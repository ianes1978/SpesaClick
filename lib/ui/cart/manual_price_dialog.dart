import 'package:flutter/material.dart';

import '../../domain/cart_item.dart';
import '../../domain/price_store.dart';
import '../widgets/format.dart';

class ManualPrice {
  const ManualPrice(this.price, this.pricePerKg);

  /// null = togli il prezzo.
  final double? price;
  final double? pricePerKg;
}

/// Prezzo letto a scaffale o sullo scontrino per un negozio senza listino
/// online (Aldi). Per gli articoli a peso si chiede anche il prezzo al kg.
Future<ManualPrice?> showManualPriceDialog(
  BuildContext context,
  CartItem item,
  PriceStore store, {
  double? current,
  double? currentPerKg,
}) {
  final price = TextEditingController(
    text: current?.toStringAsFixed(2).replaceAll('.', ',') ?? '',
  );
  final perKg = TextEditingController(
    text: currentPerKg?.toStringAsFixed(2).replaceAll('.', ',') ?? '',
  );
  final weighted = item.isVariableWeight;
  final unit = item.product.weightUnit ?? 'kg';
  return showDialog<ManualPrice>(
    context: context,
    builder: (ctx) {
      String? error;
      return StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Prezzo ${store.shortLabel}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Scrivi il prezzo letto a scaffale o sullo scontrino: '
                "l'app lo ricorda per le prossime spese.",
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: price,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: weighted
                      ? 'Prezzo della confezione (€)'
                      : 'Prezzo (€)',
                  prefixIcon: const Icon(Icons.euro),
                  errorText: error,
                ),
              ),
              if (weighted) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: perKg,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Prezzo al $unit (€)',
                    prefixIcon: const Icon(Icons.scale),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (current != null)
              TextButton(
                onPressed: () =>
                    Navigator.pop(ctx, const ManualPrice(null, null)),
                child: const Text('Togli prezzo'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () {
                final ppk = parseDecimal(perKg.text);
                var p = parseDecimal(price.text);
                // Per gli sfusi basta il prezzo al kg.
                if (p == null && weighted && ppk != null) p = ppk;
                if (p == null || p < 0) {
                  setState(() => error = 'Inserisci un prezzo valido');
                  return;
                }
                Navigator.pop(ctx, ManualPrice(p, ppk));
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      );
    },
  );
}
