import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spesa_trento/data/api_exceptions.dart';
import 'package:spesa_trento/data/ebsn_api.dart';
import 'package:spesa_trento/data/ebsn_config.dart';
import 'package:spesa_trento/domain/product.dart';

/// Adapter finto: restituisce sempre la stessa risposta e registra le richieste.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.body, {this.status = 200, this.headers = const {}});

  final String body;
  final int status;
  final Map<String, List<String>> headers;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return ResponseBody.fromString(body, status, headers: {
      // Come il server vero: JSON servito come text/html.
      Headers.contentTypeHeader: ['text/html;charset=UTF-8'],
      ...headers,
    });
  }

  @override
  void close({bool force = false}) {}
}

EbsnApi apiWith(FakeAdapter a, {void Function()? onExpired}) {
  final api = EbsnApi(EbsnConfig.poli,
      minInterval: Duration.zero,
      sleep: (_) async {},
      onSessionExpired: onExpired);
  api.dio.httpClientAdapter = a;
  return api;
}

void main() {
  final fixture =
      File('test/fixtures/products_response.json').readAsStringSync();

  group('Product.fromApi', () {
    test('legge la fixture reale', () {
      final json = jsonDecode(fixture) as Map<String, dynamic>;
      final raw = (json['data']['products'] as List).first;
      final p = Product.fromApi(raw)!;
      expect(p.productId, 213319);
      expect(p.barcode, '8007049920131');
      expect(p.name, 'MOUSSE 100% MELA E BANANA');
      expect(p.brand, 'MELINDA');
      expect(p.packageDescr, '2x100 g');
      expect(p.tipologia, 'Pezzo');
      expect(p.isVariableWeight, isFalse);
      expect(p.price, 1.25);
      expect(p.listPrice, isNull);
      expect(p.pricePerKg, 6.25);
      expect(p.weightUnit, 'kg');
      expect(p.category, 'FRUTTA E VERDURA');
      expect(p.thumbUrl, contains('pim-213319'));
      expect(p.isPromo, isFalse);
    });

    test('tollera numeri come stringhe, null e promo', () {
      final p = Product.fromApi({
        'productId': '42',
        'barcode': 2060120000000,
        'name': 'TRENTINGRANA',
        'shortDescr': null,
        'productInfos': {'TIPOLOGIA': 'Sfuso'},
        'priceDisplay': '2,50',
        'priceStandardDisplay': '3.10',
        'priceUmDisplay': '19,90',
        'breadCrumbs': null,
      })!;
      expect(p.productId, 42);
      expect(p.barcode, '2060120000000');
      expect(p.price, 2.5);
      expect(p.listPrice, 3.1);
      expect(p.isPromo, isTrue);
      expect(p.pricePerKg, 19.9);
      expect(p.isVariableWeight, isTrue);
      expect(p.brand, isNull);
      expect(p.category, isNull);
    });

    test('prezzo pieno uguale al prezzo non è promo', () {
      final p = Product.fromApi({
        'productId': 1,
        'barcode': '1',
        'name': 'X',
        'priceDisplay': 1.0,
        'priceStandardDisplay': 1.0,
      })!;
      expect(p.listPrice, isNull);
    });

    test('senza campi indispensabili restituisce null', () {
      expect(Product.fromApi({'name': 'x'}), isNull);
      expect(Product.fromApi('boh'), isNull);
    });

    test('toJson/fromJson conserva il prodotto', () {
      final json = jsonDecode(fixture) as Map<String, dynamic>;
      final p = Product.fromApi((json['data']['products'] as List).first)!;
      expect(Product.fromJson(jsonDecode(jsonEncode(p.toJson()))), p);
    });
  });

  group('EbsnApi · DupliClick', () {
    test('cerca per barcode e decodifica JSON servito come text/html',
        () async {
      final a = FakeAdapter(fixture,
          headers: {'X-Ebsn-Session': ['nuova-sessione']});
      final api = apiWith(a);
      await api.setSession(const EbsnSession(ebsnSession: 'vecchia'));
      final p = await api.productByBarcode('8007049920131');
      expect(p?.name, 'MOUSSE 100% MELA E BANANA');

      final r = a.requests.single;
      expect(r.path, '/products');
      expect(r.queryParameters['barcode'], '8007049920131');
      expect(r.queryParameters['page_size'], 1);
      expect(r.headers['X-Ebsn-Client'], 'production');
      expect(r.headers['X-Ebsn-Client-Redirect'], 'production');
      expect(r.headers['X-Ebsn-Session'], 'vecchia');
      // Il nuovo valore restituito dal server viene adottato.
      expect(api.session.ebsnSession, 'nuova-sessione');
    });

    test('pagina di ricerca', () async {
      final api = apiWith(FakeAdapter(fixture));
      final page = await api.searchProducts('melinda');
      expect(page.products, hasLength(1));
      expect(page.totPages, 1);
      expect(page.hasMore, isFalse);
    });

    test('419 → SessionExpiredException', () async {
      var expired = false;
      final api = apiWith(FakeAdapter('', status: 419),
          onExpired: () => expired = true);
      await expectLater(
          api.cartAddress(), throwsA(isA<SessionExpiredException>()));
      expect(expired, isTrue);
    });

    test('struttura cambiata → ApiFormatException', () async {
      final api = apiWith(FakeAdapter('{"response":{"status":0},"data":{}}'));
      await expectLater(
          api.productByBarcode('1'), throwsA(isA<ApiFormatException>()));
      final api2 = apiWith(FakeAdapter('<html>manutenzione</html>'));
      await expectLater(
          api2.productByBarcode('1'), throwsA(isA<ApiFormatException>()));
    });

    test('status != 0 → ApiServerException con il messaggio', () async {
      final api = apiWith(FakeAdapter(
          '{"response":{"status":-1,"errors":[{"error":"Indirizzo non valido"}]}}'));
      await expectLater(
        api.selectAddress(1103),
        throwsA(isA<ApiServerException>().having(
            (e) => e.message, 'message', contains('Indirizzo non valido'))),
      );
    });

    test('cart/view legge shippingAddress anche dentro data.cart', () async {
      final api = apiWith(FakeAdapter(jsonEncode({
        'response': {'status': 0},
        'data': {
          'cart': {
            'shippingAddress': {
              'addressId': 1412,
              'addressName': 'IperPoli Trento',
              'addressType': 'work',
              'deliveryServiceId': '1',
            }
          }
        }
      })));
      final a = await api.cartAddress();
      expect(a?.addressId, 1412);
      expect(a?.addressName, 'IperPoli Trento');
      expect(a?.deliveryServiceId, 1);
    });

    test('select manda i parametri in query string', () async {
      final a = FakeAdapter('{"response":{"status":0},"data":{}}');
      await apiWith(a).selectAddress(1103);
      final r = a.requests.single;
      expect(r.method, 'POST');
      expect(r.path, '/user-address/select');
      expect(r.queryParameters, {
        'address_type': 'work',
        'address_id': 1103,
        'delivery_service_id': 1,
      });
    });
  });
}
