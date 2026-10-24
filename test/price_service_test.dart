import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spesa_trento/data/database.dart';
import 'package:spesa_trento/data/ebsn_api.dart';
import 'package:spesa_trento/data/ebsn_config.dart';
import 'package:spesa_trento/data/everli_api.dart';
import 'package:spesa_trento/data/everli_repository.dart';
import 'package:spesa_trento/data/price_service.dart';
import 'package:spesa_trento/data/product_repository.dart';
import 'package:spesa_trento/domain/chain.dart';
import 'package:spesa_trento/domain/price_quote.dart';
import 'package:spesa_trento/domain/price_store.dart';
import 'package:spesa_trento/domain/product.dart';

class FixedAdapter implements HttpClientAdapter {
  FixedAdapter(this.body);
  final String body;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return ResponseBody.fromString(body, 200, headers: {
      Headers.contentTypeHeader: ['text/html'],
    });
  }

  @override
  void close({bool force = false}) {}
}

const _empty =
    '{"response":{"status":0},"data":{"page":{"selPage":1,"totPages":0},"products":[]}}';

void main() {
  late AppDatabase db;
  late FixedAdapter poliOnlineA, poliSessionA, coopA;
  late PriceService svc;
  int? cartStore;

  EbsnApi api(EbsnConfig c, FixedAdapter a) {
    final api = EbsnApi(c, minInterval: Duration.zero, sleep: (_) async {});
    api.dio.httpClientAdapter = a;
    return api;
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final poliFixture =
        File('test/fixtures/products_response.json').readAsStringSync();
    poliOnlineA = FixedAdapter(poliFixture);
    poliSessionA = FixedAdapter(poliFixture);
    coopA = FixedAdapter(_empty);
    cartStore = null;
    svc = PriceService(
      poliOnline: ProductRepository(
          api: api(EbsnConfig.poli, poliOnlineA),
          db: db,
          currentStoreId: () => null),
      poliSession: ProductRepository(
          api: api(EbsnConfig.poli, poliSessionA),
          db: db,
          currentStoreId: () => cartStore),
      coop: ProductRepository(
          api: api(EbsnConfig.coop, coopA), db: db, currentStoreId: () => null),
      everli: EverliRepository(api: EverliApi(), db: db),
      cartStoreId: () => cartStore,
    );
  });

  tearDown(() => db.close());

  const iper = PriceStore(chain: Chain.poli, storeId: 1412, name: 'Poli · IperPoli');
  const gardolo =
      PriceStore(chain: Chain.poli, storeId: 1103, name: 'Poli · Gardolo');

  test('listini online: Poli trovato, Coop non a listino', () async {
    final p = await svc.quote(PriceStore.poliOnline, '8007049920131');
    expect(p, isA<QuoteFound>());
    final q = (p as QuoteFound).result.quote;
    expect(q.source, PriceSource.online);
    expect(PriceStore.idOfQuote(q), PriceStore.poliOnline.id);
    expect(await svc.quote(PriceStore.coopOnline, '8007049920131'),
        isA<QuoteNotFound>());
    expect(poliOnlineA.requests, hasLength(1));
    expect(coopA.requests.single.uri.host, 'www.clickcoop.it');
  });

  test('punto vendita Poli senza login: non disponibile, nessuna chiamata',
      () async {
    final r = await svc.quote(iper, '8007049920131');
    expect(r, isA<QuoteUnavailable>());
    expect((r as QuoteUnavailable).reason, contains('Collega DupliClick'));
    expect(poliSessionA.requests, isEmpty);
    expect(svc.isLive(iper), isFalse);
  });

  test('negozio attivo nel carrello: prezzo del punto vendita in diretta',
      () async {
    cartStore = 1412;
    final r = await svc.quote(iper, '8007049920131') as QuoteFound;
    expect(r.result.quote.source, PriceSource.store);
    expect(r.result.quote.storeId, 1412);
    expect(PriceStore.idOfQuote(r.result.quote), iper.id);
    expect(poliSessionA.requests, hasLength(1));
  });

  test('altro negozio Poli: solo dalla cache del confronto', () async {
    cartStore = 1412;
    expect(await svc.quote(gardolo, '8007049920131'), isA<QuoteUnavailable>());
    // Come farebbe "Aggiorna prezzi dei negozi Poli" dopo il cambio negozio.
    await svc.poliSession.fetchStoreQuote(1103, '8007049920131');
    final r = await svc.quote(gardolo, '8007049920131') as QuoteFound;
    expect(r.result.quote.storeId, 1103);
    expect(r.result.product.name, 'MOUSSE 100% MELA E BANANA');
  });

  test('id del negozio da un prezzo', () {
    expect(PriceStore.coopOnline.id, 'coop:online');
    expect(iper.id, 'poli:1412');
    expect(iper.shortLabel, 'IperPoli');
    expect(PriceStore.poliOnline.shortLabel, 'Poli online');
  });

  test('Aldi: prezzo inserito a mano, ricordato e rimovibile', () async {
    const s = PriceStore.aldiManual;
    expect(svc.isLive(s), isTrue);
    expect(svc.isSearchable(s), isFalse);
    expect(await svc.quote(s, '8007049920131'), isA<QuoteManualMissing>());
    const ref = Product(
        productId: 213319,
        barcode: '8007049920131',
        name: 'MOUSSE 100% MELA E BANANA',
        price: 1.25);
    final saved = await svc.setManualPrice(s, '8007049920131', ref, price: 0.99);
    expect((saved as QuoteFound).result.quote.price, 0.99);
    final again = await svc.quote(s, '8007049920131') as QuoteFound;
    expect(again.result.quote.source, PriceSource.manual);
    expect(again.result.quote.chain, Chain.aldi);
    expect(PriceStore.idOfQuote(again.result.quote), s.id);
    expect(again.result.product.name, ref.name);
    await svc.setManualPrice(s, '8007049920131', ref);
    expect(await svc.quote(s, '8007049920131'), isA<QuoteManualMissing>());
    // Nessuna chiamata di rete per Aldi.
    expect([...poliOnlineA.requests, ...poliSessionA.requests, ...coopA.requests],
        isEmpty);
  });
}
