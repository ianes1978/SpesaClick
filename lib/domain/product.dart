import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/json_utils.dart';
import 'chain.dart';
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
    @Default(Chain.poli) Chain chain,

    /// Listino applicato (`priceListName`, solo Click&Coop).
    String? priceListName,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  /// Costruisce un prodotto da un elemento di `data.products` dell'API ebsn.
  /// Tollera campi mancanti, null e numeri come stringhe.
  /// Restituisce null se mancano i campi indispensabili.
  ///
  /// Prezzi: `priceDisplay` è il prezzo di vendita attuale. Su DupliClick
  /// `price == priceDisplay` e il prezzo pieno in promo sta in
  /// `priceStandardDisplay`; su Click&Coop `price` è il prezzo pieno.
  /// Prendendo il massimo fra i due si normalizzano entrambe le catene.
  static Product? fromApi(Object? raw, {Chain chain = Chain.poli}) {
    if (raw is! Map) return null;
    final m = raw.cast<String, dynamic>();
    final id = asInt(m['productId']);
    final barcode = asString(m['barcode']);
    final name = asString(m['name']);
    final fullPrice = asDouble(m['price']);
    final price = asDouble(m['priceDisplay']) ?? fullPrice;
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
    double? listPrice;
    for (final c in [asDouble(m['priceStandardDisplay']), fullPrice]) {
      if (c != null && c > price + 0.001 && (listPrice == null || c > listPrice)) {
        listPrice = c;
      }
    }
    final packageDescr = chain == Chain.coop
        ? asString(m['description']) ?? asString(infos['PACKAGE_DESCR'])
        : asString(infos['PACKAGE_DESCR']);
    return Product(
      productId: id,
      barcode: barcode,
      name: name,
      brand: asString(m['shortDescr']),
      packageDescr: packageDescr,
      tipologia: asString(infos['TIPOLOGIA']),
      price: price,
      listPrice: listPrice,
      pricePerKg: asDouble(m['priceUmDisplay']),
      weightUnit: normalizeUnit(asString(m['weightUnitDisplay'])),
      category: category,
      thumbUrl: asString(m['mediaURL']),
      imageUrl: asString(m['mediaURLMedium']) ?? asString(m['mediaURL']),
      chain: chain,
      priceListName: asString(m['priceListName']),
    );
  }

  /// "KG" → "kg", "LT" → "l", "GR" → "g".
  static String? normalizeUnit(String? u) {
    if (u == null) return null;
    final l = u.toLowerCase();
    return switch (l) {
      'lt' || 'lt.' || 'litri' => 'l',
      'gr' || 'gr.' => 'g',
      _ => l,
    };
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
        chain: chain,
      );
}
