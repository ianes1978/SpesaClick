import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/api_exceptions.dart';
import '../../domain/cart_item.dart';
import '../../domain/cart_math.dart';
import '../../domain/chain.dart';
import '../../domain/price_store.dart';
import '../feedback.dart';
import '../providers.dart';
import '../widgets/format.dart';
import '../widgets/store_selector.dart';
import 'cart_tile.dart';
import 'scan_handler.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _feedback = ScanFeedback();

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  Future<void> _submitCode(String code) async {
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await processScan(context, ref, code);
    if (!mounted) return;
    switch (outcome) {
      case ScanAdded(:final item, :final store):
        _feedback.ok();
        messenger.showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(
              'Aggiunto: ${item.product.name}'
              '${store != null ? ' (${store.shortLabel})' : ''}',
            ),
          ),
        );
      case ScanNeedsWeight():
        _feedback.ok();
      case ScanNotFound(:final code, :final detail):
        _feedback.error();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Prodotto non trovato: $code'
              '${detail != null ? '\n$detail' : ''}',
            ),
          ),
        );
      case ScanError(:final message):
        _feedback.error();
        messenger.showSnackBar(SnackBar(content: Text(message)));
      case ScanCancelled():
        break;
    }
  }

  Future<void> _manualEntry() async {
    final ctrl = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inserisci EAN'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '8 o 13 cifre'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Cerca'),
          ),
        ],
      ),
    );
    if (code != null && code.trim().isNotEmpty) await _submitCode(code);
  }

  Future<void> _simulate() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          const ListTile(title: Text('Simula scansione')),
          for (final (code, label) in kSampleCodes)
            ListTile(
              title: Text(label),
              subtitle: Text(code),
              onTap: () => Navigator.pop(ctx, code),
            ),
        ],
      ),
    );
    if (code != null) await _submitCode(code);
  }

  void _cheapest() {
    final n = ref.read(storeQuotesProvider.notifier).moveAllToCheapest();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          n == 0
              ? 'Ogni articolo è già nel negozio più conveniente '
                    '(fra quelli con un prezzo).'
              : '$n articoli spostati nel negozio più conveniente.',
        ),
      ),
    );
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Svuotare il carrello?'),
        content: const Text('Tutte le righe verranno eliminate.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Svuota'),
          ),
        ],
      ),
    );
    if (ok ?? false) ref.read(cartProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final stores = ref.watch(selectedStoresProvider);
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spesa Trento'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/stores'),
            icon: Icon(Icons.storefront, color: onPrimary, size: 18),
            label: Text(
              'Negozi (${stores.length})',
              style: TextStyle(color: onPrimary),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => switch (v) {
              'manual' => _manualEntry(),
              'simulate' => _simulate(),
              'clear' => _clear(),
              'cheapest' => _cheapest(),
              'untick' => ref.read(cartProvider.notifier).clearTaken(),
              _ => null,
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'manual', child: Text('Inserisci EAN')),
              PopupMenuItem(value: 'simulate', child: Text('Simula scansione')),
              PopupMenuItem(
                value: 'cheapest',
                child: Text('Assegna ogni articolo al negozio più conveniente'),
              ),
              PopupMenuItem(
                value: 'untick',
                child: Text('Togli tutte le spunte'),
              ),
              PopupMenuItem(value: 'clear', child: Text('Svuota carrello')),
            ],
          ),
        ],
      ),
      body: items.isEmpty
          ? _Empty(onManual: _manualEntry, onSimulate: _simulate)
          : const _FilteredList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scanner'),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scansiona'),
      ),
      bottomNavigationBar: items.isEmpty ? null : const _SummaryBar(),
    );
  }
}

/// Lista filtrata per negozio: in ogni negozio vedi cosa comprare lì.
/// Gli articoli già presi vanno in fondo.
class _FilteredList extends ConsumerWidget {
  const _FilteredList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final stores = ref.watch(selectedStoresProvider);
    final filter = ref.watch(cartFilterProvider);
    final theme = Theme.of(context);

    String storeOf(CartItem i) => PriceStore.idOfQuote(i.quote);
    final counts = <String, int>{};
    for (final i in items) {
      counts[storeOf(i)] = (counts[storeOf(i)] ?? 0) + 1;
    }
    // Negozi selezionati più eventuali negozi di righe già in lista.
    final chips = <(String, String)>[
      for (final s in stores) (s.id, s.shortLabel),
      for (final i in items)
        if (!stores.any((s) => s.id == storeOf(i)))
          (storeOf(i), storeLabelOf(i.quote, stores)),
    ];
    final seen = <String>{};
    chips.retainWhere((c) => seen.add(c.$1));

