import 'package:freezed_annotation/freezed_annotation.dart';

import 'price_quote.dart';
import 'product.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
abstract class CartItem with _$CartItem {
  const CartItem._();

  const factory CartItem({
    /// Chiave della riga: EAN del prodotto, o codice completo dell'etichetta.
    required String id,
    required Product product,
    required PriceQuote quote,
    @Default(1) int quantity,

    /// Peso in kg per i prodotti a peso variabile.
    double? weightKg,

    /// Totale stampato sull'etichetta (o inserito a mano).
    double? labelTotal,

    /// Prezzo al kg corretto a mano dall'utente.
    double? pricePerKgOverride,

    /// Bollino scadenza: 0, 30 o 50.
    @Default(0) int discountPercent,
    required DateTime addedAt,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  bool get isVariableWeight =>
      product.isVariableWeight || quote.source == PriceSource.label;

  double? get effectivePricePerKg => pricePerKgOverride ?? quote.pricePerKg;
}
