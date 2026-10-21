import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/api_exceptions.dart';
import '../../domain/cart_math.dart';
import '../../domain/store.dart';
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
    final outcome = await handleScannedCode(ref, code);
    switch (outcome) {
      case ScanAdded(:final item):
        _feedback.ok();
        messenger.showSnackBar(SnackBar(
            duration: const Duration(seconds: 2),
            content: Text('Aggiunto: ${item.product.name}')));
      case ScanNotFound(:final code):
        _feedback.error();
        messenger.showSnackBar(
            SnackBar(content: Text('Prodotto non trovato: $code')));
      case ScanError(:final message):
        _feedback.error();
        messenger.showSnackBar(SnackBar(content: Text(message)));
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
              child: const Text('Annulla')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Cerca')),
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

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Svuotare il carrello?'),
        content: const Text('Tutte le righe verranno eliminate.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annulla')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Svuota')),
        ],
      ),
    );
    if (ok ?? false) ref.read(cartProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spesa Trento'),
        actions: [
          const Flexible(child: StoreSelector()),
          PopupMenuButton<String>(
            onSelected: (v) => switch (v) {
              'manual' => _manualEntry(),
              'simulate' => _simulate(),
              'clear' => _clear(),
              _ => null,
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'manual', child: Text('Inserisci EAN')),
              PopupMenuItem(value: 'simulate', child: Text('Simula scansione')),
              PopupMenuItem(value: 'clear', child: Text('Svuota carrello')),
            ],
          ),
        ],
      ),
      body: items.isEmpty
          ? _Empty(onManual: _manualEntry, onSimulate: _simulate)
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) => CartTile(items[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scanner'),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scansiona'),
      ),
      bottomNavigationBar: items.isEmpty ? null : const _SummaryBar(),
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
            Icon(Icons.shopping_cart_outlined,
                size: 72, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            const Text('Il carrello è vuoto.\nScansiona il primo prodotto!',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Wrap(spacing: 8, children: [
              OutlinedButton.icon(
                  onPressed: onManual,
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Inserisci EAN')),
              OutlinedButton.icon(
                  onPressed: onSimulate,
                  icon: const Icon(Icons.science_outlined),
                  label: const Text('Simula scansione')),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Riepilogo fisso: totale, pezzi, risparmio, confronto con l'altro negozio.
class _SummaryBar extends ConsumerStatefulWidget {
  const _SummaryBar();

  @override
  ConsumerState<_SummaryBar> createState() => _SummaryBarState();
}

class _SummaryBarState extends ConsumerState<_SummaryBar> {
  String? _progress;

  Future<void> _compare() async {
    final session = ref.read(sessionProvider);
    final messenger = ScaffoldMessenger.of(context);
    if (session.storeId == null) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Collega DupliClick per confrontare i negozi.')));
      return;
    }
    if (!await confirmStoreSwitch(context, restore: true)) return;
    final other = ref.read(compareStoreProvider);
    final items = ref.read(cartProvider);
    try {
      await ref.read(storeRepoProvider).compare(
        items.map((i) => i.product.barcode),
        [session.storeId!, other.addressId],
        onProgress: (m) => mounted ? setState(() => _progress = m) : null,
      );
      messenger.showSnackBar(
          const SnackBar(content: Text('Confronto aggiornato.')));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(
          duration: const Duration(seconds: 8), content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _progress = null);
      ref.invalidate(otherQuotesProvider);
      ref.read(sessionProvider.notifier).verify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = ref.watch(cartTotalsProvider);
    final items = ref.watch(cartProvider);
    final other = ref.watch(compareStoreProvider);
    final quotes = ref.watch(otherQuotesProvider).value ?? const {};
    final theme = Theme.of(context);

    Widget compareLine;
    if (_progress != null) {
      compareLine = Row(children: [
        const SizedBox(
            width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
        const SizedBox(width: 8),
        Expanded(child: Text(_progress!, style: theme.textTheme.bodySmall)),
      ]);
    } else if (quotes.isEmpty) {
      compareLine = InkWell(
        onTap: _compare,
        child: Text('Confronta con ${other.shortName} →',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.primary)),
      );
    } else {
      final o = otherStoreTotal(items, quotes);
      final diff = round2(o.total - totals.total);
      final name = other.addressId == kPoliGardoloId ? 'Gardolo' : other.shortName;
      final text = diff > 0
          ? 'Qui risparmi ${eur(diff)}'
          : diff < 0
              ? 'A $name spenderesti ${eur(-diff)} in meno'
              : 'Stesso totale a $name';
      compareLine = InkWell(
        onTap: _compare,
        child: Text(
          '$name: ${eur(o.total)} · $text'
          '${o.missing > 0 ? ' (${o.missing} senza prezzo)' : ''}',
          style: theme.textTheme.bodySmall,
        ),
      );
    }

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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${totals.pieces} pezzi',
                            style: theme.textTheme.bodyMedium),
                        if (totals.saving > 0)
                          Text('Risparmio ${eur(totals.saving)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary)),
                      ],
                    ),
                  ),
                  Text(eur(totals.total),
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Align(alignment: Alignment.centerLeft, child: compareLine),
            ],
          ),
        ),
      ),
    );
  }
}
