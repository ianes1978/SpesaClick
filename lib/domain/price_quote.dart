import 'package:freezed_annotation/freezed_annotation.dart';

import 'chain.dart';

part 'price_quote.freezed.dart';
part 'price_quote.g.dart';

/// Da dove arriva un prezzo.
enum PriceSource {
  /// Prezzo del punto vendita selezionato (utente collegato).
  store,

  /// Listino online generico (senza login).
  online,

  /// Prezzo stampato sull'etichetta della bilancia.
  label,

  /// Listino scaricato per l'uso offline.
  offline,
}

extension PriceSourceLabel on PriceSource {
  String get badge => switch (this) {
    PriceSource.store => 'prezzo PV',
    PriceSource.online => 'online',
    PriceSource.label => 'etichetta',
    PriceSource.offline => 'offline',
  };
}

@freezed
abstract class PriceQuote with _$PriceQuote {
  const PriceQuote._();

  const factory PriceQuote({
    /// Prezzo di vendita (a pezzo / confezione).
    required double price,

    /// Prezzo pieno, se il prodotto è in promozione.
    double? listPrice,

    /// Prezzo al kg / l.
    double? pricePerKg,
    required PriceSource source,
    required DateTime readAt,

    /// Catena a cui si riferisce il prezzo.
    @Default(Chain.poli) Chain chain,

    /// Punto vendita a cui si riferisce il prezzo (null = online/offline).
    int? storeId,
  }) = _PriceQuote;

  factory PriceQuote.fromJson(Map<String, dynamic> json) =>
      _$PriceQuoteFromJson(json);

  bool get isPromo => listPrice != null && listPrice! > price + 0.001;
}
