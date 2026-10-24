// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceQuote _$PriceQuoteFromJson(Map<String, dynamic> json) => _PriceQuote(
  price: (json['price'] as num).toDouble(),
  listPrice: (json['listPrice'] as num?)?.toDouble(),
  pricePerKg: (json['pricePerKg'] as num?)?.toDouble(),
  source: $enumDecode(_$PriceSourceEnumMap, json['source']),
  readAt: DateTime.parse(json['readAt'] as String),
  chain: $enumDecodeNullable(_$ChainEnumMap, json['chain']) ?? Chain.poli,
  storeId: (json['storeId'] as num?)?.toInt(),
);

Map<String, dynamic> _$PriceQuoteToJson(_PriceQuote instance) =>
    <String, dynamic>{
      'price': instance.price,
      'listPrice': ?instance.listPrice,
      'pricePerKg': ?instance.pricePerKg,
      'source': _$PriceSourceEnumMap[instance.source]!,
      'readAt': instance.readAt.toIso8601String(),
      'chain': _$ChainEnumMap[instance.chain]!,
      'storeId': ?instance.storeId,
    };

const _$PriceSourceEnumMap = {
  PriceSource.store: 'store',
  PriceSource.online: 'online',
  PriceSource.label: 'label',
  PriceSource.offline: 'offline',
  PriceSource.manual: 'manual',
};

const _$ChainEnumMap = {
  Chain.poli: 'poli',
  Chain.coop: 'coop',
  Chain.lidl: 'lidl',
  Chain.md: 'md',
  Chain.pam: 'pam',
  Chain.aldi: 'aldi',
};
