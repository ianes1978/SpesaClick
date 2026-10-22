import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/cart_item.dart';
import '../domain/chain.dart';
import '../domain/product.dart';

part 'database.g.dart';

/// Prezzi letti per (catena, negozio, EAN). `storeKey` = id negozio o "online".
class PriceCache extends Table {
  TextColumn get chain => text()();
  TextColumn get storeKey => text()();
  TextColumn get barcode => text()();
  TextColumn get productJson => text()();
  DateTimeColumn get readAt => dateTime()();

  @override
  Set<Column> get primaryKey => {chain, storeKey, barcode};
}

/// Listino completo scaricato per l'uso offline. La chiave è `productId`:
/// su Click&Coop più sfusi condividono lo stesso codice interno.
class Catalog extends Table {
  TextColumn get chain => text()();
  IntColumn get productId => integer()();
  TextColumn get barcode => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get productJson => text()();
  DateTimeColumn get downloadedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {chain, productId};
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Cache e listino offline: si possono riscaricare.
            await m.deleteTable('price_cache');
            await m.deleteTable('catalog');
            await m.createTable(priceCache);
            await m.createTable(catalog);
          }
        },
      );

  Product _decode(String json) =>
      Product.fromJson(jsonDecode(json) as Map<String, dynamic>);

  // ---- cache prezzi ------------------------------------------------------

  Future<CachedPrice?> cachedPrice(
      Chain chain, String storeKey, String barcode) async {
    final row = await (select(priceCache)
          ..where((t) =>
              t.chain.equals(chain.name) &
              t.storeKey.equals(storeKey) &
              t.barcode.equals(barcode)))
        .getSingleOrNull();
    if (row == null) return null;
    return CachedPrice(_decode(row.productJson), row.readAt);
  }

  Future<void> putPrice(String storeKey, Product p, DateTime readAt) =>
      into(priceCache).insertOnConflictUpdate(PriceCacheCompanion.insert(
        chain: p.chain.name,
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
                chain: p.chain.name,
                productId: p.productId,
                barcode: p.barcode,
                name: p.name.toLowerCase(),
                brand: Value(p.brand?.toLowerCase()),
                category: Value(p.category),
                productJson: jsonEncode(p.toJson()),
                downloadedAt: at,
              )),
        );
      });

  Future<void> clearCatalog(Chain chain) =>
      (delete(catalog)..where((t) => t.chain.equals(chain.name))).go();

  Future<({Product product, DateTime downloadedAt})?> catalogProduct(
      Chain chain, String barcode) async {
    final row = await (select(catalog)
          ..where((t) => t.chain.equals(chain.name) & t.barcode.equals(barcode))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return (product: _decode(row.productJson), downloadedAt: row.downloadedAt);
  }

  Future<List<Product>> searchCatalog(Chain chain, String q,
      {int limit = 24, int offset = 0}) async {
    final words = q
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final query = select(catalog)..where((t) => t.chain.equals(chain.name));
    for (final w in words) {
      query.where((t) => t.name.contains(w) | t.brand.contains(w));
    }
    query
      ..orderBy([(t) => OrderingTerm.asc(t.name)])
      ..limit(limit, offset: offset);
    final rows = await query.get();
    return rows.map((r) => _decode(r.productJson)).toList();
  }

  Future<List<Product>> allCatalog([Chain? chain]) async {
    final q = select(catalog)
      ..orderBy([(t) => OrderingTerm.asc(t.chain), (t) => OrderingTerm.asc(t.name)]);
    if (chain != null) q.where((t) => t.chain.equals(chain.name));
    final rows = await q.get();
    return rows.map((r) => _decode(r.productJson)).toList();
  }

  Future<int> catalogCount(Chain chain) async {
    final c = catalog.productId.count();
    final row = await (selectOnly(catalog)
          ..addColumns([c])
          ..where(catalog.chain.equals(chain.name)))
        .getSingle();
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
