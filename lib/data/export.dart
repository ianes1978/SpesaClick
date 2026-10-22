import 'dart:convert';

import '../domain/cart_item.dart';
import '../domain/cart_math.dart';
import '../domain/product.dart';

String _csvCell(Object? v) {
  if (v == null) return '';
  final s = v is double ? v.toStringAsFixed(2) : v.toString();
  if (s.contains(RegExp('[;"\n\r]'))) return '"${s.replaceAll('"', '""')}"';
  return s;
}

/// CSV con separatore ";" (si apre bene in Excel con impostazioni italiane).
String toCsv(List<String> header, Iterable<List<Object?>> rows) {
  final b = StringBuffer()..writeln(header.map(_csvCell).join(';'));
  for (final r in rows) {
    b.writeln(r.map(_csvCell).join(';'));
  }
  return b.toString();
}

String cartToCsv(List<CartItem> items) => toCsv(
      [
        'catena', 'ean', 'nome', 'marca', 'formato', 'quantita', 'peso_kg',
        'prezzo_unitario', 'prezzo_kg', 'bollino_%', 'totale', 'fonte',
        'letto_il',
      ],
      items.map((i) => [
            i.product.chain.name,
            i.product.barcode,
            i.product.name,
            i.product.brand,
            i.product.packageDescr,
            i.quantity,
            i.weightKg?.toStringAsFixed(3),
            i.quote.price,
            i.effectivePricePerKg,
            i.discountPercent,
            lineTotals(i).net,
            i.quote.source.name,
            i.quote.readAt.toIso8601String(),
          ]),
    );

String cartToJson(List<CartItem> items) =>
    const JsonEncoder.withIndent('  ').convert({
      'esportato': DateTime.now().toIso8601String(),
      'totale': cartTotals(items).total,
      'righe': items.map((i) => i.toJson()).toList(),
    });

String productsToCsv(List<Product> products) => toCsv(
      [
        'catena', 'product_id', 'ean', 'nome', 'marca', 'formato',
        'tipologia', 'prezzo', 'prezzo_pieno', 'prezzo_kg', 'unita',
        'categoria',
      ],
      products.map((p) => [
            p.chain.name,
            p.productId,
            p.barcode,
            p.name,
            p.brand,
            p.packageDescr,
            p.tipologia,
            p.price,
            p.listPrice,
            p.pricePerKg,
            p.weightUnit,
            p.category,
          ]),
    );

String productsToJson(List<Product> products) =>
    jsonEncode(products.map((p) => p.toJson()).toList());
