// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceStore _$PriceStoreFromJson(Map<String, dynamic> json) => _PriceStore(
  chain: $enumDecode(_$ChainEnumMap, json['chain']),
  storeId: (json['storeId'] as num?)?.toInt(),
  name: json['name'] as String,
  address: json['address'] as String?,
);

Map<String, dynamic> _$PriceStoreToJson(_PriceStore instance) =>
    <String, dynamic>{
      'chain': _$ChainEnumMap[instance.chain]!,
      'storeId': ?instance.storeId,
      'name': instance.name,
      'address': ?instance.address,
    };

const _$ChainEnumMap = {
  Chain.poli: 'poli',
  Chain.coop: 'coop',
  Chain.lidl: 'lidl',
  Chain.md: 'md',
  Chain.aldi: 'aldi',
};
