import 'dart:async';
import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';

import '../domain/chain.dart';
import '../domain/product.dart';
import 'api_exceptions.dart';
import 'json_utils.dart';

const kEverliBase = 'https://spesa.everli.com/api';

/// Indirizzo fisso di Trento usato per la sessione anonima di Everli.
const kEverliTrentoAddress = {
  'address': 'Via Belenzani',
  'street_number': '1',
  'city': 'Trento',
  'province': 'TN',
  'postal_code': '38122',
  'country': 'ITA',
  'lat': 46.07,
  'lng': 11.121,
};

class EverliStore {
  const EverliStore({
    required this.id,
    required this.name,
    this.address,
    this.type,
    this.brandName,
    this.brandSlug,
  });

  final int id;
  final String name;
  final String? address;
  final String? type;
  final String? brandName;
  final String? brandSlug;

  static EverliStore? fromApi(Object? raw) {
    final m = asMap(raw);
    final id = asInt(m?['id']);
    final name = asString(m?['name']);
    if (m == null || id == null || name == null) return null;
    final brand = asMap(m['brand_details']);
    return EverliStore(
      id: id,
      name: name,
      address: asString(m['address']),
      type: asString(m['type']),
      brandName: asString(brand?['name']),
      brandSlug: asString(brand?['slug'])?.toLowerCase(),
    );
  }

  Chain? get chain =>
      Chain.values.where((c) => c.everliSlug == brandSlug).firstOrNull;
}

/// Errore con il codice restituito da Everli (`no_address`, `no_store`…).
class EverliException extends ApiServerException {
  const EverliException(super.message, {super.statusCode, this.code});
  final String? code;
}

/// Converte un prodotto Everli nel modello comune. Prezzi in centesimi;
/// `discount` è negativo quando c'è una promozione; `*_per_type` = 0
/// significa "non disponibile". Everli non ha EAN: il "barcode" è
/// `everli:<id>`, che non coincide mai con un codice vero.
Product? everliProduct(Object? raw, Chain chain) {
  final m = asMap(raw);
  if (m == null) return null;
  final id = asInt(m['id']);
  final name = asString(m['name']);
  final full = asDouble(m['price']);
  final sale = asDouble(m['discounted_price']) ?? full;
  if (id == null || name == null || sale == null) return null;
  final discount = asDouble(m['discount']) ?? 0;
  double? perType;
  for (final k in ['discounted_price_per_type', 'price_per_type']) {
    final v = asDouble(m[k]);
    if (v != null && v > 0) {
      perType = v / 100;
      break;
    }
  }
  final type = asString(m['type']);
  final images = m['images'];
  return Product(
    productId: id,
    barcode: 'everli:$id',
    name: name,
    brand: asString(m['brand']),
    packageDescr: asString(m['short_description']),
    tipologia: m['variable_weight'] == true ? 'Sfuso' : 'Pezzo',
    price: sale / 100,
    listPrice: discount != 0 && full != null && full > sale ? full / 100 : null,
    pricePerKg: perType,
    weightUnit: switch (type) {
      'kilogram' => 'kg',
      'liter' => 'l',
      _ => null,
    },
    category: asString(m['main_category_name']) ?? asString(m['category_name']),
    thumbUrl: asString(m['thumbnail']),
    imageUrl: (images is List && images.isNotEmpty)
        ? asString(
            images.first is Map ? (images.first as Map)['url'] : images.first,
          )
        : asString(m['thumbnail']),
    chain: chain,
  );
}

