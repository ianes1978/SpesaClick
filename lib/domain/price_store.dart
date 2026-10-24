import 'package:freezed_annotation/freezed_annotation.dart';

import 'chain.dart';
import 'price_quote.dart';

part 'price_store.freezed.dart';
part 'price_store.g.dart';

/// Un "negozio" da cui leggere i prezzi: un punto vendita Poli (prezzi del
/// negozio, con login) oppure un listino online (DupliClick senza login,
/// Click&Coop, che ha un unico listino per tutti i punti di ritiro).
@freezed
abstract class PriceStore with _$PriceStore {
  const PriceStore._();

  const factory PriceStore({
    required Chain chain,

    /// `addressId` del punto vendita; null = listino online della catena.
    int? storeId,
    required String name,
    String? address,
  }) = _PriceStore;

  factory PriceStore.fromJson(Map<String, dynamic> json) =>
      _$PriceStoreFromJson(json);

  static String idFor(Chain chain, int? storeId) =>
      '${chain.name}:${storeId ?? 'online'}';

  /// Negozio da cui arriva un prezzo.
  static String idOfQuote(PriceQuote q) => idFor(q.chain, q.storeId);

  String get id => idFor(chain, storeId);

  /// Etichetta corta per chip e righe di confronto.
  String get shortLabel => chain.isManual
      ? chain.label
      : isOnline
      ? '${chain.label} online'
      : name.replaceFirst(RegExp(r'^Poli · '), '');
  bool get isOnline => storeId == null;

  static const poliOnline = PriceStore(
    chain: Chain.poli,
    name: 'Poli · listino online DupliClick',
  );
  static const aldiManual = PriceStore(
    chain: Chain.aldi,
    name: 'Aldi · prezzi inseriti a mano',
  );

  static const coopOnline = PriceStore(
    chain: Chain.coop,
    name: 'Coop · listino online Click&Coop',
  );
}
