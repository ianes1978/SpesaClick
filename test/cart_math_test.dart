import 'package:flutter_test/flutter_test.dart';
import 'package:spesa_trento/domain/cart_item.dart';
import 'package:spesa_trento/domain/cart_math.dart';
import 'package:spesa_trento/domain/ean.dart';
import 'package:spesa_trento/domain/price_quote.dart';
import 'package:spesa_trento/domain/product.dart';

final _t = DateTime(2026, 10, 21);

Product product({
  String barcode = '8007049920131',
  double price = 1.25,
  double? listPrice,
  double? ppk,
  String tipologia = 'Pezzo',
}) =>
    Product(
      productId: 1,
      barcode: barcode,
      name: 'Prodotto',
      price: price,
      listPrice: listPrice,
      pricePerKg: ppk,
      tipologia: tipologia,
    );

CartItem item(Product p,
        {int qty = 1,
        int pct = 0,
        double? weight,
        double? label,
        PriceSource source = PriceSource.store,
        double? price}) =>
    CartItem(
      id: p.barcode,
      product: p,
      quote: PriceQuote(
        price: price ?? p.price,
        listPrice: p.listPrice,
        pricePerKg: p.pricePerKg,
        source: source,
        readAt: _t,
      ),
      quantity: qty,
      discountPercent: pct,
      weightKg: weight,
      labelTotal: label,
      addedAt: _t,
    );

void main() {
  test('pezzi: prezzo × quantità', () {
    final t = cartTotals([item(product(), qty: 3)]);
    expect(t.total, 3.75);
    expect(t.pieces, 3);
    expect(t.saving, 0);
  });

  test('bollini −30% e −50%', () {
    final a = item(product(price: 2.00), qty: 2, pct: 30); // 4.00 → 2.80
    final b = item(product(barcode: '2', price: 3.99), pct: 50); // 3.99 → 2.00
    final la = lineTotals(a);
    expect(la.gross, 4.00);
    expect(la.stickerSaving, 1.20);
    expect(la.net, 2.80);
    final lb = lineTotals(b);
    expect(lb.stickerSaving, 2.00);
    expect(lb.net, 1.99);
    final t = cartTotals([a, b]);
    expect(t.total, 4.79);
    expect(t.stickerSaving, 3.20);
    expect(t.pieces, 3);
  });

  test('promo: risparmio rispetto al prezzo pieno', () {
    final t = cartTotals([item(product(price: 1.99, listPrice: 2.49), qty: 2)]);
    expect(t.total, 3.98);
    expect(t.promoSaving, 1.00);
    expect(t.saving, 1.00);
  });

  test('promo + bollino si sommano nel risparmio', () {
    final t = cartTotals(
        [item(product(price: 2.00, listPrice: 3.00), pct: 50)]);
    expect(t.total, 1.00);
    expect(t.stickerSaving, 1.00);
    expect(t.promoSaving, 1.00);
    expect(t.saving, 2.00);
  });

  test('peso variabile: prezzo al kg × peso', () {
    final p = product(tipologia: 'Sfuso', price: 5, ppk: 19.90);
    final l = lineTotals(item(p, weight: 0.352));
    expect(l.gross, 7.00); // 6.9848 → 7.00
  });

  test('peso variabile senza peso: usa il prezzo a pezzo', () {
    final p = product(tipologia: 'Confezione', price: 5, ppk: 19.90);
    expect(lineTotals(item(p)).gross, 5.0);
  });

  test('prezzo al kg corretto a mano', () {
    final p = product(tipologia: 'Sfuso', price: 5, ppk: 20);
    final it = item(p, weight: 0.5).copyWith(pricePerKgOverride: 18);
    expect(lineTotals(it).gross, 9.0);
  });

  test('etichetta bilancia: il prezzo stampato è il totale', () {
    final label = ScaleLabel.tryParse('2060120012343')!;
    final p = product(
        barcode: label.lookupBarcode, tipologia: 'Sfuso', price: 0, ppk: 19.90);
    final it = item(p,
        source: PriceSource.label,
        price: label.total,
        label: label.total,
        weight: label.total / 19.90);
    expect(it.isVariableWeight, isTrue);
    expect(it.weightKg, closeTo(0.620, 0.001));
    final l = lineTotals(it);
    expect(l.gross, 12.34);
    expect(lineTotals(it.copyWith(discountPercent: 30)).net, 8.64);
  });

  test("totale nell'altro negozio", () {
    final a = item(product(barcode: 'A', price: 2.00), qty: 2);
    final b = item(product(barcode: 'B', price: 1.00));
    final c = item(product(barcode: 'C', tipologia: 'Sfuso', ppk: 10),
        weight: 0.5);
    final other = {
      'A': PriceQuote(price: 1.80, source: PriceSource.store, readAt: _t),
      'C': PriceQuote(
          price: 0, pricePerKg: 12, source: PriceSource.store, readAt: _t),
    };
    final o = otherStoreTotal([a, b, c], other);
    // A 3.60 + B 1.00 (mancante: prezzo attuale) + C 6.00
    expect(o.total, 10.60);
    expect(o.missing, 1);
    expect(cartTotals([a, b, c]).total, 10.00);
  });
}
