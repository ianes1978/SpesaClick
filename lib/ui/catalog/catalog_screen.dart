import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api_exceptions.dart';
import '../../data/ebsn_api.dart';
import '../../data/product_repository.dart';
import '../../domain/chain.dart';
import '../../domain/price_quote.dart';
import '../../domain/product.dart';
import '../cart/scan_handler.dart';
import '../providers.dart';
import '../widgets/chain_switcher.dart';
import '../widgets/format.dart';
import '../widgets/product_image.dart';
import '../widgets/store_selector.dart';

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
final coopCategoriesProvider = FutureProvider<List<EbsnCategory>>((ref) => ref
    .watch(productRepoProvider(Chain.coop))
    .categories(includeCollections: true));

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
  final _products = <Product>[];
  int _page = 0;
  bool _hasMore = false;
  bool _loading = false;
  bool _offline = false;
  String? _error;
  String? _category;
  int _generation = 0;

  /// Categoria Click&Coop che si sta sfogliando (al posto della ricerca).
  EbsnCategory? _browse;

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
    q = q.trim();
    setState(() {
      _generation++;
      _browse = browse;
      _query = browse != null ? browse.name : q;
      _products.clear();
      _page = 0;
      _hasMore = _query.isNotEmpty;
      _error = null;
      _category = null;
      _loading = false;
    });
    if (_query.isNotEmpty) _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore || _query.isEmpty) return;
    final gen = _generation;
    setState(() => _loading = true);
    try {
      final repo = ref.read(productRepoProvider(ref.read(activeChainProvider)));
      final browse = _browse;
      final r = browse != null
          ? (page: await repo.byCategory(browse.id, page: _page + 1), offline: false)
          : await repo.search(_query, page: _page + 1);
      if (gen != _generation || !mounted) return;
      setState(() {
        _products.addAll(r.page.products);
        _page = r.page.page;
        _hasMore = r.page.hasMore && r.page.products.isNotEmpty;
        _offline = r.offline;
      });
    } on ApiException catch (e) {
      if (gen == _generation && mounted) {
        setState(() {
          _error = e.message;
          _hasMore = false;
        });
      }
    } finally {
      if (gen == _generation && mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add(Product p) async {
    final storeId =
        p.chain == Chain.poli ? ref.read(sessionProvider).storeId : null;
    final source = _offline
        ? PriceSource.offline
        : (storeId != null ? PriceSource.store : PriceSource.online);
    final item = ref.read(cartProvider.notifier).add(
        LookupResult(p, p.quote(source, DateTime.now(), storeId: storeId)));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text('Aggiunto: ${p.name}'),
    ));
    final outcome = ScanAdded(item, isLabel: false);
    if (outcome.needsWeight) await completeWeight(context, ref, outcome);
  }

  @override
  Widget build(BuildContext context) {
    final chain = ref.watch(activeChainProvider);
    ref.listen(activeChainProvider, (_, _) {
      _search.clear();
      _start('');
    });
    final categories = _products
        .map((p) => p.category)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    final visible = _category == null
        ? _products
        : _products.where((p) => p.category == _category).toList();

    return Scaffold(
      appBar: AppBar(
        title: const ChainSwitcher(),
        titleSpacing: 8,
        actions: [
          if (chain == Chain.poli) const Flexible(child: StoreSelector()),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: SearchBar(
              controller: _search,
              hintText: 'Cerca su ${chain.serviceName}…',
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
      body: Column(children: [
        if (chain == Chain.coop) const CoopPriceNotice(),
        if (_browse != null)
          ListTile(
            dense: true,
            leading: const Icon(Icons.category_outlined),
            title: Text(_browse!.name),
            trailing: IconButton(
                icon: const Icon(Icons.close), onPressed: () => _start('')),
          ),
        Expanded(child: _query.isEmpty
          ? _Highlights(
              chain: chain,
              onTap: (q) {
                _search.text = q;
                _start(q);
              },
              onCategory: (c) {
                _search.clear();
                _start('', browse: c);
              })
          : Column(
              children: [
                if (categories.length > 1)
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        for (final c in categories)
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: FilterChip(
                              label: Text(c),
                              selected: _category == c,
                              onSelected: (s) =>
                                  setState(() => _category = s ? c : null),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (_offline)
                  const MaterialBanner(
                    content: Text('Senza rete: risultati dal listino offline.'),
                    actions: [SizedBox.shrink()],
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    itemCount: visible.length + (_loading ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i >= visible.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final p = visible[i];
                      return _ProductTile(p, onAdd: () => _add(p));
                    },
                  ),
                ),
                if (!_loading && visible.isEmpty && _error == null)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Nessun prodotto trovato.'),
                  ),
              ],
            )),
      ]),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile(this.p, {required this.onAdd});
  final Product p;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = [
      if (p.brand != null) p.brand!,
      if (p.packageDescr != null) p.packageDescr!,
      if (p.pricePerKg != null)
        '${eur(p.pricePerKg!)}/${p.weightUnit ?? 'kg'}',
    ].join(' · ');
    return ListTile(
      onTap: onAdd,
      leading: ProductImage(p.thumbUrl, size: 48),
      title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(sub),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(eur(p.price),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          if (p.isPromo)
            Text(eur(p.listPrice!),
                style: theme.textTheme.bodySmall?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: theme.colorScheme.error)),
        ],
      ),
    );
  }
}

class _Highlights extends ConsumerWidget {
  const _Highlights(
      {required this.chain, required this.onTap, required this.onCategory});
  final Chain chain;
  final void Function(String) onTap;
  final void Function(EbsnCategory) onCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = chain == Chain.coop ? ref.watch(coopCategoriesProvider) : null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('In evidenza: prodotti trentini',
            style: Theme.of(context).textTheme.titleMedium),
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
          Text('Reparti Click&Coop',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          cats.when(
            data: (list) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in list)
                  ActionChip(label: Text(c.name), onPressed: () => onCategory(c)),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Reparti non disponibili: $e'),
          ),
        ],
        const SizedBox(height: 24),
        Text('Tocca un prodotto per aggiungerlo al carrello.',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
