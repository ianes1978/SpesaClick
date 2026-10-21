// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  productId: (json['productId'] as num).toInt(),
  barcode: json['barcode'] as String,
  name: json['name'] as String,
  brand: json['brand'] as String?,
  packageDescr: json['packageDescr'] as String?,
  tipologia: json['tipologia'] as String?,
  price: (json['price'] as num).toDouble(),
  listPrice: (json['listPrice'] as num?)?.toDouble(),
  pricePerKg: (json['pricePerKg'] as num?)?.toDouble(),
  weightUnit: json['weightUnit'] as String?,
  category: json['category'] as String?,
  thumbUrl: json['thumbUrl'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'productId': instance.productId,
  'barcode': instance.barcode,
  'name': instance.name,
  'brand': ?instance.brand,
  'packageDescr': ?instance.packageDescr,
  'tipologia': ?instance.tipologia,
  'price': instance.price,
  'listPrice': ?instance.listPrice,
  'pricePerKg': ?instance.pricePerKg,
  'weightUnit': ?instance.weightUnit,
  'category': ?instance.category,
  'thumbUrl': ?instance.thumbUrl,
  'imageUrl': ?instance.imageUrl,
};
