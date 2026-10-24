import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/chain.dart';
import '../domain/ean.dart';
import '../domain/price_quote.dart';
import '../domain/product.dart';
import 'api_exceptions.dart';
import 'database.dart';
import 'ebsn_api.dart';

class LookupResult {
  const LookupResult(this.product, this.quote);
  final Product product;
  final PriceQuote quote;
}

class DownloadProgress {
  const DownloadProgress(this.done, this.total, this.items, {this.label});
  final int done;
  final int total;
  final int items;
  final String? label;
  double get fraction => total == 0 ? 0 : done / total;
}

/// Prodotti e prezzi di una catena: cache locale (6 ore), API, listino offline.
class ProductRepository {
  ProductRepository({
    required this.api,
    required this.db,
    required this.currentStoreId,
  });

  final EbsnApi api;
  final AppDatabase db;

  /// Negozio attivo nel carrello DupliClick, null se non collegato
  /// (sempre null per Click&Coop, che ha un unico listino online).
  final int? Function() currentStoreId;

  Chain get chain => api.chain;

  static const cacheTtl = Duration(hours: 6);
  static const onlineKey = 'online';

  /// Raccolte di Click&Coop (prodotti già presenti in altre categorie).
  static const coopCollectionIds = {45294, 46836, 46899};
  static final _collectionName = RegExp(
    r'promozion|cashback|sempre gi',
    caseSensitive: false,
  );

  static String storeKey(int? storeId) => storeId?.toString() ?? onlineKey;

  String get downloadedAtKey => 'catalog_downloaded_at_${chain.name}';

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

    final cached = await db.cachedPrice(chain, key, ean);
    if (cached != null && _fresh(cached.readAt)) {
      return LookupResult(
        cached.product,
        cached.product.quote(source, cached.readAt, storeId: storeId),
      );
    }

    // DupliClick senza sessione: si preferisce il listino scaricato.
    if (storeId == null && api.config.preferOfflineWithoutSession) {
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
      if (e is ApiFormatException) rethrow;
      if (cached != null) {
        return LookupResult(
          cached.product,
          cached.product.quote(source, cached.readAt, storeId: storeId),
        );
      }
      final off = await _offline(ean);
      if (off != null) return off;
      rethrow;
    }
  }

  Future<LookupResult?> _offline(String ean) async {
    final row = await db.catalogProduct(chain, ean);
    if (row == null) return null;
    return LookupResult(
      row.product,
      row.product.quote(PriceSource.offline, row.downloadedAt),
    );
  }

  /// Prezzo già in cache (e fresco) per un negozio.
  Future<PriceQuote?> cachedQuote(int storeId, String ean) async {
    final c = await db.cachedPrice(chain, storeKey(storeId), ean);
    if (c == null || !_fresh(c.readAt)) return null;
    return c.product.quote(PriceSource.store, c.readAt, storeId: storeId);
  }

  /// Prodotto in cache per un negozio (anche se non più fresco).
  Future<Product?> cachedProduct(int storeId, String ean) async =>
      (await db.cachedPrice(chain, storeKey(storeId), ean))?.product;

  /// Legge il prezzo dal server per il negozio attualmente selezionato nel
  /// carrello DupliClick, che deve essere [storeId].
  Future<PriceQuote?> fetchStoreQuote(int storeId, String ean) async {
    final p = await api.productByBarcode(ean);
    if (p == null) return null;
    final now = DateTime.now();
    await db.putPrice(storeKey(storeId), p, now);
    return p.quote(PriceSource.store, now, storeId: storeId);
  }

  Future<void> _cacheAll(List<Product> products) async {
    final key = storeKey(currentStoreId());
    final now = DateTime.now();
    for (final p in products) {
      await db.putPrice(key, p, now);
    }
  }

  /// Ricerca nel catalogo; senza rete usa il listino offline.
  Future<({ProductPage page, bool offline})> search(
    String q, {
    int page = 1,
    int pageSize = 24,
  }) async {
    try {
      final res = await api.searchProducts(q, page: page, pageSize: pageSize);
      await _cacheAll(res.products);
      return (page: res, offline: false);
    } on NetworkException {
      final list = await db.searchCatalog(
        chain,
        q,
        limit: pageSize,
        offset: (page - 1) * pageSize,
      );
      if (list.isEmpty && page == 1 && await db.catalogCount(chain) == 0) {
        rethrow;
      }
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

  /// Prodotti di una categoria (online).
  Future<ProductPage> byCategory(
    int categoryId, {
    int page = 1,
    int pageSize = 24,
  }) async {
    final res = await api.productsByCategory(
      categoryId,
      page: page,
      pageSize: pageSize,
    );
    await _cacheAll(res.products);
    return res;
  }

  /// Categorie merceologiche, senza le raccolte (promozioni, cashback…).
  Future<List<EbsnCategory>> categories({
    bool includeCollections = false,
  }) async {
    final all = await api.categories();
    if (includeCollections) return all;
    return all
        .where(
          (c) =>
              !coopCollectionIds.contains(c.id) &&
              !_collectionName.hasMatch(c.name),
        )
        .toList();
  }

  /// Scarica l'intero listino per l'uso offline.
  Stream<DownloadProgress> downloadCatalog({bool Function()? cancelled}) =>
      api.config.emptyQueryListsAll
      ? _downloadAll(cancelled)
      : _downloadByCategory(cancelled);

  /// DupliClick: `q=` vuoto, 100 per pagina, una richiesta ogni 350 ms.
  Stream<DownloadProgress> _downloadAll(bool Function()? cancelled) async* {
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
        await db.clearCatalog(chain);
        first = false;
      }
      tot = res.totPages;
      items += res.products.length;
      await db.putCatalog(res.products, start);
      yield DownloadProgress(page, tot, items);
      page++;
    }
    await db.setValue(downloadedAtKey, start.toIso8601String());
  }

  /// Click&Coop: `q` vuoto non è ammesso, si scorrono le categorie
  /// merceologiche (80 per pagina; se una pagina fallisce sempre, la si
  /// riprende in due pagine da 40). I doppioni spariscono perché la chiave
  /// del listino è `productId`.
  Stream<DownloadProgress> _downloadByCategory(
    bool Function()? cancelled,
  ) async* {
    const size = 80, smallSize = 40;
    final start = DateTime.now();
    final cats = await categories();
    if (cats.isEmpty) throw const ApiFormatException('nessuna categoria');
    await db.clearCatalog(chain);
    final seen = <int>{};
    for (var ci = 0; ci < cats.length; ci++) {
      final cat = cats[ci];
      var page = 1, tot = 1;
      while (page <= tot) {
        if (cancelled?.call() ?? false) return;
        List<Product> products;
        try {
          final res = await api.productsByCategory(
            cat.id,
            page: page,
            pageSize: size,
          );
          tot = res.totPages;
          products = res.products;
        } on ApiServerException catch (e) {
          debugPrint('Pagina $page di ${cat.name} fallita ($e): riprovo da 40');
          products = [];
          for (final p in [page * 2 - 1, page * 2]) {
            final res = await api.productsByCategory(
              cat.id,
              page: p,
              pageSize: smallSize,
            );
            products.addAll(res.products);
            tot = (res.totPages + 1) ~/ 2;
          }
        }
        await db.putCatalog(products, start);
        seen.addAll(products.map((p) => p.productId));
        yield DownloadProgress(
          ci,
          cats.length,
          seen.length,
          label: '${cat.name} · pagina $page/$tot',
        );
        page++;
      }
    }
    yield DownloadProgress(cats.length, cats.length, seen.length);
    await db.setValue(downloadedAtKey, start.toIso8601String());
  }
}
