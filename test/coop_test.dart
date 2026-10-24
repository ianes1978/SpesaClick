import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spesa_trento/data/api_exceptions.dart';
import 'package:spesa_trento/data/ebsn_api.dart';
import 'package:spesa_trento/data/ebsn_config.dart';
import 'package:spesa_trento/domain/cart_item.dart';
import 'package:spesa_trento/domain/cart_math.dart';
import 'package:spesa_trento/domain/chain.dart';
import 'package:spesa_trento/domain/price_quote.dart';
import 'package:spesa_trento/domain/product.dart';

/// Adapter finto che restituisce in sequenza le risposte date (l'ultima si
/// ripete) e registra le richieste.
class SeqAdapter implements HttpClientAdapter {
  SeqAdapter(this.bodies);

  final List<String> bodies;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = bodies[(requests.length - 1).clamp(0, bodies.length - 1)];
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: ['text/html;charset=UTF-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _flaky =
    '{"response":{"status":1,"errors":[{"error":"Si è verificato un errore nella richiesta."}]}}';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

({EbsnApi api, SeqAdapter adapter, List<Duration> waits}) coop(
  List<String> bodies,
) {
  final waits = <Duration>[];
  final api = EbsnApi(
    EbsnConfig.coop,
    minInterval: Duration.zero,
    sleep: (d) async => waits.add(d),
  );
  final a = SeqAdapter(bodies);
  api.dio.httpClientAdapter = a;
  return (api: api, adapter: a, waits: waits);
}

Product parse(String name) {
  final json = jsonDecode(fixture(name)) as Map<String, dynamic>;
  return Product.fromApi(
    (json['data']['products'] as List).first,
    chain: Chain.coop,
  )!;
}

void main() {
  group('Product.fromApi · Click&Coop', () {
    test('promo: priceDisplay è il prezzo, price il prezzo pieno', () {
      final p = parse('coop_promo.json');
      expect(p.chain, Chain.coop);
      expect(p.productId, 802663);
      expect(p.barcode, '8013755002023');
      expect(p.brand, 'TRENTINGRANA');
      expect(p.packageDescr, '80g'); // da `description`
      expect(p.price, 1.49);
      expect(p.listPrice, 1.89);
      expect(p.isPromo, isTrue);
      expect(p.pricePerKg, 18.63);
      expect(p.weightUnit, 'kg'); // "KG" normalizzato
      expect(p.isVariableWeight, isFalse);
      expect(p.category, 'Gastronomia, Salumi e Formaggi');
      expect(p.priceListName, 'Listino clickcoop');
      expect(p.thumbUrl, contains('//photo/'));
    });

    test(
      'promo anche senza priceStandardDisplay (solo price > priceDisplay)',
      () {
        final p = Product.fromApi({
          'productId': 1,
          'barcode': '1',
          'name': 'X',
          'price': '2,00',
          'priceDisplay': 1.5,
        }, chain: Chain.coop)!;
        expect(p.listPrice, 2.0);
      },
    );

    test('nessuna promo quando price == priceDisplay', () {
      final p = parse('coop_sfuso.json');
      expect(p.listPrice, isNull);
      expect(p.isPromo, isFalse);
    });

    test('sfuso: codice interno corto, prezzo al kg, peso variabile', () {
      final p = parse('coop_sfuso.json');
      expect(p.barcode, '2877992');
      expect(p.isVariableWeight, isTrue);
      expect(p.price, 23.9);
      expect(p.pricePerKg, 23.9);
    });

    test('unità normalizzate', () {
      expect(Product.normalizeUnit('KG'), 'kg');
      expect(Product.normalizeUnit('LT'), 'l');
      expect(Product.normalizeUnit('GR'), 'g');
      expect(Product.normalizeUnit(null), isNull);
    });

    test('DupliClick continua a usare PACKAGE_DESCR', () {
      final p = Product.fromApi({
        'productId': 1,
        'barcode': '1',
        'name': 'X',
        'description': 'testo lungo',
        'price': 1.25,
        'priceDisplay': 1.25,
        'productInfos': {'PACKAGE_DESCR': '500 g'},
      })!;
      expect(p.chain, Chain.poli);
      expect(p.packageDescr, '500 g');
    });
  });

  group('EbsnApi · Click&Coop', () {
    test('header, base URL e righe vuote prima del JSON', () async {
      final c = coop(['\n\n  ${fixture('coop_promo.json')}']);
      final p = await c.api.productByBarcode('8013755002023');
      expect(p?.price, 1.49);
      final r = c.adapter.requests.single;
      expect(
        r.uri.toString(),
        startsWith('https://www.clickcoop.it/ebsn/api/products?'),
      );
      expect(r.queryParameters, {'barcode': '8013755002023', 'page_size': 1});
      expect(r.headers['Accept'], 'application/json');
      expect(r.headers['X-Ebsn-Client'], 'production');
      expect(r.headers['User-Agent'], contains('uso personale'));
      expect(r.headers.containsKey('X-Ebsn-Client-Redirect'), isFalse);
      expect(r.headers.containsKey('X-Ebsn-Session'), isFalse);
    });

    test('errore intermittente: riprova con attesa crescente', () async {
      final c = coop([_flaky, _flaky, fixture('coop_promo.json')]);
      final p = await c.api.productByBarcode('8013755002023');
      expect(p?.productId, 802663);
      expect(c.adapter.requests, hasLength(3));
      expect(c.waits, [
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 1500),
      ]);
    });

    test('dopo 5 nuovi tentativi rinuncia', () async {
      final c = coop([_flaky]);
      await expectLater(
        c.api.productByBarcode('1'),
        throwsA(isA<ApiServerException>()),
      );
      expect(c.adapter.requests, hasLength(6));
      expect(c.waits.last, const Duration(milliseconds: 4500));
    });

    test('DupliClick non ritenta le risposte con status != 0', () async {
      final api = EbsnApi(
        EbsnConfig.poli,
        minInterval: Duration.zero,
        sleep: (_) async {},
      );
      final a = SeqAdapter([_flaky]);
      api.dio.httpClientAdapter = a;
      await expectLater(
        api.productByBarcode('1'),
        throwsA(isA<ApiServerException>()),
      );
      expect(a.requests, hasLength(1));
    });

    test('ricerca con q vuoto: nessuna richiesta', () async {
      final c = coop([fixture('coop_promo.json')]);
      final page = await c.api.searchProducts('');
      expect(page.products, isEmpty);
      expect(c.adapter.requests, isEmpty);
    });

    test('prodotti per categoria usano parent_category_id', () async {
      final c = coop([fixture('coop_promo.json')]);
      await c.api.productsByCategory(45307, page: 2, pageSize: 80);
      expect(c.adapter.requests.single.queryParameters, {
        'parent_category_id': 45307,
        'page': 2,
        'page_size': 80,
      });
    });

    test('categorie', () async {
      final c = coop([
        jsonEncode({
          'response': {'status': 0, 'errors': []},
          'data': {
            'categories': [
              {
                'categoryId': 45306,
                'name': 'Frutta e verdura',
                'slug': 'frutta',
              },
              {'categoryId': '45294', 'name': 'Promozioni'},
              {'name': 'senza id'},
            ],
          },
        }),
      ]);
      final cats = await c.api.categories();
      expect(cats.map((c) => c.id), [45306, 45294]);
      expect(cats.first.name, 'Frutta e verdura');
    });

    test('punti di ritiro da data.addresses', () async {
      final c = coop([
        jsonEncode({
          'response': {'status': 0, 'errors': []},
          'data': {
            'addresses': [
              {
                'addressId': 686491,
                'addressType': 'drive',
                'addressName': 'Coop Superstore',
                'address1': 'Centro Direzionale Trento Sud',
                'city': 'Trento',
                'province': 'TN',
              },
            ],
          },
        }),
      ]);
      final list = await c.api.deliveryServiceList();
      expect(list.single.addressId, 686491);
      expect(list.single.name, 'Coop Superstore');
      expect(list.single.city, 'Trento');
    });

    test('cart/view e cambio negozio non sono disponibili', () async {
      final c = coop([fixture('coop_promo.json')]);
      await expectLater(
        c.api.cartAddress(),
        throwsA(isA<ApiServerException>()),
      );
      await expectLater(
        c.api.selectAddress(686491),
        throwsA(isA<ApiServerException>()),
      );
      expect(c.adapter.requests, isEmpty);
    });
  });

  group('confronto Poli ↔ Coop', () {
    final t = DateTime(2026, 10, 22);

    test('totale nell\'altra catena per id riga, con peso variabile', () {
      final melinda = CartItem(
        id: 'poli:8007049920131',
        product: const Product(
          productId: 1,
          barcode: '8007049920131',
          name: 'Mousse',
          price: 1.25,
        ),
        quote: PriceQuote(price: 1.25, source: PriceSource.store, readAt: t),
        quantity: 2,
        addedAt: t,
      );
      final grana = CartItem(
        id: 'coop:2877992',
        product: parse('coop_sfuso.json'),
        quote: PriceQuote(
          price: 23.9,
          pricePerKg: 23.9,
          source: PriceSource.online,
          readAt: t,
          chain: Chain.coop,
        ),
        weightKg: 0.25,
        addedAt: t,
      );
      final here = cartTotals([melinda, grana]);
      expect(here.total, 2.50 + 5.98);
      final o = otherStoreTotal(
        [melinda, grana],
        {
          'poli:8007049920131': PriceQuote(
            price: 1.19,
            source: PriceSource.online,
            readAt: t,
            chain: Chain.coop,
          ),
        },
        keyOf: (i) => i.id,
      );
      expect(o.total, 2.38 + 5.98);
      expect(o.missing, 1);
    });
  });
}
