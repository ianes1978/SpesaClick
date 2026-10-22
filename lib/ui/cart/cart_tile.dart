import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/cart_item.dart';
import '../../domain/cart_math.dart';
import '../../domain/price_quote.dart';
import '../providers.dart';
import '../widgets/format.dart';
import '../widgets/product_image.dart';
import '../widgets/source_badge.dart';
import 'weight_dialog.dart';

class CartTile extends ConsumerWidget {
  const CartTile(this.item, {super.key});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    final t = lineTotals(item);
    final cross = ref.watch(crossChainProvider);
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImage(p.thumbUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  if (details.isNotEmpty)
                    Text(details, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SourceBadge(q),
                      Text(unitPrice, style: theme.textTheme.bodySmall),
                      if (q.isPromo && !item.isVariableWeight)
                        Text(eur(q.listPrice!),
                            style: theme.textTheme.bodySmall?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: theme.colorScheme.error)),
                    ],
                  ),
                  if (cross.containsKey(item.id))
                    _CrossPrice(item, cross[item.id], t.net),
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
                              cart.setWeight(item.id,
                                  weightKg: r.weightKg,
                                  labelTotal: r.total,
                                  pricePerKg: r.pricePerKg);
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
                Text(eur(t.net),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                if (t.stickerSaving > 0)
                  Text(eur(t.gross),
                      style: theme.textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () =>
                          cart.setQuantity(item.id, item.quantity - 1),
                    ),
                    Text('${item.quantity}',
                        style: theme.textTheme.titleMedium),
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
        child: Text('−$pct%',
            style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ),
    );
  }
}

/// Prezzo della stessa riga nell'altra catena.
class _CrossPrice extends StatelessWidget {
  const _CrossPrice(this.item, this.quote, this.hereNet);
  final CartItem item;
  final PriceQuote? quote;
  final double hereNet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = item.product.chain.other.label;
    final q = quote;
    if (q == null) {
      return Text('$name: non a listino',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.outline));
    }
    final there = lineTotals(item, quote: q).net;
    final diff = round2(there - hereNet);
    final color = diff < 0
        ? theme.colorScheme.error
        : diff > 0
            ? theme.colorScheme.primary
            : theme.colorScheme.outline;
    final unit = item.isVariableWeight && q.pricePerKg != null
        ? '${eur(q.pricePerKg!)}/${item.product.weightUnit ?? 'kg'}'
        : eur(q.price);
    final sign = diff > 0 ? '+' : '';
    return Text(
      '$name: $unit${q.isPromo ? ' (promo)' : ''}'
      '${diff != 0 ? ' · $sign${eur(diff)}' : ''}',
      style: theme.textTheme.bodySmall?.copyWith(color: color),
    );
  }
}
