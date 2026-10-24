import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spesa_trento/data/database.dart';
import 'package:spesa_trento/data/everli_api.dart';
import 'package:spesa_trento/data/everli_repository.dart';
import 'package:spesa_trento/domain/chain.dart';
import 'package:spesa_trento/domain/product.dart';
import 'package:spesa_trento/domain/similarity.dart';

/// Risponde in base al percorso; le risposte di `queue` si consumano in ordine.
class RouteAdapter implements HttpClientAdapter {
  RouteAdapter(this.routes);
  final Map<String, List<(int, String)>> routes;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final q = routes[options.path]!;
    final (status, body) = q.length > 1 ? q.removeAt(0) : q.first;
    return ResponseBody.fromString(body, status, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

const _ok = '{"success":true}';
const _noAddress = '{"message":"No address in session","code":"no_address"}';

void main() {
  final fixture = File('test/fixtures/everli_search_latte.json').readAsStringSync();
  final json = jsonDecode(fixture) as Map<String, dynamic>;
  Map<String, dynamic> raw(int store, int i) =>
      (json['stores'][store]['products'] as List)[i] as Map<String, dynamic>;

  group('prodotto Everli', () {
    test('centesimi → euro, unità, niente EAN', () {
      final p = everliProduct(raw(0, 0), Chain.lidl)!;
      expect(p.productId, 2112008);
      expect(p.barcode, 'everli:2112008');
      expect(p.chain, Chain.lidl);
      expect(p.name, 'Latte Italiano Intero Uht');
      expect(p.brand, 'Latteria');
      expect(p.packageDescr, 'Bottiglia 1l');
      expect(p.price, 1.39);
      expect(p.listPrice, isNull);
      expect(p.isPromo, isFalse);
      expect(p.pricePerKg, 1.39); // discounted_price_per_type
      expect(p.weightUnit, 'l');
      expect(p.category, 'Latticini e Uova');
    });

    test('promo: 3,01 € → 2,15 €, sconto 0,86 €', () {
      final p = everliProduct(raw(0, 1), Chain.lidl)!;
      expect(p.price, 2.15);
      expect(p.listPrice, 3.01);
      expect((p.listPrice! - p.price).toStringAsFixed(2), '0.86');
      expect(p.pricePerKg, 11.94);
      expect(p.weightUnit, 'kg');
      expect(p.brand, isNull); // "" → null
    });

    test('price_per_type = 0 è "non disponibile"', () {
      final p = everliProduct(raw(1, 0), Chain.md)!;
      expect(p.price, 1.5);
      expect(p.pricePerKg, isNull);
    });
  });

  group('filtro di rilevanza', () {
    test('"forst" su risultati senza "forst" → lista vuota', () {
      final names = ['Brezel', 'Krapfen alla crema', 'Mazzancolle tropicali'];
      expect(names.where((n) => matchesAllTerms('forst', n)), isEmpty);
    });

    test('tiene i prodotti con tutti i termini, senza accenti e plurali', () {
      expect(matchesAllTerms('latte intero', 'Latte Italiano Intero Uht'),
          isTrue);
      expect(matchesAllTerms('latte intero', 'Latte parzialmente scremato'),
          isFalse);
      expect(matchesAllTerms('caffè', 'Caffe macinato'), isTrue);
      expect(matchesAllTerms('banane', 'Banana Chiquita'), isTrue);
    });
  });

  group('somiglianza', () {
    const ref = Product(
      productId: 1,
      barcode: '8000000000000',
      name: 'LATTE INTERO UHT',
      brand: 'TRENTO',
      packageDescr: '1 l',
      price: 1.49,
      weightUnit: 'l',
    );

    test('quantità dalle descrizioni', () {
      expect(parseQuantity('2x100 g')?.amount, closeTo(0.2, 1e-9));
      expect(parseQuantity('busta 0.350kg')?.amount, 0.35);
      expect(parseQuantity('Bottiglia 1 l')?.unit, 'l');
      expect(parseQuantity('80g')?.amount, closeTo(0.08, 1e-9));
      expect(parseQuantity('confezione'), isNull);
    });

    test('il latte intero è simile, le mazzancolle no', () {
      final latte = everliProduct(raw(0, 0), Chain.lidl)!;
      final mazz = everliProduct(raw(0, 1), Chain.lidl)!;
      expect(similarity(ref, latte), greaterThanOrEqualTo(0.8));
      expect(similarity(ref, mazz), lessThan(EverliRepository.minScore));
    });

    test('parole chiave per gli equivalenti', () {
      expect(equivalentKeyword(ref), 'latte intero uht');
    });
  });

  group('EverliApi', () {
    test('imposta l\'indirizzo e ripete dopo no_address', () async {
      final a = RouteAdapter({
        '/user/address/set': [(200, _ok)],
        '/search': [(400, _noAddress), (200, fixture)],
      });
      final api = EverliApi(minInterval: Duration.zero);
      api.dio.httpClientAdapter = a;
      final r = await api.search('latte', {9231: Chain.lidl, 9750: Chain.md});
      expect(a.requests.map((r) => '${r.method} ${r.path}'), [
        'POST /user/address/set',
        'GET /search',
        'POST /user/address/set',
        'GET /search',
      ]);
      expect(r[9231], hasLength(2));
      expect(r[9750]!.single.chain, Chain.md);
      final search = a.requests.last;
      expect(search.queryParameters,
          {'keyword': 'latte', 'skip': 0, 'take': 50, 'store_ids': '9231,9750'});
      final set = jsonDecode(a.requests.first.data as String) as Map;
      expect(set['skip_location_check'], isTrue);
      expect((set['address'] as Map)['postal_code'], '38122');
      expect(a.requests.first.headers['Content-Type'], 'application/json');
      expect(search.headers['User-Agent'], contains('uso personale'));
    });

    test('keyword vuota: nessuna richiesta', () async {
      final a = RouteAdapter({});
      final api = EverliApi(minInterval: Duration.zero);
      api.dio.httpClientAdapter = a;
      expect(await api.search(' ', {9231: Chain.lidl}), isEmpty);
      expect(a.requests, isEmpty);
    });

    test('dettaglio usa storeId', () async {
      final a = RouteAdapter({
        '/user/address/set': [(200, _ok)],
        '/product/2112008': [(200, jsonEncode(raw(0, 0)))],
      });
      final api = EverliApi(minInterval: Duration.zero);
      api.dio.httpClientAdapter = a;
      final p = await api.product(2112008, 9231, Chain.lidl);
      expect(p?.price, 1.39);
      expect(a.requests.last.queryParameters, {'storeId': 9231});
    });

    test('negozi Lidl e MD da store_list', () async {
      final a = RouteAdapter({
        '/user/address/set': [(200, _ok)],
        '/store_list': [
          (
            200,
            jsonEncode({
              'location': {},
              'stores': [
                {'id': '9231', 'name': 'Lidl', 'address': 'Via Brennero 99-101',
                  'type': 'SUPERMARKET', 'brand_details': {'name': 'Lidl', 'slug': 'lidl'}},
                {'id': '9750', 'name': 'MD', 'address': 'Via Brennero 161',
                  'type': 'SUPERMARKET', 'brand_details': {'name': 'MD', 'slug': 'md'}},
                {'id': '3693', 'name': 'Pam', 'address': 'Via G.B. Trener 16',
                  'type': 'SUPERMARKET', 'brand_details': {'name': 'Pam', 'slug': 'pam'}},
              ]
            })
          )
        ],
      });
      final api = EverliApi(minInterval: Duration.zero);
      api.dio.httpClientAdapter = a;
      final list = await api.storeList();
      expect(list.map((s) => s.chain), [Chain.lidl, Chain.md, null]);
      expect(list.first.id, 9231);
    });
  });

  group('EverliRepository', () {
    test('equivalenti: i più simili, sopra la soglia; cache 12 ore', () async {
      final a = RouteAdapter({
        '/user/address/set': [(200, _ok)],
        '/search': [(200, fixture)],
      });
      final api = EverliApi(minInterval: Duration.zero);
      api.dio.httpClientAdapter = a;
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = EverliRepository(api: api, db: db);
      const ref = Product(
          productId: 1,
          barcode: '8000000000000',
          name: 'LATTE INTERO UHT',
          packageDescr: '1 l',
          price: 1.49,
          weightUnit: 'l');
      final eq = await repo.equivalents(9231, Chain.lidl, ref);
      expect(eq.map((e) => e.product.productId), [2112008]);
      await repo.equivalents(9231, Chain.lidl, ref);
      expect(a.requests.where((r) => r.path == '/search'), hasLength(1));

      await repo.setMatch('8000000000000', 9231, 2112008);
      expect(await repo.match('8000000000000', 9231), 2112008);
      final p = await repo.product(9231, Chain.lidl, 2112008);
      expect(p?.product.price, 1.39); // dalla cache della ricerca
      expect(a.requests.where((r) => r.path.startsWith('/product')), isEmpty);
    });
  });
}
