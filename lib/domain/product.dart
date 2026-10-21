import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/json_utils.dart';
import 'price_quote.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const Product._();

  const factory Product({
    required int productId,
    required String barcode,
    required String name,
    String? brand,
    String? packageDescr,

    /// "Pezzo" | "Sfuso" | "Confezione".
    String? tipologia,
    required double price,
    double? listPrice,
    double? pricePerKg,
    String? weightUnit,
    String? category,
    String? thumbUrl,
    String? imageUrl,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  /// Costruisce un prodotto da un elemento di `data.products` dell'API
  /// DupliClick. Tollera campi mancanti, null e numeri come stringhe.
  /// Restituisce null se mancano i campi indispensabili.
  static Product? fromApi(Object? raw) {
    if (raw is! Map) return null;
    final m = raw.cast<String, dynamic>();
    final id = asInt(m['productId']);
    final barcode = asString(m['barcode']);
    final name = asString(m['name']);
    final price = asDouble(m['priceDisplay']) ?? asDouble(m['price']);
    if (id == null || barcode == null || name == null || price == null) {
      return null;
    }
    final infos = m['productInfos'] is Map
        ? (m['productInfos'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final crumbs = m['breadCrumbs'];
    String? category;
    if (crumbs is List && crumbs.isNotEmpty && crumbs.first is Map) {
      category = asString((crumbs.first as Map)['name']);
    }
    final standard = asDouble(m['priceStandardDisplay']);
    return Product(
      productId: id,
      barcode: barcode,
      name: name,
      brand: asString(m['shortDescr']),
      packageDescr: asString(infos['PACKAGE_DESCR']),
      tipologia: asString(infos['TIPOLOGIA']),
      price: price,
      listPrice: (standard != null && standard > price + 0.001) ? standard : null,
      pricePerKg: asDouble(m['priceUmDisplay']),
      weightUnit: asString(m['weightUnitDisplay']),
      category: category,
      thumbUrl: asString(m['mediaURL']),
      imageUrl: asString(m['mediaURLMedium']) ?? asString(m['mediaURL']),
    );
  }

  /// Sfuso e Confezione sono a peso variabile: si paga a kg.
  bool get isVariableWeight {
    final t = tipologia?.toLowerCase();
    return t == 'sfuso' || t == 'confezione';
  }

  bool get isPromo => listPrice != null && listPrice! > price + 0.001;

  PriceQuote quote(PriceSource source, DateTime readAt, {int? storeId}) =>
      PriceQuote(
        price: price,
        listPrice: listPrice,
        pricePerKg: pricePerKg,
        source: source,
        readAt: readAt,
        storeId: storeId,
      );
}