/// API (non documentate) di Everli. Sessione anonima con cookie
/// `sessionId`; prima di tutto va impostato un indirizzo.
class EverliApi {
  EverliApi({
    Dio? dio,
    this.minInterval = const Duration(milliseconds: 600),
    this.address = kEverliTrentoAddress,
  }) : dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: kEverliBase,
               connectTimeout: const Duration(seconds: 20),
               receiveTimeout: const Duration(seconds: 20),
               sendTimeout: const Duration(seconds: 20),
               responseType: ResponseType.plain,
               validateStatus: (_) => true,
             ),
           ) {
    this.dio.interceptors.addAll([
      CookieManager(CookieJar()),
      InterceptorsWrapper(
        onRequest: (o, h) async {
          await _waitTurn();
          o.headers['Accept'] = 'application/json';
          o.headers['User-Agent'] = 'SpesaTrento (uso personale)';
          if (o.method == 'POST') {
            o.headers['Content-Type'] = 'application/json';
          }
          h.next(o);
        },
      ),
      if (kDebugMode)
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          responseBody: true,
          logPrint: (o) {
            final s = o.toString();
            debugPrint(s.length > 1500 ? '${s.substring(0, 1500)}…' : s);
          },
        ),
    ]);
  }

  final Dio dio;
  final Duration minInterval;
  final Map<String, Object> address;

  bool _addressSet = false;
  Future<void> _gate = Future.value();
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> _waitTurn() {
    final prev = _gate;
    final done = Completer<void>();
    _gate = done.future;
    return prev.then((_) async {
      final wait = minInterval - DateTime.now().difference(_last);
      if (wait > Duration.zero) await Future<void>.delayed(wait);
      _last = DateTime.now();
      done.complete();
    });
  }

  Future<Object?> _raw(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final Response<dynamic> r;
    try {
      r = await dio.request<dynamic>(
        path,
        queryParameters: query,
        data: body == null ? null : jsonEncode(body),
        options: Options(method: method),
      );
    } on DioException catch (e) {
      throw NetworkException(e.message ?? e.type.name);
    }
    final code = r.statusCode ?? 0;
    Object? json;
    final data = r.data;
    if (data is String && data.trim().isNotEmpty) {
      try {
        json = jsonDecode(data.trimLeft());
      } on FormatException {
        json = null;
      }
    } else if (data is! String) {
      json = data;
    }
    if (code >= 400) {
      final m = asMap(json);
      throw EverliException(
        asString(m?['message']) ?? 'Errore HTTP $code da Everli',
        statusCode: code,
        code: asString(m?['code']),
      );
    }
    if (json == null) throw const ApiFormatException('Everli: corpo non JSON');
    return json;
  }

  /// Passo 1: indirizzo in sessione (obbligatorio).
  Future<void> setAddress() async {
    final r = asMap(
      await _raw(
        'POST',
        '/user/address/set',
        body: {'address': address, 'skip_location_check': true},
      ),
    );
    if (r?['success'] != true) {
      throw const ApiFormatException('Everli: indirizzo non accettato');
    }
    _addressSet = true;
  }

  /// Richiesta con indirizzo in sessione; su `no_address` lo reimposta e
  /// ripete una volta.
  Future<Object?> _get(String path, Map<String, dynamic> query) async {
    if (!_addressSet) await setAddress();
    try {
      return await _raw('GET', path, query: query);
    } on EverliException catch (e) {
      if (e.code != 'no_address') rethrow;
      debugPrint('Everli: sessione senza indirizzo, la reimposto');
      await setAddress();
      return _raw('GET', path, query: query);
    }
  }

  /// Passo 2: negozi che consegnano all'indirizzo.
  Future<List<EverliStore>> storeList() async {
    final r = asMap(await _get('/store_list', const {}));
    final stores = r?['stores'];
    if (stores is! List) {
      throw const ApiFormatException('Everli: manca "stores"');
    }
    return stores.map(EverliStore.fromApi).whereType<EverliStore>().toList();
  }

  /// Passo 3: ricerca su più negozi. Restituisce i prodotti grezzi (non
  /// filtrati) per id negozio. `keyword` è obbligatoria.
  Future<Map<int, List<Product>>> search(
    String keyword,
    Map<int, Chain> stores, {
    int skip = 0,
    int take = 50,
  }) async {
    if (keyword.trim().isEmpty) return const {};
    final r = asMap(
      await _get('/search', {
        'keyword': keyword,
        'skip': skip,
        'take': take,
        'store_ids': stores.keys.join(','),
      }),
    );
    final blocks = r?['stores'];
    if (blocks is! List) {
      throw const ApiFormatException('Everli: manca "stores"');
    }
    final out = <int, List<Product>>{};
    for (final b in blocks.map(asMap).whereType<Map<String, dynamic>>()) {
      final id = asInt(asMap(b['store'])?['id']);
      final chain = stores[id];
      if (id == null || chain == null) continue;
      final products = b['products'];
      out[id] = products is List
          ? products
                .map((p) => everliProduct(p, chain))
                .whereType<Product>()
                .toList()
          : const [];
    }
    return out;
  }

  /// Passo 4: dettaglio (il parametro deve chiamarsi `storeId`).
  Future<Product?> product(int productId, int storeId, Chain chain) async {
    final r = await _get('/product/$productId', {'storeId': storeId});
    // Stesso oggetto restituito dalla ricerca.
    return everliProduct(r, chain);
  }
}
