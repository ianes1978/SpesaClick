import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/price_service.dart';
import '../../domain/cart_item.dart';
import '../../domain/cart_math.dart';
import '../../domain/price_store.dart';
import '../providers.dart';
import '../widgets/format.dart';
import '../widgets/product_image.dart';
import '../widgets/source_badge.dart';
import 'compare_sheet.dart';
import 'weight_dialog.dart';

class CartTile extends ConsumerWidget {
  const CartTile(this.item, {super.key});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    final t = lineTotals(item);
    final quotes = ref.watch(storeQuotesProvider);
    final stores = ref.watch(selectedStoresProvider);
    final ownStore = PriceStore.idOfQuote(item.quote);
    final p = item.product;
    final theme = Theme.of(context);
    final q = item.quote;

    final details = <String>[
      if (p.brand != null) p.brand!,
      if (p.packageDescr != null) p.packageDescr!,
    ].join(' · ');

    String unitPrice;
    if (item.isVariableWeight && item.effectivePricePerKg != null) {
      unitPrice = '${eur(item.effectivePricePerKg!)}/${p.weightUnit ?? 'kg'}';
      if (item.weightKg != null) unitPrice += ' · ${num3(item.weightKg!)} kg';
    } else {
      unitPrice = eur(q.price);
    }

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: theme.colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline),
      ),
      onDismissed: (_) => cart.remove(item.id),
      child: InkWell(
        onTap: () => showCompareSheet(context, item),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: item.taken,
                onChanged: (_) => cart.toggleTaken(item.id),
                visualDensity: VisualDensity.compact,
              ),
              Opacity(
                opacity: item.taken ? 0.5 : 1,
                child: ProductImage(p.thumbUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        decoration: item.taken
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.taken ? theme.colorScheme.outline : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (details.isNotEmpty)
                      Text(details, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.place,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            Text(
                              storeLabelOf(q, stores),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SourceBadge(q),
                        Text(unitPrice, style: theme.textTheme.bodySmall),
                        if (q.isPromo && !item.isVariableWeight)
                          Text(
                            eur(q.listPrice!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: theme.colorScheme.error,
                            ),
                          ),
                      ],
                    ),
                    if (item.product.productId > 0)
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final st in stores)
                            if (st.id != ownStore)
                              _OtherPrice(
                                item,
                                st,
                                quotes[storeQuoteKey(st.id, item.id)],
                                t.net,
                              ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Sticker(item, 30),
                        const SizedBox(width: 6),
                        _Sticker(item, 50),
                        if (item.isVariableWeight)
                          IconButton(
                            tooltip: 'Peso',
                            icon: const Icon(Icons.scale_outlined),
                            onPressed: () async {
                              final r = await showWeightDialog(context, item);
                              if (r != null) {
                                cart.setWeight(
                                  item.id,
                                  weightKg: r.weightKg,
                                  labelTotal: r.total,
                                  pricePerKg: r.pricePerKg,
                                );
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    eur(t.net),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (t.stickerSaving > 0)
                    Text(
                      eur(t.gross),
                      style: theme.textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () =>
                            cart.setQuantity(item.id, item.quantity - 1),
                      ),
                      Text(
                        '${item.quantity}',
                        style: theme.textTheme.titleMedium,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () =>
                            cart.setQuantity(item.id, item.quantity + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bollino scadenza −30% / −50%.
class _Sticker extends ConsumerWidget {
  const _Sticker(this.item, this.pct);
  final CartItem item;
  final int pct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = item.discountPercent == pct;
    final color = pct == 50 ? Colors.red : Colors.orange;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => ref.read(cartProvider.notifier).toggleSticker(item.id, pct),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color : null,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '−$pct%',
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// Prezzo della stessa riga in un altro negozio selezionato.
class _OtherPrice extends StatelessWidget {
  const _OtherPrice(this.item, this.store, this.quote, this.hereNet);
  final CartItem item;
  final PriceStore store;
  final StoreQuote? quote;
  final double hereNet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall;
    final muted = style?.copyWith(color: theme.colorScheme.outline);
    switch (quote) {
      case QuoteFound(:final result):
        final there = lineTotals(item, quote: result.quote).net;
        final diff = round2(there - hereNet);
        final color = diff < 0
            ? theme.colorScheme.error
            : diff > 0
            ? theme.colorScheme.primary
            : theme.colorScheme.outline;
        final sign = diff > 0 ? '+' : '';
        return Text(
          '${store.shortLabel}: ${eur(there)}'
          '${diff != 0 ? ' ($sign${eur(diff)})' : ''}',
          style: style?.copyWith(color: color),
        );
      case QuoteSimilar(:final candidates):
        final best = candidates
            .map((c) => c.product.price)
            .reduce((a, b) => a < b ? a : b);
        return Text(
          '${store.shortLabel}: simile da ${eur(best)} ›',
          style: muted?.copyWith(fontStyle: FontStyle.italic),
        );
      case QuoteManualMissing():
        return Text('${store.shortLabel}: inserisci prezzo ›', style: muted);
      case null:
        return Text('${store.shortLabel}: …', style: muted);
      default:
        return Text('${store.shortLabel}: —', style: muted);
    }
  }
}