    final visible = [
      for (final i in items)
        if (filter == null || storeOf(i) == filter) i,
    ]..sort((a, b) => (a.taken ? 1 : 0) - (b.taken ? 1 : 0));
    final taken = visible.where((i) => i.taken).length;
    final todo = cartTotals(visible.where((i) => !i.taken)).total;

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text('Tutti (${items.length})'),
                  selected: filter == null,
                  onSelected: (_) =>
                      ref.read(cartFilterProvider.notifier).set(null),
                ),
              ),
              for (final (id, label) in chips)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    avatar: const Icon(Icons.place, size: 16),
                    label: Text('$label (${counts[id] ?? 0})'),
                    selected: filter == id,
                    onSelected: (on) => ref
                        .read(cartFilterProvider.notifier)
                        .set(on ? id : null),
                  ),
                ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          color: theme.colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            visible.isEmpty
                ? 'Niente da comprare qui.'
                : 'Presi $taken/${visible.length}'
                      '${taken < visible.length ? ' · da prendere ${eur(todo)}' : ' · tutto preso!'}',
            style: theme.textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: visible.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) =>
                CartTile(visible[i], key: ValueKey(visible[i].id)),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onManual, required this.onSimulate});
  final VoidCallback onManual;
  final VoidCallback onSimulate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            const Text(
              'Il carrello è vuoto.\nScansiona il primo prodotto!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onManual,
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Inserisci EAN'),
                ),
                OutlinedButton.icon(
                  onPressed: onSimulate,
                  icon: const Icon(Icons.science_outlined),
                  label: const Text('Simula scansione'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Riepilogo fisso: totale, pezzi, risparmio e totale in ogni negozio
/// selezionato.
class _SummaryBar extends ConsumerStatefulWidget {
  const _SummaryBar();

  @override
  ConsumerState<_SummaryBar> createState() => _SummaryBarState();
}

class _SummaryBarState extends ConsumerState<_SummaryBar> {
  String? _progress;
  bool _expanded = false;

  /// Legge i prezzi dei negozi Poli selezionati spostando il carrello
  /// DupliClick reale e ripristinandolo alla fine.
  Future<void> _refreshPoli() async {
    final session = ref.read(sessionProvider);
    final messenger = ScaffoldMessenger.of(context);
    if (session.storeId == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Collega DupliClick per i prezzi dei negozi Poli.'),
        ),
      );
      return;
    }
    final ids = ref
        .read(selectedStoresProvider)
        .where((s) => s.chain == Chain.poli && !s.isOnline)
        .map((s) => s.storeId!)
        .toList();
    if (!ids.contains(session.storeId)) ids.insert(0, session.storeId!);
    if (!await confirmStoreSwitch(context, restore: true)) return;
    final items = ref.read(cartProvider);
    try {
      await ref
          .read(storeRepoProvider)
          .compare(
            items.map((i) => i.product.barcode),
            ids,
            onProgress: (m) => mounted ? setState(() => _progress = m) : null,
          );
      messenger.showSnackBar(
        const SnackBar(content: Text('Prezzi Poli aggiornati.')),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 8),
          content: Text(e.message),
        ),
      );
    } finally {
      if (mounted) setState(() => _progress = null);
      ref.read(storeQuotesProvider.notifier).refresh();
      ref.read(sessionProvider.notifier).verify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = ref.watch(cartTotalsProvider);
    final storeTotals = ref.watch(storeTotalsProvider);
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;

    final complete = storeTotals.where((t) => t.complete).toList();
    final cheapest = complete.isEmpty
        ? null
        : complete.reduce((a, b) => a.total <= b.total ? a : b);
    final needsPoli = storeTotals.any(
      (t) =>
          t.store.chain == Chain.poli &&
          !t.store.isOnline &&
          t.unavailable != null,
    );

    final rows = <Widget>[
      for (final t in storeTotals)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              Icon(
                t == cheapest ? Icons.star : Icons.store_outlined,
                size: 14,
                color: t == cheapest ? theme.colorScheme.primary : null,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  t.unavailable ??
                      (t.matched == 0
                          ? '${t.store.shortLabel}: ${t.store.chain.isManual ? 'nessun prezzo inserito' : 'nessun articolo abbinato'}'
                          : '${t.store.shortLabel}'
                                '${t.complete ? '' : ' (${t.matched}/${t.count} articoli, mancano ${t.missing})'}'),
                  style: small,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (t.unavailable == null && t.matched > 0) ...[
                Text(
                  eur(t.total),
                  style: small?.copyWith(
                    fontWeight: t == cheapest ? FontWeight.bold : null,
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    t.diff == 0
                        ? '='
                        : '${t.diff > 0 ? '+' : '−'}${eur(t.diff.abs())}',
                    textAlign: TextAlign.end,
                    style: small,
                  ),
                ),
              ],
            ],
          ),
        ),
      if (storeTotals.any((t) => t.store.chain.isEverli))
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            'Lidl/MD/Pam: prezzi Everli sui soli articoli abbinati, in negozio '
            'possono differire; consegna esclusa. Tocca una riga per gli '
            'equivalenti.',
            style: small?.copyWith(color: theme.colorScheme.outline),
          ),
        ),
    ];

    return Material(
      elevation: 8,
      color: theme.colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${totals.pieces} pezzi',
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (totals.saving > 0)
                            Text(
                              'Risparmio ${eur(totals.saving)}',
                              style: small?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          if (cheapest != null && !_expanded)
                            Text(
                              'Più conveniente: ${cheapest.store.shortLabel} '
                              '${eur(cheapest.total)}',
                              style: small,
                            ),
                        ],
                      ),
                    ),
                    Text(
                      eur(totals.total),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(_expanded ? Icons.expand_more : Icons.expand_less),
                  ],
                ),
              ),
              if (_expanded) ...[
                const SizedBox(height: 6),
                ...rows,
                if (_progress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_progress!, style: small)),
                      ],
                    ),
                  )
                else if (needsPoli)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _refreshPoli,
                      icon: const Icon(Icons.sync, size: 16),
                      label: const Text('Aggiorna prezzi dei negozi Poli'),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
