import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/json_utils.dart';

part 'store.freezed.dart';
part 'store.g.dart';

const kIperPoliTrentoId = 1412;
const kPoliGardoloId = 1103;

@freezed
abstract class Store with _$Store {
  const Store._();

  const factory Store({
    required int addressId,
    required String name,
    String? address,
    String? city,
    String? province,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  /// Elemento di `delivery-service-list` (nomi dei campi non documentati:
  /// si provano le varianti più comuni della piattaforma ebsn).
  static Store? fromApi(Object? raw) {
    final m = asMap(raw);
    if (m == null) return null;
    final id = asInt(m['addressId']) ?? asInt(m['id']);
    final name = asString(m['addressName']) ??
        asString(m['name']) ??
        asString(m['warehouseName']);
    if (id == null || name == null) return null;
    final street = asString(m['address1']) ?? asString(m['address']);
    final number = asString(m['addressNumber']);
    return Store(
      addressId: id,
      name: name,
      address: [street, number].whereType<String>().join(' ').trim(),
      city: asString(m['city']),
      province: asString(m['province']),
    );
  }

  String get shortName => name
      .replaceAll(RegExp(r'\s*-\s*.*$'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Negozi di Trento noti, usati se `delivery-service-list` non risponde.
const kKnownTrentoStores = <Store>[
  Store(
    addressId: kIperPoliTrentoId,
    name: 'IperPoli Trento',
    address: 'Via Brennero 270 – La Cittadella',
    city: 'Trento',
    province: 'TN',
  ),
  Store(
    addressId: kPoliGardoloId,
    name: 'Poli Gardolo',
    address: 'Via Soprasasso 21',
    city: 'Trento',
    province: 'TN',
  ),
];

/// Indirizzo di consegna/ritiro attivo nel carrello DupliClick.
@freezed
abstract class CartAddress with _$CartAddress {
  const factory CartAddress({
    required int addressId,
    String? addressName,
    String? addressType,
    int? deliveryServiceId,
  }) = _CartAddress;

  static CartAddress? fromApi(Object? raw) {
    final m = asMap(raw);
    if (m == null) return null;
    final id = asInt(m['addressId']) ?? asInt(m['id']);
    if (id == null) return null;
    return CartAddress(
      addressId: id,
      addressName: asString(m['addressName']) ?? asString(m['name']),
      addressType: asString(m['addressType']),
      deliveryServiceId: asInt(m['deliveryServiceId']) ??
          asInt(asMap(m['deliveryService'])?['deliveryServiceId']),
    );
  }
}
