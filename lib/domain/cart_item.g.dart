// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartItem _$CartItemFromJson(Map<String, dynamic> json) => _CartItem(
  id: json['id'] as String,
  product: Product.fromJson(json['product'] as Map<String, dynamic>),
  quote: PriceQuote.fromJson(json['quote'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  labelTotal: (json['labelTotal'] as num?)?.toDouble(),
  pricePerKgOverride: (json['pricePerKgOverride'] as num?)?.toDouble(),
  discountPercent: (json['discountPercent'] as num?)?.toInt() ?? 0,
  addedAt: DateTime.parse(json['addedAt'] as String),
);

Map<String, dynamic> _$CartItemToJson(_CartItem instance) => <String, dynamic>{
  'id': instance.id,
  'product': instance.product.toJson(),
  'quote': instance.quote.toJson(),
  'quantity': instance.quantity,
  'weightKg': ?instance.weightKg,
  'labelTotal': ?instance.labelTotal,
  'pricePerKgOverride': ?instance.pricePerKgOverride,
  'discountPercent': instance.discountPercent,
  'addedAt': instance.addedAt.toIso8601String(),
};
