// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Store _$StoreFromJson(Map<String, dynamic> json) => _Store(
  addressId: (json['addressId'] as num).toInt(),
  name: json['name'] as String,
  address: json['address'] as String?,
  city: json['city'] as String?,
  province: json['province'] as String?,
);

Map<String, dynamic> _$StoreToJson(_Store instance) => <String, dynamic>{
  'addressId': instance.addressId,
  'name': instance.name,
  'address': ?instance.address,
  'city': ?instance.city,
  'province': ?instance.province,
};
