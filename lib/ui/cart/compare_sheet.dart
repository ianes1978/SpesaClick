import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/price_service.dart';
import '../../domain/cart_item.dart';
import '../../domain/cart_math.dart';
import '../../domain/price_quote.dart';
import '../../domain/price_store.dart';
import '../../domain/product.dart';
import '../providers.dart';
import '../widgets/format.dart';
import '../widgets/product_image.dart';
import 'manual_price_dialog.dart';

/// Scheda di un articolo del carrello: prezzo per EAN nei negozi Poli/Coop
/// ed equivalenti Lidl/MD/Pam (Everli) da confermare.
Future<void> showCompareSheet(BuildContext context, CartItem item) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, scroll) => _CompareSheet(item.id, scroll),
      ),
    );

class _CompareSheet extends ConsumerWidget {
  const _CompareSheet(this.itemId, this.scroll);
  final String itemId;
  final ScrollController scroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref
        .watch(cartProvider)
        .where((i) => i.id == itemId)
        .firstOrNull;
    if (item == null) return const SizedBox.shrink();
    final stores = ref.watch(selectedStoresProvider);
    final quotes = ref.watch(storeQuotesProvider);
    final theme = Theme.of(context);
    final own = PriceStore.idOfQuote(item.quote);
    final hereNet = lineTotals(item).net;
    final p = item.product;

    return ListView(
      controller: scroll,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ListTile(
          leading: ProductImage(p.thumbUrl, size: 56),
          title: Text(p.name),
          subtitle: Text(
            [
              if (p.brand != null) p.brand!,
              if (p.packageDescr != null) p.packageDescr!,
              if (p.barcode.isNotEmpty && !p.barcode.startsWith('everli:'))
                'EAN ${p.barcode}',
            ].join(' · '),
          ),
          trailing: Text(
            eur(hereNet),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(),
        for (final s in stores)
          if (s.id == own)
            ListTile(
              dense: true,
              leading: const Icon(Icons.shopping_cart),
              title: Text(s.shortLabel),
              subtitle: Text(
                s.chain.isManual
                    ? 'Qui compri questo articolo · prezzo inserito a mano '
                          'il ${shortDate(item.quote.readAt)}'
                    : 'Qui compri questo articolo',
              ),
              trailing: Text(eur(hereNet)),
              onTap: s.chain.isManual
                  ? () => editManualPrice(context, ref, s, item)
                  : null,
            )
          else
            _StoreSection(
              store: s,
              item: item,
              quote: quotes[storeQuoteKey(s.id, item.id)],
              hereNet: hereNet,
            ),
      ],
    );
  }
}

class _StoreSection extends ConsumerWidget {
  const _StoreSection({
    required this.store,
    required this.item,
    required this.quote,
    required this.hereNet,
  });

  final PriceStore store;
  final CartItem item;
  final StoreQuote? quote;
  final double hereNet;

  String _diff(double there) {
    final d = round2(there - hereNet);
    if (d == 0) return 'stesso prezzo';
    return d > 0 ? '+${eur(d)}' : '−${eur(-d)}';
  }

