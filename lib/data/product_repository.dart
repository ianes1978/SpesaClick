import 'dart:async';

import '../domain/ean.dart';
import '../domain/price_quote.dart';
import '../domain/product.dart';
import 'api_exceptions.dart';
import 'database.dart';
import 'dupliclick_api.dart';

class LookupResult {
  const LookupResult(this.product, this.quote);
  final Product product;
  final PriceQuote quote;
}

class DownloadProgress {
  const DownloadProgress(this.page, this.totPages, this.items);
  final int page;
  final int totPages;
  final int items;
  double get fraction => totPages == 0 ? 0 : page / totPages;
}

/// Prodotti e prezzi: cache locale (6 ore), API, listino offline.
class ProductRepository {
  ProductRepository({
    required this.api,
    required this.db,
    required this.currentStoreId,
  });

  final DupliclickApi api;
  final AppDatabase db;

  /// Negozio attivo nel carrello DupliClick, null se non collegato.
  final int? Function() currentStoreId;

  static const cacheTtl = Duration(hours: 6);
  static const onlineKey = 'online';

  static String storeKey(int? storeId) => storeId?.toString() ?? onlineKey;

  bool _fresh(DateTime t) => DateTime.now().difference(t) < cacheTtl;

  /// Cerca un codice scansionato provando le varianti (UPC-A/UPC-E → EAN-13).
  Future<LookupResult?> lookup(String code) async {
    for (final c in barcodeCandidates(code)) {
      final r = await _lookupOne(c);
      if (r != null) return r;
    }
    return null;
  }

  Future<LookupResult?> _lookupOne(String ean) async {
    final storeId = currentStoreId();
    final key = storeKey(storeId);
    final source = storeId != null ? PriceSource.store : PriceSource.online;

    final cached = await db.cachedPrice(key, ean);
    if (cached != null && _fresh(cached.readAt)) {
      return LookupResult(cached.product,
          cached.product.quote(source, cached.readAt, storeId: storeId));
    }

    // Senza sessione si preferisce il listino scaricato (nessuna chiamata).
    if (storeId == null) {
      final off = await _offline(ean);
      if (off != null) return off;
    }

    try {
      final p = await api.productByBarcode(ean);
      if (p == null) return null;
      final now = DateTime.now();
      await db.putPrice(key, p, now);
      return LookupResult(p, p.quote(source, now, storeId: storeId));
    } on ApiException catch (e) {
      if (e is! NetworkException && e is! SessionExpiredException) rethrow;
      if (cached != null) {
        return LookupResult(cached.product,
            cached.product.quote(source, cached.readAt, storeId: storeId));
      }
      final off = await _offline(ean);
      if (off != null) return off;
      rethrow;
    }
  }

  Future<LookupResult?> _offline(String ean) async {
    final row = await db.catalogProduct(ean);
    if (row == null) return null;
    return LookupResult(
        row.product, row.product.quote(PriceSource.offline, row.downloadedAt));
  }

  /// Prezzo già in cache (e fresco) per un negozio.
  Future<PriceQuote?> cachedQuote(int storeId, String ean) async {
    final c = await db.cachedPrice(storeKey(storeId), ean);
    if (c == null || !_fresh(c.readAt)) return null;
    return c.product.quote(PriceSource.store, c.readAt, storeId: storeId);
  }

  /// Legge il prezzo dal server per il negozio attualmente selezionato nel
  /// carrello DupliClick, che deve essere [storeId].
  Future<PriceQuote?> fetchStoreQuote(int storeId, String ean) async {
    final p = await api.productByBarcode(ean);
    if (p == null) return null;
    final now = DateTime.now();
    await db.putPrice(storeKey(storeId), p, now);
    return p.quote(PriceSource.store, now, storeId: storeId);
  }

  /// Ricerca nel catalogo; senza rete usa il listino offline.
  Future<({ProductPage page, bool offline})> search(String q,
      {int page = 1, int pageSize = 24}) async {
    try {
      final res = await api.searchProducts(q, page: page, pageSize: pageSize);
      final key = storeKey(currentStoreId());
      final now = DateTime.now();
      for (final p in res.products) {
        await db.putPrice(key, p, now);
      }
      return (page: res, offline: false);
    } on NetworkException {
      final list = await db.searchCatalog(q,
          limit: pageSize, offset: (page - 1) * pageSize);
      if (list.isEmpty && page == 1 && await db.catalogCount() == 0) rethrow;
      return (
        page: ProductPage(
          products: list,
          page: page,
          totPages: list.length == pageSize ? page + 1 : page,
          totItems: list.length,
        ),
        offline: true,
      );
    }
  }

  /// Scarica l'intero listino (100 per pagina, una richiesta ogni 350 ms).
  Stream<DownloadProgress> downloadCatalog({
    bool Function()? cancelled,
  }) async* {
    final start = DateTime.now();
    var page = 1, tot = 1, items = 0;
    var first = true;
    while (page <= tot) {
      if (cancelled?.call() ?? false) return;
      if (!first) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
      }
      final res = await api.searchProducts('', page: page, pageSize: 100);
      if (first) {
        await db.clearCatalog();
        first = false;
      }
      tot = res.totPages;
      items += res.products.length;
      await db.putCatalog(res.products, start);
      yield DownloadProgress(page, tot, items);
      page++;
    }
    await db.setValue('catalog_downloaded_at', start.toIso8601String());
  }
}
