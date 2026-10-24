import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api_exceptions.dart';
import '../../data/ebsn_api.dart';
import '../../data/product_repository.dart';
import '../../domain/chain.dart';
import '../../domain/price_quote.dart';
import '../../domain/price_store.dart';
import '../../domain/product.dart';
import '../cart/scan_handler.dart';
import '../providers.dart';
import '../widgets/format.dart';
import '../widgets/product_image.dart';

/// Prodotti trentini in evidenza (ricerche predefinite).
const kTrentinoHighlights = <String>[
  'Melinda',
  'Trentingrana',
  'Spressa',
  'Latte Trento',
  'canederli',
  'Felicetti',
  'Forst',
  'Ferrari',
  'Rotari',
  'Teroldego',
  'Marzadro',
  'farina Storo',
];

/// Categorie Click&Coop (raccolte comprese, utili per sfogliare le promo).
final coopCategoriesProvider = FutureProvider<List<EbsnCategory>>(
  (ref) => ref
      .watch(productRepoProvider(Chain.coop))
      .categories(includeCollections: true),
);

/// Stato della ricerca in un negozio.
class _Source {
  _Source(this.store);
  final PriceStore store;
  int page = 0;
  bool hasMore = true;
  bool offline = false;
  String? error;
}

/// Uno stesso prodotto (stesso EAN) trovato in uno o più negozi.
class _Group {
  _Group(this.barcode);
  final String barcode;
  final byStore = <String, Product>{};
  final offline = <String>{};
}

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;

  String _query = '';
  EbsnCategory? _browse;
  final _sources = <_Source>[];
  final _groups = <String, _Group>{};
  bool _loading = false;
  int _generation = 0;

  /// Negozio selezionato nei filtri in alto (null = tutti).
  String? _filter;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _start(v));
  }

  void _start(String q, {EbsnCategory? browse}) {
    final svc = ref.read(priceServiceProvider);
    final stores = ref.read(selectedStoresProvider);
    q = q.trim();
    setState(() {
      _generation++;
      _browse = browse;
      _query = browse?.name ?? q;
      _groups.clear();
      _sources
        ..clear()
        ..addAll([
          for (final s in stores)
            if (svc.isSearchable(s) &&
                (browse == null || s.chain == Chain.coop))
              _Source(s),
        ]);
      _loading = false;
    });
    if (_query.isNotEmpty) _loadMore();
  }

  /// Carica la pagina successiva da ogni negozio che ne ha ancora.
  Future<void> _loadMore() async {
    if (_loading || _query.isEmpty) return;
    final todo = _sources.where((s) => s.hasMore).toList();
    if (todo.isEmpty) return;
    final gen = _generation;
    setState(() => _loading = true);
    final svc = ref.read(priceServiceProvider);
    await Future.wait(
      todo.map((src) async {
        try {
          final ({ProductPage page, bool offline}) r;
          final browse = _browse;
          if (browse != null) {
            r = (
              page: await svc.byCategory(
                src.store,
                browse.id,
                page: src.page + 1,
              ),
              offline: false,
            );
          } else {
            r = await svc.search(src.store, _query, page: src.page + 1);
          }
          if (gen != _generation || !mounted) return;
          setState(() {
            src.page = r.page.page;
            src.hasMore = r.page.hasMore && r.page.products.isNotEmpty;
            src.offline = r.offline;
            for (final p in r.page.products) {
              final g = _groups.putIfAbsent(p.barcode, () => _Group(p.barcode));
              g.byStore[src.store.id] = p;
              if (r.offline) g.offline.add(src.store.id);
            }
          });
        } on ApiException catch (e) {
          if (gen != _generation || !mounted) return;
          setState(() {
            src.error = e.message;
            src.hasMore = false;
          });
        }
      }),
    );
    if (gen == _generation && mounted) setState(() => _loading = false);
  }

  List<(PriceStore, LookupResult)> _options(_Group g) {
    final session = ref.read(sessionProvider);
    final now = DateTime.now();
    return [
      for (final src in _sources)
        if ((_filter == null || _filter == src.store.id) &&
            g.byStore[src.store.id] != null)
          () {
            final p = g.byStore[src.store.id]!;
            final s = src.store;
            final source = g.offline.contains(s.id)
                ? PriceSource.offline
                : (s.chain == Chain.poli &&
                      !s.isOnline &&
                      s.storeId == session.storeId)
                ? PriceSource.store
                : PriceSource.online;
            return (
              s,
              LookupResult(p, p.quote(source, now, storeId: s.storeId)),
            );
          }(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedStoresProvider);
    final svc = ref.watch(priceServiceProvider);
    ref.listen(selectedStoresProvider, (_, _) => _start(_search.text));
    ref.listen(sessionProvider, (a, b) {
      if (a?.storeId != b.storeId) _start(_search.text);
    });
    final hasCoop = selected.any((s) => s.chain == Chain.coop);
    final hasEverli = selected.any((s) => s.chain.isEverli);
    final visible = _groups.values
        .where((g) => _filter == null || g.byStore.containsKey(_filter))
        .toList();
    final errors = _sources.where((s) => s.error != null).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogo'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: SearchBar(
              controller: _search,
              hintText: 'Cerca nei negozi selezionati…',
              leading: const Icon(Icons.search),
              trailing: [
                if (_search.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _search.clear();
                      _start('');
                    },
                  ),
              ],
              onChanged: _onChanged,
              onSubmitted: _start,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtri: un chip per negozio selezionato.
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('Tutti'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                ),
                for (final s in selected)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: svc.isSearchable(s)
                        ? ChoiceChip(
                            label: Text(s.shortLabel),
                            selected: _filter == s.id,
                            onSelected: (on) =>
                                setState(() => _filter = on ? s.id : null),
                          )
                        : ActionChip(
                            avatar: const Icon(Icons.lock_clock, size: 16),
                            label: Text(s.shortLabel),
                            onPressed: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      s.chain.isManual
                                          ? '${s.shortLabel}: prezzi inseriti a '
                                                'mano, nessuna ricerca. Inserisci '
                                                'il prezzo dalla riga del carrello.'
                                          : '${svc.unavailableReason(s)}. '
                                                'La ricerca testuale funziona solo '
                                                'sul negozio attivo nel carrello '
                                                'DupliClick.',
                                    ),
                                  ),
                                ),
                          ),
                  ),
              ],
            ),
          ),
          if (_sources.any((s) => s.offline))
            const MaterialBanner(
              content: Text(
                'Senza rete: alcuni risultati vengono dal listino '
                'offline.',
              ),
              actions: [SizedBox.shrink()],
            ),
          if (hasCoop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Prezzi Coop: listino online Click&Coop, in negozio possono '
                'differire.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (hasEverli)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Lidl/MD/Pam: prezzi Everli (data di lettura sul prodotto), in '
                'negozio possono differire. Si mostrano solo i risultati che '
                'contengono tutte le parole cercate.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (_browse != null)
            ListTile(
              dense: true,
              leading: const Icon(Icons.category_outlined),
              title: Text('Reparto Coop: ${_browse!.name}'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _start(''),
              ),
            ),
          for (final e in errors)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Text(
                '${e.store.shortLabel}: ${e.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: _query.isEmpty
                ? _Highlights(
                    showCoopDepartments: hasCoop,
                    onTap: (q) {
                      _search.text = q;
                      _start(q);
                    },
                    onCategory: (c) {
                      _search.clear();
                      _start('', browse: c);
                    },
                  )
                : selected.isEmpty
                ? const Center(child: Text('Nessun negozio selezionato.'))
                : ListView.builder(
                    controller: _scroll,
                    itemCount: visible.length + 1,
                    itemBuilder: (_, i) {
                      if (i == visible.length) {
                        if (_loading) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return visible.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(24),
                                child: Text('Nessun prodotto trovato.'),
                              )
                            : const SizedBox(height: 24);
                      }
                      final g = visible[i];
                      return _GroupTile(
                        options: _options(g),
                        onTap: () => addFromCatalog(context, ref, _options(g)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Un prodotto con i prezzi nei negozi in cui è stato trovato.
class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.options, required this.onTap});
  final List<(PriceStore, LookupResult)> options;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = options.first.$2.product;
    final sub = [
      if (p.brand != null) p.brand!,
      if (p.packageDescr != null) p.packageDescr!,
    ].join(' · ');
    final cheapest = options
        .map((o) => o.$2.quote.price)
        .reduce((a, b) => a < b ? a : b);
    return ListTile(
      onTap: onTap,
      leading: ProductImage(p.thumbUrl, size: 48),
      title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sub.isNotEmpty) Text(sub),
          Wrap(
            spacing: 10,
            children: [
              for (final (s, r) in options)
                Text(
                  '${s.shortLabel}: ${eur(r.quote.price)}'
                  '${r.product.isVariableWeight && r.quote.pricePerKg != null ? '/${r.product.weightUnit ?? 'kg'}' : ''}'
                  '${r.quote.isPromo ? ' (promo)' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight:
                        options.length > 1 && r.quote.price <= cheapest + 0.001
                        ? FontWeight.bold
                        : null,
                    color:
                        options.length > 1 && r.quote.price <= cheapest + 0.001
                        ? theme.colorScheme.primary
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: Text(
        eur(cheapest),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Highlights extends ConsumerWidget {
  const _Highlights({
    required this.showCoopDepartments,
    required this.onTap,
    required this.onCategory,
  });
  final bool showCoopDepartments;
  final void Function(String) onTap;
  final void Function(EbsnCategory) onCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = showCoopDepartments ? ref.watch(coopCategoriesProvider) : null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'In evidenza: prodotti trentini',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final h in kTrentinoHighlights)
              ActionChip(
                avatar: const Icon(Icons.landscape_outlined, size: 18),
                label: Text(h),
                onPressed: () => onTap(h),
              ),
          ],
        ),
        if (cats != null) ...[
          const SizedBox(height: 24),
          Text(
            'Reparti Click&Coop',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          cats.when(
            data: (list) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in list)
                  ActionChip(
                    label: Text(c.name),
                    onPressed: () => onCategory(c),
                  ),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Reparti non disponibili: $e'),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Tocca un prodotto per aggiungerlo al carrello: se è in più '
          'negozi puoi scegliere quale prezzo usare.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
