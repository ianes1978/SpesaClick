import 'dart:async';
import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';

import '../domain/product.dart';
import '../domain/store.dart';
import 'api_exceptions.dart';
import 'json_utils.dart';

const kDupliclickOrigin = 'https://www.dupliclick.it';
const kEbsnBase = '$kDupliclickOrigin/ebsn/api';
final kEbsnCookieUri = Uri.parse('$kDupliclickOrigin/ebsn/');

/// Una pagina di risultati di `/products`.
class ProductPage {
  const ProductPage({
    required this.products,
    required this.page,
    required this.totPages,
    required this.totItems,
  });

  final List<Product> products;
  final int page;
  final int totPages;
  final int totItems;

  bool get hasMore => page < totPages;
}

/// Credenziali di sessione copiate dalla WebView di login.
class EbsnSession {
  const EbsnSession({this.jsessionId, this.ebsnSession, this.ebsnAccount});

  final String? jsessionId;
  final String? ebsnSession;
  final String? ebsnAccount;

  bool get isEmpty =>
      (jsessionId ?? '').isEmpty && (ebsnSession ?? '').isEmpty;

  EbsnSession copyWith({String? jsessionId, String? ebsnSession}) =>
      EbsnSession(
        jsessionId: jsessionId ?? this.jsessionId,
        ebsnSession: ebsnSession ?? this.ebsnSession,
        ebsnAccount: ebsnAccount,
      );
}

