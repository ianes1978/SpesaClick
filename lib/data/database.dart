import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/cart_item.dart';
import '../domain/product.dart';

part 'database.g.dart';

/// Prezzi letti per (negozio, EAN). `storeKey` = id negozio o "online".
class PriceCache extends Table {
  TextColumn get storeKey => text()();
  TextColumn get barcode => text()();
  TextColumn get productJson => text()();
  DateTimeColumn get readAt => dateTime()();

  @override
  Set<Column> get primaryKey => {storeKey, barcode};
}

/// Listino completo scaricato per l'uso offline.
class Catalog extends Table {
  TextColumn get barcode => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get productJson => text()();
  DateTimeColumn get downloadedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {barcode};
}

class CartLines extends Table {
  TextColumn get id => text()();
  IntColumn get position => integer()();
  TextColumn get json => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class KeyValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class CachedPrice {
  const CachedPrice(this.product, this.readAt);
  final Product product;
  final DateTime readAt;
}

@DriftDatabase(tables: [PriceCache, Catalog, CartLines, KeyValues])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'spesa_trento'));

  @override
  int get schemaVersion => 1;

  // ---- cache prezzi ------------------------------------------------------

  Future<CachedPrice?> cachedPrice(String storeKey, String barcode) async {
    final row = await (select(priceCache)
          ..where((t) => t.storeKey.equals(storeKey) & t.barcode.equals(barcode)))
        .getSingleOrNull();
    if (row == null) return null;
    return CachedPrice(
      Product.fromJson(jsonDecode(row.productJson) as Map<String, dynamic>),
      row.readAt,
    );
  }

  Future<void> putPrice(String storeKey, Product p, DateTime readAt) =>
      into(priceCache).insertOnConflictUpdate(PriceCacheCompanion.insert(
        storeKey: storeKey,
        barcode: p.barcode,
        productJson: jsonEncode(p.toJson()),
        readAt: readAt,
      ));

  // ---- listino offline ---------------------------------------------------

  Future<void> putCatalog(List<Product> products, DateTime at) =>
      batch((b) {
        b.insertAllOnConflictUpdate(
          catalog,
          products.map((p) => CatalogCompanion.insert(
                barcode: p.barcode,
                name: p.name.toLowerCase(),
                brand: Value(p.brand?.toLowerCase()),
                category: Value(p.category),
                productJson: jsonEncode(p.toJson()),
                downloadedAt: at,
              )),
        );
      });

  Future<void> clearCatalog() => delete(catalog).go();

  Future<({Product product, DateTime downloadedAt})?> catalogProduct(
      String barcode) async {
    final row = await (select(catalog)..where((t) => t.barcode.equals(barcode)))
        .getSingleOrNull();
    if (row == null) return null;
    return (
      product: Product.fromJson(
          jsonDecode(row.productJson) as Map<String, dynamic>),
      downloadedAt: row.downloadedAt,
    );
  }

  Future<List<Product>> searchCatalog(String q,
      {int limit = 24, int offset = 0}) async {
    final words = q
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final query = select(catalog);
    for (final w in words) {
      query.where((t) => t.name.contains(w) | t.brand.contains(w));
    }
    query
      ..orderBy([(t) => OrderingTerm.asc(t.name)])
      ..limit(limit, offset: offset);
    final rows = await query.get();
    return rows
        .map((r) =>
            Product.fromJson(jsonDecode(r.productJson) as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> allCatalog() async {
    final rows = await (select(catalog)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows
        .map((r) =>
            Product.fromJson(jsonDecode(r.productJson) as Map<String, dynamic>))
        .toList();
  }

  Future<int> catalogCount() async {
    final c = catalog.barcode.count();
    final row = await (selectOnly(catalog)..addColumns([c])).getSingle();
    return row.read(c) ?? 0;
  }

  // ---- carrello -----------------------------------------------------------

  Future<List<CartItem>> loadCart() async {
    final rows = await (select(cartLines)
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    final out = <CartItem>[];
    for (final r in rows) {
      try {
        out.add(
            CartItem.fromJson(jsonDecode(r.json) as Map<String, dynamic>));
      } catch (_) {
        // Riga salvata con un formato vecchio: la ignoriamo.
      }
    }
    return out;
  }

  Future<void> saveCart(List<CartItem> items) => transaction(() async {
        await delete(cartLines).go();
        await batch((b) {
          for (var i = 0; i < items.length; i++) {
            b.insert(
              cartLines,
              CartLinesCompanion.insert(
                id: items[i].id,
                position: i,
                json: jsonEncode(items[i].toJson()),
              ),
            );
          }
        });
      });

  // ---- impostazioni -------------------------------------------------------

  Future<String?> getValue(String key) async =>
      (await (select(keyValues)..where((t) => t.key.equals(key)))
              .getSingleOrNull())
          ?.value;

  Future<void> setValue(String key, String? value) async {
    if (value == null) {
      await (delete(keyValues)..where((t) => t.key.equals(key))).go();
    } else {
      await into(keyValues).insertOnConflictUpdate(
          KeyValuesCompanion.insert(key: key, value: value));
    }
  }
}
