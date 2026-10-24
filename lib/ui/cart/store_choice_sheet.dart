import 'package:flutter/material.dart';

import '../../data/product_repository.dart';
import '../../domain/price_store.dart';
import '../widgets/format.dart';
import '../widgets/product_image.dart';

/// Il prodotto è in più negozi: quale prezzo usare per la riga?
/// Restituisce l'indice scelto, o null se l'utente annulla.
Future<int?> showStoreChoice(
  BuildContext context,
  List<(PriceStore, LookupResult)> options,
) {
  final cheapest = options
      .map((o) => o.$2.quote.price)
      .reduce((a, b) => a < b ? a : b);
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final p = options.first.$2.product;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: ProductImage(p.thumbUrl, size: 48),
              title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: const Text('Trovato in più negozi: quale prezzo uso?'),
            ),
            const Divider(height: 1),
            for (var i = 0; i < options.length; i++)
              () {
                final (store, r) = options[i];
                final q = r.quote;
                final best = q.price <= cheapest + 0.001;
                final unit = r.product.isVariableWeight && q.pricePerKg != null
                    ? ' · ${eur(q.pricePerKg!)}/${r.product.weightUnit ?? 'kg'}'
                    : '';
                return ListTile(
                  leading: Icon(
                    best ? Icons.star : Icons.store_outlined,
                    color: best ? theme.colorScheme.primary : null,
                  ),
                  title: Text(store.shortLabel),
                  subtitle: Text(
                    '${r.product.brand ?? ''} ${r.product.packageDescr ?? ''}'
                            .trim() +
                        unit,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        eur(q.price),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: best ? FontWeight.bold : null,
                        ),
                      ),
                      if (q.isPromo)
                        Text(
                          eur(q.listPrice!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  onTap: () => Navigator.pop(ctx, i),
                );
              }(),
          ],
        ),
      );
    },
  );
}
