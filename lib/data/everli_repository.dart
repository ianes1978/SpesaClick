import 'dart:convert';

import '../domain/chain.dart';
import '../domain/product.dart';
import '../domain/similarity.dart';
import 'database.dart';
import 'everli_api.dart';

class ScoredProduct {
  const ScoredProduct(this.product, this.score, this.readAt);
  final Product product;

  /// Somiglianza 0–1 con il prodotto di riferimento.
  final double score;
  final DateTime readAt;
}

/// Everli con cache di 12 ore per ricerche e prodotti, e abbinamenti
/// EAN → prodotto Everli confermati dall'utente.
class EverliRepository {
  EverliRepository({required this.api, required this.db});

  final EverliApi api;
  final AppDatabase db;

  static const ttl = Duration(hours: 12);
  static const pageSize = 50;

  /// Soglia sotto la quale un candidato non viene proposto.
  static const minScore = 0.5;

  bool _fresh(DateTime t) => DateTime.now().difference(t) < ttl;

  Future<List<EverliStore>> stores() async {
    const key = 'stores';
    final c = await db.everliCached(key);
    if (c != null &&
        DateTime.now().difference(c.readAt) < const Duration(days: 1)) {
      return _decodeStores(c.json);
    }
    final list = await api.storeList();
    await db.putEverli(
      key,
      jsonEncode([
        for (final s in list)
          {
            'id': s.id,
            'name': s.name,
            'address': s.address,
            'type': s.type,
            'brand_details': {'name': s.brandName, 'slug': s.brandSlug},
          },
      ]),
      DateTime.now(),
    );
    return list;
  }

  List<EverliStore> _decodeStores(String json) => (jsonDecode(json) as List)
      .map(EverliStore.fromApi)
      .whereType<EverliStore>()
      .toList();

  /// Una pagina di ricerca in un negozio. Con [filter] tiene solo i
  /// prodotti che contengono tutti i termini cercati (la ricerca di Everli
  /// è "fuzzy" e restituisce sempre qualcosa).
  Future<({List<Product> products, bool hasMore, DateTime readAt})> search(
    int storeId,
    Chain chain,
    String keyword, {
    int page = 1,
    bool filter = true,
  }) async {
    final skip = (page - 1) * pageSize;
    final key = 'search|$storeId|${normalizeText(keyword)}|$skip|$pageSize';
    List<Product> raw;
    DateTime at;
    final c = await db.everliCached(key);
    if (c != null && _fresh(c.readAt)) {
      raw = (jsonDecode(c.json) as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      at = c.readAt;
    } else {
      final r = await api.search(
        keyword,
        {storeId: chain},
        skip: skip,
        take: pageSize,
      );
      raw = r[storeId] ?? const [];
      at = DateTime.now();
      await db.putEverli(
        key,
        jsonEncode(raw.map((p) => p.toJson()).toList()),
        at,
      );
      for (final p in raw) {
        await _putProduct(storeId, p, at);
      }
    }
    final products = filter
        ? raw
              .where(
                (p) => matchesAllTerms(
                  keyword,
                  [p.name, p.brand ?? '', p.packageDescr ?? ''].join(' '),
                ),
              )
              .toList()
        : raw;
    // Il totale non c'è: si va avanti finché la pagina è piena.
    return (products: products, hasMore: raw.length >= pageSize, readAt: at);
  }

  Future<void> _putProduct(int storeId, Product p, DateTime at) => db.putEverli(
    'product|$storeId|${p.productId}',
    jsonEncode(p.toJson()),
    at,
  );

  Future<({Product product, DateTime readAt})?> product(
    int storeId,
    Chain chain,
    int productId,
  ) async {
    final key = 'product|$storeId|$productId';
    final c = await db.everliCached(key);
    if (c != null && _fresh(c.readAt)) {
      return (
        product: Product.fromJson(jsonDecode(c.json) as Map<String, dynamic>),
        readAt: c.readAt,
      );
    }
    final p = await api.product(productId, storeId, chain);
    if (p == null) return null;
    final now = DateTime.now();
    await _putProduct(storeId, p, now);
    return (product: p, readAt: now);
  }

  /// I 3 prodotti più simili a [ref] in un negozio Everli.
  Future<List<ScoredProduct>> equivalents(
    int storeId,
    Chain chain,
    Product ref,
  ) async {
    final keyword = equivalentKeyword(ref);
    if (keyword.isEmpty) return const [];
    final r = await search(storeId, chain, keyword, filter: false);
    final scored =
        [
            for (final p in r.products)
              ScoredProduct(p, similarity(ref, p), r.readAt),
          ].where((s) => s.score >= minScore).toList()
          ..sort((a, b) => b.score.compareTo(a.score));
    return scored.take(3).toList();
  }

  /// `id` Everli abbinato a un codice (valido in tutti i negozi Everli).
  Future<int?> match(String code) => db.everliMatch(code);

  Future<void> setMatch(String code, int? productId) =>
      db.setEverliMatch(code, productId);

  /// `id` Everli contenuto in un codice `everli:<id>` (righe prese da Everli).
  static int? idFromCode(String code) =>
      code.startsWith('everli:') ? int.tryParse(code.substring(7)) : null;
}