/// Unico punto di contatto con le API (non documentate) di DupliClick.
///
/// Tutte le richieste passano da un solo client Dio che:
/// * aggiunge gli header `X-Ebsn-*` del sito web;
/// * aggiorna `X-Ebsn-Session` se il server ne restituisce uno nuovo;
/// * trasforma il 419 in [SessionExpiredException];
/// * serializza le richieste con almeno 300 ms di distanza;
/// * ritenta una sola volta in caso di errore di rete.
class DupliclickApi {
  DupliclickApi({
    Dio? dio,
    CookieJar? cookieJar,
    this.minInterval = const Duration(milliseconds: 300),
    this.onSessionChanged,
    this.onSessionExpired,
  })  : cookieJar = cookieJar ?? CookieJar(),
        dio = dio ??
            Dio(BaseOptions(
              baseUrl: kEbsnBase,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
              responseType: ResponseType.plain,
              // Gestiamo noi i codici d'errore (419 compreso).
              validateStatus: (_) => true,
            )) {
    this.dio.interceptors.addAll([
      CookieManager(this.cookieJar),
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
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
  final CookieJar cookieJar;
  final Duration minInterval;

  /// Chiamato quando cambia JSESSIONID o X-Ebsn-Session (per salvarli).
  final void Function(EbsnSession session)? onSessionChanged;

  /// Chiamato su HTTP 419.
  final void Function()? onSessionExpired;

  EbsnSession _session = const EbsnSession();
  EbsnSession get session => _session;
  bool get hasSession => !_session.isEmpty;

  // ---- sessione ---------------------------------------------------------

  /// Imposta la sessione letta dalla WebView o dallo storage sicuro.
  Future<void> setSession(EbsnSession s) async {
    _session = s;
    await cookieJar.deleteAll();
    final id = s.jsessionId;
    if (id != null && id.isNotEmpty) {
      final c = Cookie('JSESSIONID', id)
        ..path = '/ebsn/'
        ..httpOnly = true
        ..secure = true;
      await cookieJar.saveFromResponse(kEbsnCookieUri, [c]);
    }
  }

  Future<void> clearSession() => setSession(const EbsnSession());

  // ---- interceptor -------------------------------------------------------

  Future<void> _gate = Future.value();
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);

  /// Rate limit: le richieste partono una alla volta, distanziate.
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

  Future<void> _onRequest(
      RequestOptions o, RequestInterceptorHandler h) async {
    await _waitTurn();
    o.headers['Accept'] = 'application/json';
    o.headers['X-Ebsn-Client'] = 'production';
    o.headers['X-Ebsn-Client-Redirect'] = 'production';
    final s = _session.ebsnSession;
    if (s != null && s.isNotEmpty) o.headers['X-Ebsn-Session'] = s;
    final a = _session.ebsnAccount;
    if (a != null && a.isNotEmpty) o.headers['X-Ebsn-Account'] = a;
    h.next(o);
  }

  Future<void> _onResponse(Response r, ResponseInterceptorHandler h) async {
    var changed = false;
    final newSession = r.headers.value('X-Ebsn-Session');
    if (newSession != null &&
        newSession.isNotEmpty &&
        newSession != _session.ebsnSession) {
      _session = _session.copyWith(ebsnSession: newSession);
      changed = true;
    }
    try {
      final cookies = await cookieJar.loadForRequest(kEbsnCookieUri);
      final js = cookies.where((c) => c.name == 'JSESSIONID').firstOrNull;
      if (js != null && js.value != _session.jsessionId) {
        _session = _session.copyWith(jsessionId: js.value);
        changed = true;
      }
    } catch (_) {}
    if (changed) onSessionChanged?.call(_session);
    h.next(r);
  }

  Future<void> _onError(DioException e, ErrorInterceptorHandler h) async {
    final retriable = e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
    if (retriable && e.requestOptions.extra['retried'] != true) {
      e.requestOptions.extra['retried'] = true;
      try {
        final r = await dio.fetch<dynamic>(e.requestOptions);
        return h.resolve(r);
      } on DioException catch (e2) {
        return h.next(e2);
      }
    }
    h.next(e);
  }

  // ---- chiamate di base ---------------------------------------------------

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final Response<dynamic> r;
    try {
      r = await dio.request<dynamic>(
        path,
        queryParameters: query,
        options: Options(method: method),
        data: method == 'POST' ? '' : null,
      );
    } on DioException catch (e) {
      throw NetworkException(e.message ?? e.type.name);
    }
    final code = r.statusCode ?? 0;
    if (code == 419) {
      onSessionExpired?.call();
      throw const SessionExpiredException();
    }
    final body = r.data;
    Map<String, dynamic>? json;
    // Content-Type è text/html ma il corpo è JSON.
    if (body is String) {
      try {
        json = asMap(jsonDecode(body));
      } on FormatException {
        json = null;
      }
    } else {
      json = asMap(body);
    }
    if (code >= 400) {
      throw ApiServerException(
        _errorText(json) ?? 'Errore HTTP $code da DupliClick',
        statusCode: code,
      );
    }
    if (json == null) throw const ApiFormatException('il corpo non è JSON');
    final status = asInt(asMap(json['response'])?['status']);
    if (status != null && status != 0) {
      throw ApiServerException(
          _errorText(json) ?? 'DupliClick ha risposto con stato $status');
    }
    return json;
  }

  String? _errorText(Map<String, dynamic>? json) {
    final errors = asMap(json?['response'])?['errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors
          .map((e) => e is Map ? (e['error'] ?? e['message'] ?? e) : e)
          .join('; ');
    }
    return null;
  }

  Map<String, dynamic> _data(Map<String, dynamic> json) {
    final d = asMap(json['data']);
    if (d == null) throw const ApiFormatException('manca "data"');
    return d;
  }

  ProductPage _parsePage(Map<String, dynamic> json) {
    final data = _data(json);
    final raw = data['products'];
    if (raw is! List) throw const ApiFormatException('manca "data.products"');
    final products = raw.map(Product.fromApi).whereType<Product>().toList();
    if (raw.isNotEmpty && products.isEmpty) {
      throw const ApiFormatException('prodotti senza i campi attesi');
    }
    final page = asMap(data['page']);
    return ProductPage(
      products: products,
      page: asInt(page?['selPage']) ?? 1,
      totPages: asInt(page?['totPages']) ?? 1,
      totItems: asInt(page?['totItems']) ?? products.length,
    );
  }

  // ---- endpoint -----------------------------------------------------------

  /// Prodotto per EAN (match esatto). NB: `q=<EAN>` non funziona.
  Future<Product?> productByBarcode(String ean) async {
    final json = await _request('GET', '/products',
        query: {'barcode': ean, 'page_size': 1});
    final page = _parsePage(json);
    return page.products
            .where((p) => p.barcode == ean)
            .firstOrNull ??
        page.products.firstOrNull;
  }

  /// Ricerca testuale; con `q` vuoto restituisce l'intero listino.
  Future<ProductPage> searchProducts(String q,
      {int page = 1, int pageSize = 24}) async {
    final json = await _request('GET', '/products',
        query: {'q': q, 'page': page, 'page_size': pageSize});
    return _parsePage(json);
  }

  /// Punti vendita con ritiro in negozio.
  Future<List<Store>> deliveryServiceList({int deliveryServiceId = 1}) async {
    final json = await _request('GET', '/address/delivery-service-list',
        query: {'delivery_service_id': deliveryServiceId});
    final data = json['data'];
    List<dynamic>? list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      for (final k in ['addresses', 'warehouses', 'addressList', 'list']) {
        if (data[k] is List) {
          list = data[k] as List;
          break;
        }
      }
      list ??= data.values.whereType<List>().firstOrNull;
    }
    if (list == null) {
      throw const ApiFormatException('elenco punti vendita non trovato');
    }
    return list.map(Store.fromApi).whereType<Store>().toList();
  }

  /// Indirizzo attivo nel carrello (richiede login).
  Future<CartAddress?> cartAddress() async {
    final json = await _request('GET', '/cart/view');
    final data = _data(json);
    final addr = data['shippingAddress'] ??
        asMap(data['cart'])?['shippingAddress'];
    final parsed = CartAddress.fromApi(addr);
    if (parsed == null) {
      debugPrint('cart/view senza shippingAddress: chiavi ${data.keys}');
    }
    return parsed;
  }

  /// Cambia il punto vendita del carrello (richiede login).
  Future<void> selectAddress(
    int addressId, {
    String addressType = 'work',
    int deliveryServiceId = 1,
  }) async {
    await _request('POST', '/user-address/select', query: {
      'address_type': addressType,
      'address_id': addressId,
      'delivery_service_id': deliveryServiceId,
    });
  }
}
