import 'dart:convert';

import '../domain/price_quote.dart';
import '../domain/store.dart';
import 'api_exceptions.dart';
import 'database.dart';
import 'ebsn_api.dart';
import 'product_repository.dart';

/// Punti vendita, cambio negozio e confronto prezzi.
class StoreRepository {
  StoreRepository({
    required this.api,
    required this.db,
    required this.products,
  });

  final EbsnApi api;
  final AppDatabase db;
  final ProductRepository products;

  static const _kStores = 'stores_tn';
  static const _kStoresAt = 'stores_tn_at';

  /// Negozi della provincia di Trento (cache di un giorno).
  Future<List<Store>> trentoStores({bool refresh = false}) async {
    final at = DateTime.tryParse(await db.getValue(_kStoresAt) ?? '');
    final cached = await db.getValue(_kStores);
    if (!refresh &&
        cached != null &&
        at != null &&
        DateTime.now().difference(at) < const Duration(days: 1)) {
      return _decode(cached);
    }
    try {
      final all = await api.deliveryServiceList();
      final tn =
          all.where((s) => (s.province ?? '').toUpperCase() == 'TN').toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      final result = tn.isEmpty ? kKnownTrentoStores : tn;
      await db.setValue(
        _kStores,
        jsonEncode(result.map((s) => s.toJson()).toList()),
      );
      await db.setValue(_kStoresAt, DateTime.now().toIso8601String());
      return result;
    } on ApiException {
      return cached != null ? _decode(cached) : kKnownTrentoStores;
    }
  }

  List<Store> _decode(String s) => (jsonDecode(s) as List)
      .map((e) => Store.fromJson(e as Map<String, dynamic>))
      .toList();

  Future<CartAddress?> current() => api.cartAddress();

  /// Cambia negozio e verifica con `cart/view`.
  Future<CartAddress?> select(int addressId) async {
    final cur = await api.cartAddress();
    await api.selectAddress(
      addressId,
      // NB: il prompt indica address_type=work per il ritiro in negozio.
      addressType: 'work',
      deliveryServiceId: cur?.deliveryServiceId ?? 1,
    );
    final after = await api.cartAddress();
    if (after?.addressId != addressId) {
      throw ApiServerException(
        'Il negozio non risulta cambiato (attivo: ${after?.addressName ?? '?'})',
      );
    }
    return after;
  }

  /// Prezzi già in cache per un negozio, per barcode.
  Future<Map<String, PriceQuote>> cachedQuotes(
    int storeId,
    Iterable<String> eans,
  ) async {
    final out = <String, PriceQuote>{};
    for (final e in eans.toSet()) {
      final q = await products.cachedQuote(storeId, e);
      if (q != null) out[e] = q;
    }
    return out;
  }

  /// Legge i prezzi di [eans] su ognuno di [storeIds]. Cambia il negozio del
  /// carrello DupliClick solo se servono prezzi non in cache e RIPRISTINA
  /// SEMPRE il negozio originale alla fine (anche in caso d'errore).
  Future<Map<int, Map<String, PriceQuote>>> compare(
    Iterable<String> eans,
    List<int> storeIds, {
    void Function(String message)? onProgress,
  }) async {
    final unique = eans.toSet().toList();
    final result = <int, Map<String, PriceQuote>>{};
    final missing = <int, List<String>>{};
    for (final s in storeIds) {
      result[s] = await cachedQuotes(s, unique);
      missing[s] = unique.where((e) => !result[s]!.containsKey(e)).toList();
    }
    if (missing.values.every((m) => m.isEmpty)) return result;

    final orig = await api.cartAddress();
    if (orig == null) {
      throw const ApiFormatException(
        'negozio attivo non leggibile da cart/view',
      );
    }
    var active = orig.addressId;
    final type = orig.addressType ?? 'work';
    final dsid = orig.deliveryServiceId ?? 1;
    try {
      // Prima il negozio già attivo, così si evita un cambio.
      final order = [...storeIds]
        ..sort((a, b) => a == active ? -1 : (b == active ? 1 : 0));
      for (final s in order) {
        final todo = missing[s]!;
        if (todo.isEmpty) continue;
        if (active != s) {
          onProgress?.call('Passo al negozio $s…');
          await api.selectAddress(
            s,
            addressType: type,
            deliveryServiceId: dsid,
          );
          active = s;
        }
        for (var i = 0; i < todo.length; i++) {
          onProgress?.call('Negozio $s: ${i + 1}/${todo.length}');
          final q = await products.fetchStoreQuote(s, todo[i]);
          if (q != null) result[s]![todo[i]] = q;
        }
      }
    } finally {
      if (active != orig.addressId) {
        onProgress?.call('Ripristino il negozio originale…');
        await api.selectAddress(
          orig.addressId,
          addressType: type,
          deliveryServiceId: dsid,
        );
      }
    }
    final check = await api.cartAddress();
    if (check?.addressId != orig.addressId) {
      throw ApiServerException(
        'ATTENZIONE: il negozio originale (${orig.addressName}) non è stato '
        'ripristinato. Controlla su dupliclick.it.',
      );
    }
    return result;
  }
}
