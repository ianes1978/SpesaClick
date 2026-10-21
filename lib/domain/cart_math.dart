import 'cart_item.dart';
import 'price_quote.dart';

double round2(double v) => (v * 100).roundToDouble() / 100;

class LineTotals {
  const LineTotals({
    required this.gross,
    required this.stickerSaving,
    required this.promoSaving,
  });

  /// Importo prima del bollino.
  final double gross;

  /// Sconto del bollino scadenza.
  final double stickerSaving;

  /// Risparmio rispetto al prezzo pieno (promozione).
  final double promoSaving;

  double get net => round2(gross - stickerSaving);
}

/// Calcola l'importo di una riga. Con [quote] si usa il prezzo di un altro
/// negozio, mantenendo quantità, peso e bollino della riga.
LineTotals lineTotals(CartItem item, {PriceQuote? quote}) {
  final q = quote ?? item.quote;
  final useOther = quote != null;
  double gross;
  if (item.isVariableWeight) {
    final ppk = useOther ? q.pricePerKg : item.effectivePricePerKg;
    final w = item.weightKg;
    if (!useOther && item.labelTotal != null) {
      gross = item.labelTotal! * item.quantity;
    } else if (ppk != null && w != null) {
      gross = round2(ppk * w) * item.quantity;
    } else {
      gross = q.price * item.quantity;
    }
  } else {
    gross = q.price * item.quantity;
  }
  gross = round2(gross);

  final sticker = round2(gross * item.discountPercent / 100);
  var promo = 0.0;
  if (q.isPromo && q.price > 0) {
    promo = round2(gross * (q.listPrice! / q.price - 1));
  }
  return LineTotals(gross: gross, stickerSaving: sticker, promoSaving: promo);
}

class CartTotals {
  const CartTotals({
    required this.total,
    required this.pieces,
    required this.stickerSaving,
    required this.promoSaving,
  });

  final double total;
  final int pieces;
  final double stickerSaving;
  final double promoSaving;

  double get saving => round2(stickerSaving + promoSaving);

  static const empty =
      CartTotals(total: 0, pieces: 0, stickerSaving: 0, promoSaving: 0);
}

CartTotals cartTotals(Iterable<CartItem> items) {
  var total = 0.0, sticker = 0.0, promo = 0.0;
  var pieces = 0;
  for (final it in items) {
    final t = lineTotals(it);
    total += t.net;
    sticker += t.stickerSaving;
    promo += t.promoSaving;
    pieces += it.quantity;
  }
  return CartTotals(
    total: round2(total),
    pieces: pieces,
    stickerSaving: round2(sticker),
    promoSaving: round2(promo),
  );
}

class OtherStoreTotal {
  const OtherStoreTotal({required this.total, required this.missing});

  final double total;

  /// Righe senza prezzo nell'altro negozio (conteggiate col prezzo attuale).
  final int missing;
}

/// Totale del carrello nell'altro negozio. [quotes] è indicizzato per
/// barcode del prodotto (`item.product.barcode`).
OtherStoreTotal otherStoreTotal(
    Iterable<CartItem> items, Map<String, PriceQuote> quotes) {
  var total = 0.0;
  var missing = 0;
  for (final it in items) {
    final q = quotes[it.product.barcode];
    if (q == null) missing++;
    total += lineTotals(it, quote: q).net;
  }
  return OtherStoreTotal(total: round2(total), missing: missing);
}