  String _unit(Product p) => p.pricePerKg == null
      ? ''
      : ' · ${eur(p.pricePerKg!)}/${p.weightUnit ?? 'kg'}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final everli = store.chain.isEverli;
    final manual = store.chain.isManual;
    final notifier = ref.read(storeQuotesProvider.notifier);
    switch (quote) {
      case null:
        return ListTile(
          dense: true,
          leading: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text(store.shortLabel),
          subtitle: const Text('Cerco il prezzo…'),
        );
      case QuoteFound(:final result):
        final there = lineTotals(item, quote: result.quote).net;
        final tile = ListTile(
          dense: true,
          leading: Icon(everli ? Icons.link : Icons.check_circle_outline),
          title: Text(store.shortLabel),
          subtitle: Text(
            manual
                ? 'Prezzo inserito a mano il ${shortDate(result.quote.readAt)}'
                      '${_unit(result.product)} · tocca per modificarlo'
                : everli
                ? 'Abbinato: ${result.product.name}'
                      '${_unit(result.product)}\n'
                      'Prezzo Everli · ${shortDate(result.quote.readAt)}, in negozio '
                      'può differire'
                : 'Stesso EAN${_unit(result.product)}',
          ),
          isThreeLine: everli,
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(eur(there), style: theme.textTheme.titleSmall),
              Text(_diff(there), style: theme.textTheme.bodySmall),
            ],
          ),
          onLongPress: everli ? () => notifier.removeMatch(store, item) : null,
          onTap: manual
              ? () => editManualPrice(
                  context,
                  ref,
                  store,
                  item,
                  current: result.quote,
                )
              : null,
        );
        return Column(
          children: [
            tile,
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton.icon(
                  onPressed: () {
                    notifier.moveItem(item, store);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.place, size: 16),
                  label: Text('Compra qui (${store.shortLabel})'),
                ),
              ),
            ),
          ],
        );
      case QuoteSimilar(:final candidates):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              dense: true,
              leading: const Icon(Icons.compare_arrows),
              title: Text('Equivalenti ${store.shortLabel}'),
              subtitle: const Text(
                'Prodotti simili, non lo stesso articolo. '
                'Conferma se è lo stesso per usarlo nel confronto.',
              ),
            ),
            for (final c in candidates)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        ProductImage(c.product.thumbUrl, size: 44),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                [
                                      if ((c.product.brand ?? '').isNotEmpty)
                                        c.product.brand!,
                                      if (c.product.packageDescr != null)
                                        c.product.packageDescr!,
                                    ].join(' · ') +
                                    _unit(c.product),
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                '${eur(c.product.price)}'
                                '${c.product.isPromo ? ' (promo, era ${eur(c.product.listPrice!)})' : ''}'
                                ' · somiglianza ${(c.score * 100).round()}%'
                                ' · Everli ${shortDate(c.readAt)}',
                                style: theme.textTheme.bodySmall,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () => notifier.confirmMatch(
                                    store,
                                    item,
                                    c.product,
                                  ),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('È lo stesso prodotto'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      case QuoteManualMissing():
        return ListTile(
          dense: true,
          leading: const Icon(Icons.edit_note),
          title: Text(store.shortLabel),
          subtitle: const Text(
            'Nessun prezzo: inseriscilo per confrontarlo '
            'e per comprarlo qui',
          ),
          trailing: FilledButton.tonal(
            onPressed: () => editManualPrice(context, ref, store, item),
            child: const Text('Inserisci'),
          ),
        );
      case QuoteNotFound():
        return ListTile(
          dense: true,
          leading: const Icon(Icons.search_off),
          title: Text(store.shortLabel),
          subtitle: Text(everli ? 'Nessun prodotto simile' : 'Non a listino'),
        );
      case QuoteUnavailable(:final reason):
        return ListTile(
          dense: true,
          leading: const Icon(Icons.lock_clock),
          title: Text(store.shortLabel),
          subtitle: Text(reason),
        );
      case QuoteFailed(:final message):
        return ListTile(
          dense: true,
          leading: const Icon(Icons.error_outline),
          title: Text(store.shortLabel),
          subtitle: Text(message),
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.refresh,
          ),
        );
    }
  }
}

/// Inserisce o modifica il prezzo a mano di [item] nel negozio [store].
/// Se la riga non si compra ancora lì, chiede se spostarla.
Future<void> editManualPrice(
  BuildContext context,
  WidgetRef ref,
  PriceStore store,
  CartItem item, {
  PriceQuote? current,
}) async {
  final own = PriceStore.idOfQuote(item.quote) == store.id;
  final cur = current ?? (own ? item.quote : null);
  final r = await showManualPriceDialog(
    context,
    item,
    store,
    current: cur?.price,
    currentPerKg: cur?.pricePerKg,
  );
  if (r == null || !context.mounted) return;
  final notifier = ref.read(storeQuotesProvider.notifier);
  await notifier.setManualPrice(
    store,
    item,
    price: r.price,
    pricePerKg: r.pricePerKg,
  );
  if (r.price == null || own || !context.mounted) return;
  final move = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Compri questo articolo da ${store.shortLabel}?'),
      content: Text('Prezzo salvato: ${eur(r.price!)}.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('No, solo confronto'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Sì, compra qui'),
        ),
      ],
    ),
  );
  if (move ?? false) {
    final fresh = ref
        .read(cartProvider)
        .where((i) => i.id == item.id)
        .firstOrNull;
    if (fresh != null) notifier.moveItem(fresh, store);
  }
}
