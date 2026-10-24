import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_exceptions.dart';
import '../data/database.dart';
import '../data/ebsn_api.dart';
import '../data/ebsn_config.dart';
import '../data/everli_api.dart';
import '../data/everli_repository.dart';
import '../data/price_service.dart';
import '../data/product_repository.dart';
import '../data/session_storage.dart';
import '../data/store_repository.dart';
import '../domain/cart_item.dart';
import '../domain/cart_math.dart';
import '../domain/chain.dart';
import '../domain/ean.dart';
import '../domain/price_quote.dart';
import '../domain/price_store.dart';
import '../domain/product.dart';
import '../domain/store.dart';

// ---- infrastruttura ---------------------------------------------------------

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final sessionStorageProvider = Provider<SessionStorage>(
  (_) => SessionStorage(),
);

/// Un client per catena (ognuno con il suo rate limit).
final apiProvider = Provider.family<EbsnApi, Chain>((ref, chain) {
  if (chain == Chain.coop) return EbsnApi(EbsnConfig.coop);
  return EbsnApi(
    EbsnConfig.poli,
    onSessionChanged: (s) => ref.read(sessionStorageProvider).save(s),
    onSessionExpired: () => Future.microtask(
      () => ref.read(sessionProvider.notifier).markExpired(),
    ),
  );
});

/// DupliClick senza sessione: listino online, anche quando si è collegati.
final poliOnlineApiProvider = Provider<EbsnApi>(
  (ref) => EbsnApi(EbsnConfig.poli),
);

final poliOnlineRepoProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    api: ref.watch(poliOnlineApiProvider),
    db: ref.watch(dbProvider),
    currentStoreId: () => null,
  );
});

final everliApiProvider = Provider<EverliApi>((ref) => EverliApi());

final everliRepoProvider = Provider<EverliRepository>(
  (ref) => EverliRepository(
    api: ref.watch(everliApiProvider),
    db: ref.watch(dbProvider),
  ),
);

final priceServiceProvider = Provider<PriceService>((ref) {
  return PriceService(
    poliOnline: ref.watch(poliOnlineRepoProvider),
    poliSession: ref.watch(productRepoProvider(Chain.poli)),
    coop: ref.watch(productRepoProvider(Chain.coop)),
    everli: ref.watch(everliRepoProvider),
    cartStoreId: () => ref.read(sessionProvider).storeId,
  );
});

final productRepoProvider = Provider.family<ProductRepository, Chain>((
  ref,
  chain,
) {
  return ProductRepository(
    api: ref.watch(apiProvider(chain)),
    db: ref.watch(dbProvider),
    currentStoreId: chain == Chain.poli
        ? () => ref.read(sessionProvider).storeId
        : () => null,
  );
});

final storeRepoProvider = Provider<StoreRepository>((ref) {
  return StoreRepository(
    api: ref.watch(apiProvider(Chain.poli)),
    db: ref.watch(dbProvider),
    products: ref.watch(productRepoProvider(Chain.poli)),
  );
});

/// Negozi da cui leggere e confrontare i prezzi, in ordine di preferenza.
/// Il primo è quello proposto per primo quando un prodotto è in più negozi.
class SelectedStoresNotifier extends Notifier<List<PriceStore>> {
  static const _key = 'selected_stores';

  @override
  List<PriceStore> build() {
    Future.microtask(_load);
    return const [PriceStore.poliOnline, PriceStore.coopOnline];
  }

  Future<void> _load() async {
    final raw = await ref.read(dbProvider).getValue(_key);
    if (raw == null) return;
    try {
      state = (jsonDecode(raw) as List)
          .map((e) => PriceStore.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  void _set(List<PriceStore> v) {
    state = v;
    ref
        .read(dbProvider)
        .setValue(_key, jsonEncode(v.map((s) => s.toJson()).toList()));
  }

  bool contains(PriceStore s) => state.any((e) => e.id == s.id);

  void toggle(PriceStore s) => contains(s)
      ? _set(state.where((e) => e.id != s.id).toList())
      : _set([...state, s]);

  void reorder(int from, int to) {
    final l = [...state];
    // `to` è già corretto per l'elemento tolto (onReorderItem).
    l.insert(to, l.removeAt(from));
    _set(l);
  }
}

final selectedStoresProvider =
    NotifierProvider<SelectedStoresNotifier, List<PriceStore>>(
      SelectedStoresNotifier.new,
    );

/// Tutti i negozi che si possono aggiungere al confronto.
final availableStoresProvider = FutureProvider<List<PriceStore>>((ref) async {
  final poli = await ref.watch(storesProvider.future);
  final everli = await ref.watch(everliStoresProvider.future);
  return [
    PriceStore.poliOnline,
    for (final s in poli)
      PriceStore(
        chain: Chain.poli,
        storeId: s.addressId,
        name: 'Poli · ${s.name}',
        address: [
          s.address,
          s.city,
        ].whereType<String>().where((e) => e.isNotEmpty).join(', '),
      ),
    PriceStore.coopOnline,
    ...everli,
    PriceStore.aldiManual,
  ];
});

/// Negozi Lidl, MD e Pam che Everli serve all'indirizzo di Trento.
/// Lista vuota se Everli non risponde (l'errore va in [everliErrorProvider]).
final everliStoresProvider = FutureProvider<List<PriceStore>>((ref) async {
  try {
    final list = await ref.watch(everliRepoProvider).stores();
    return [
      for (final s in list)
        if (s.chain case final c?)
          PriceStore(
            chain: c,
            storeId: s.id,
            name: '${c.label} · ${s.address ?? s.name}',
            address: s.address,
          ),
    ];
  } on ApiException catch (e) {
    debugPrint('Everli store_list: $e');
    return const [];
  }
});

/// Chiedere quale prezzo usare quando il prodotto è in più negozi.
class AskStoreChoiceNotifier extends Notifier<bool> {
  static const _key = 'ask_store_choice';

  @override
  bool build() {
    Future.microtask(() async {
      final v = await ref.read(dbProvider).getValue(_key);
      if (v != null) state = v == 'true';
    });
    return true;
  }

  void set(bool v) {
    state = v;
    ref.read(dbProvider).setValue(_key, '$v');
  }
}

final askStoreChoiceProvider = NotifierProvider<AskStoreChoiceNotifier, bool>(
  AskStoreChoiceNotifier.new,
);

// ---- sessione DupliClick ----------------------------------------------------

enum SessionStatus { none, checking, connected, expired, offline, error }

@immutable
class SessionState {
  const SessionState(this.status, {this.address, this.message});

  final SessionStatus status;
  final CartAddress? address;
  final String? message;

  int? get storeId =>
      status == SessionStatus.connected ? address?.addressId : null;

  String get label => switch (status) {
    SessionStatus.none => 'Non collegato',
    SessionStatus.checking => 'Verifica sessione…',
    SessionStatus.connected =>
      'Collegato a ${address?.addressName ?? 'DupliClick'}',
    SessionStatus.expired => 'Sessione scaduta',
    SessionStatus.offline => 'Offline (sessione salvata)',
    SessionStatus.error => 'Errore: ${message ?? ''}',
  };
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() {
    Future.microtask(_restore);
    return const SessionState(SessionStatus.checking);
  }

  EbsnApi get _api => ref.read(apiProvider(Chain.poli));
  SessionStorage get _storage => ref.read(sessionStorageProvider);

  Future<void> _restore() async {
    final s = await _storage.load();
    if (s.isEmpty) {
      state = const SessionState(SessionStatus.none);
      return;
    }
    await _api.setSession(s);
    await verify();
  }

  /// Sessione appena letta dalla WebView di login.
  Future<void> connect(EbsnSession s) async {
    debugPrint(
      'Sessione DupliClick: JSESSIONID=${s.jsessionId != null}, '
      'X-Ebsn-Session=${s.ebsnSession != null}, '
      'X-Ebsn-Account=${s.ebsnAccount != null}',
    );
    await _storage.save(s);
    await _api.setSession(s);
    await verify();
  }

  Future<void> verify() async {
    if (!_api.hasSession) {
      state = const SessionState(SessionStatus.none);
      return;
    }
    state = SessionState(SessionStatus.checking, address: state.address);
    try {
      final addr = await _api.cartAddress();
      state = SessionState(SessionStatus.connected, address: addr);
    } on SessionExpiredException {
      state = const SessionState(SessionStatus.expired);
    } on NetworkException {
      state = SessionState(SessionStatus.offline, address: state.address);
    } on ApiException catch (e) {
      state = SessionState(SessionStatus.error, message: e.message);
    }
  }

  void markExpired() {
    if (state.status != SessionStatus.expired) {
      state = const SessionState(SessionStatus.expired);
    }
  }

  void setAddress(CartAddress? a) =>
      state = SessionState(SessionStatus.connected, address: a);

  Future<void> disconnect() async {
    await _storage.clear();
    await _api.clearSession();
    state = const SessionState(SessionStatus.none);
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);

final storesProvider = FutureProvider<List<Store>>(
  (ref) => ref.watch(storeRepoProvider).trentoStores(),
);

// ---- carrello ---------------------------------------------------------------

class CartNotifier extends Notifier<List<CartItem>> {
  bool _loaded = false;

  @override
  List<CartItem> build() {
    Future.microtask(_load);
    return const [];
  }

  AppDatabase get _db => ref.read(dbProvider);

  Future<void> _load() async {
    final items = await _db.loadCart();
    // Se nel frattempo si è già scansionato qualcosa, lo si tiene.
    state = [...items.where((i) => !state.any((s) => s.id == i.id)), ...state];
    _loaded = true;
  }

  void _set(List<CartItem> items) {
    state = items;
    if (_loaded) unawaited(_db.saveCart(items));
  }

  /// Aggiunge un prodotto trovato; se già presente incrementa la quantità.
  /// Restituisce la riga aggiornata.
  CartItem add(LookupResult r, {ScaleLabel? label}) {
    final id = label?.raw ?? r.product.barcode;
    final idx = state.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      final updated = state[idx].copyWith(quantity: state[idx].quantity + 1);
      _set([...state]..[idx] = updated);
      return updated;
    }
    CartItem item;
    if (label != null) {
      final ppk = r.quote.pricePerKg;
      item = CartItem(
        id: id,
        product: r.product,
        quote: PriceQuote(
          price: label.total,
          pricePerKg: ppk,
          source: PriceSource.label,
          readAt: DateTime.now(),
          storeId: r.quote.storeId,
          chain: r.quote.chain,
        ),
        labelTotal: label.total,
        weightKg: (ppk != null && ppk > 0)
            ? double.parse((label.total / ppk).toStringAsFixed(3))
            : null,
        addedAt: DateTime.now(),
      );
    } else {
      item = CartItem(
        id: id,
        product: r.product,
        quote: r.quote,
        addedAt: DateTime.now(),
      );
    }
    _set([item, ...state]);
    return item;
  }

  /// Riga inserita a mano (es. articolo a peso non riconosciuto).
  void addManual(CartItem item) => _set([item, ...state]);

  void setQuantity(String id, int q) {
    if (q <= 0) return remove(id);
    _update(id, (i) => i.copyWith(quantity: q));
  }

  void remove(String id) => _set(state.where((i) => i.id != id).toList());

  /// Un tocco sullo stesso bollino lo toglie, sull'altro lo sostituisce.
  void toggleSticker(String id, int pct) => _update(
    id,
    (i) => i.copyWith(discountPercent: i.discountPercent == pct ? 0 : pct),
  );

  void setWeight(
    String id, {
    double? weightKg,
    double? labelTotal,
    double? pricePerKg,
  }) {
    _update(
      id,
      (i) => i.copyWith(
        weightKg: weightKg,
        labelTotal: labelTotal,
        pricePerKgOverride:
            (pricePerKg != null && pricePerKg != i.quote.pricePerKg)
            ? pricePerKg
            : null,
      ),
    );
  }

  void clear() => _set(const []);

  void toggleTaken(String id) =>
      _update(id, (i) => i.copyWith(taken: !i.taken));

  void clearTaken() => _set([for (final i in state) i.copyWith(taken: false)]);

  /// La riga si comprerà in un altro negozio: si usa il suo prezzo.
  /// Il totale dell'etichetta della bilancia non vale più, il peso sì.
  void moveTo(String id, PriceQuote quote) => _update(
    id,
    (i) => i.copyWith(quote: quote, labelTotal: null, pricePerKgOverride: null),
  );

  void _update(String id, CartItem Function(CartItem) f) {
    final idx = state.indexWhere((i) => i.id == id);
    if (idx < 0) return;
    _set([...state]..[idx] = f(state[idx]));
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

/// Filtro della lista per negozio (id di [PriceStore], null = tutti).
class CartFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? v) => state = v;
}

final cartFilterProvider = NotifierProvider<CartFilterNotifier, String?>(
  CartFilterNotifier.new,
);

/// Nome del negozio da cui viene il prezzo di una riga.
String storeLabelOf(PriceQuote q, List<PriceStore> stores) {
  final id = PriceStore.idOfQuote(q);
  final s = stores.where((s) => s.id == id).firstOrNull;
  if (s != null) return s.shortLabel;
  return q.storeId == null
      ? '${q.chain.label} online'
      : '${q.chain.label} ${q.storeId}';
}

final cartTotalsProvider = Provider<CartTotals>(
  (ref) => cartTotals(ref.watch(cartProvider)),
);

/// Prezzi delle righe del carrello in tutti i negozi selezionati, con chiave
/// `storeQuoteKey(negozio, riga)`. Le letture partono una alla volta per
/// client; i prezzi Poli dei negozi non attivi arrivano solo dalla cache.
String storeQuoteKey(String storeId, String itemId) => '$storeId|$itemId';

class StoreQuotesNotifier extends Notifier<Map<String, StoreQuote>> {
  bool _running = false;

  @override
  Map<String, StoreQuote> build() {
    ref.listen(cartProvider, (_, _) => _fill());
    ref.listen(selectedStoresProvider, (_, _) => _fill());
    ref.listen(sessionProvider, (a, b) {
      if (a?.storeId != b.storeId) refresh();
    });
    Future.microtask(_fill);
    return const {};
  }

  /// Prezzi già letti durante una scansione.
  void prefill(String itemId, Map<String, StoreQuote> byStore) {
    state = {
      ...state,
      for (final e in byStore.entries) storeQuoteKey(e.key, itemId): e.value,
    };
  }

  /// Sposta la riga nel negozio [s] usando il prezzo letto lì; il prezzo
  /// del negozio di prima resta disponibile per il confronto.
  void moveItem(CartItem item, PriceStore s) {
    final q = quoteIn(s, item, state);
    if (q == null) return;
    final old = PriceStore.idOfQuote(item.quote);
    state = {
      ...state,
      storeQuoteKey(old, item.id): QuoteFound(
        LookupResult(item.product, item.quote),
      ),
    };
    ref.read(cartProvider.notifier).moveTo(item.id, q);
  }

  /// Sposta ogni riga nel negozio selezionato dove costa meno (fra quelli con
  /// un prezzo: per Everli solo gli abbinamenti confermati).
  int moveAllToCheapest() {
    var moved = 0;
    final stores = ref.read(selectedStoresProvider);
    for (final item in ref.read(cartProvider)) {
      if (item.product.productId <= 0) continue;
      PriceStore? best;
      var bestNet = lineTotals(item).net;
      for (final s in stores) {
        final q = quoteIn(s, item, state);
        if (q == null || q == item.quote) continue;
        final net = lineTotals(item, quote: q).net;
        if (net < bestNet - 0.001) {
          best = s;
          bestNet = net;
        }
      }
      if (best != null) {
        moveItem(
          ref.read(cartProvider).firstWhere((i) => i.id == item.id),
          best,
        );
        moved++;
      }
    }
    return moved;
  }

  /// Prezzo inserito a mano (Aldi). Con [price] null lo toglie. Se la riga
  /// si compra già in quel negozio, ne aggiorna anche il prezzo.
  Future<void> setManualPrice(
    PriceStore s,
    CartItem item, {
    double? price,
    double? pricePerKg,
  }) async {
    final q = await ref
        .read(priceServiceProvider)
        .setManualPrice(
          s,
          item.product.barcode,
          item.product,
          price: price,
          pricePerKg: pricePerKg,
        );
    state = {...state, storeQuoteKey(s.id, item.id): q};
    if (q is QuoteFound && PriceStore.idOfQuote(item.quote) == s.id) {
      ref.read(cartProvider.notifier).moveTo(item.id, q.result.quote);
    }
  }

  /// L'utente conferma che [p] (Everli) è lo stesso prodotto della riga.
  /// L'abbinamento vale per tutti i negozi Everli: gli altri si rileggono
  /// per id.
  Future<void> confirmMatch(PriceStore s, CartItem item, Product p) async {
    await ref
        .read(priceServiceProvider)
        .setEverliMatch(item.product.barcode, p);
    state = {
      for (final e in state.entries)
        if (!_isEverliKeyOf(e.key, item)) e.key: e.value,
      storeQuoteKey(s.id, item.id): QuoteFound(
        LookupResult(
          p,
          p.quote(PriceSource.online, DateTime.now(), storeId: s.storeId),
        ),
      ),
    };
    _fill();
  }

  bool _isEverliKeyOf(String key, CartItem item) =>
      key.endsWith('|${item.id}') &&
      Chain.values.any((c) => c.isEverli && key.startsWith('${c.name}:'));

  /// Toglie l'abbinamento e ripropone i prodotti simili.
  Future<void> removeMatch(PriceStore s, CartItem item) async {
    await ref
        .read(priceServiceProvider)
        .setEverliMatch(item.product.barcode, null);
    state = {
      for (final e in state.entries)
        if (!_isEverliKeyOf(e.key, item)) e.key: e.value,
    };
    _fill();
  }

  /// Rilegge le righe senza prezzo (errori, negozi non disponibili).
  void refresh() {
    state = {
      for (final e in state.entries)
        if (e.value is QuoteFound || e.value is QuoteNotFound) e.key: e.value,
    };
    _fill();
  }

  Future<void> _fill() async {
    if (_running) return;
    _running = true;
    try {
      while (true) {
        final stores = ref.read(selectedStoresProvider);
        (PriceStore, CartItem)? todo;
        for (final item in ref.read(cartProvider)) {
          if (item.product.productId <= 0) continue;
          for (final s in stores) {
            if (s.id == PriceStore.idOfQuote(item.quote)) continue;
            if (!state.containsKey(storeQuoteKey(s.id, item.id))) {
              todo = (s, item);
              break;
            }
          }
          if (todo != null) break;
        }
        if (todo == null) break;
        final (store, item) = todo;
        final q = await ref
            .read(priceServiceProvider)
            .quote(store, item.product.barcode, reference: item.product);
        state = {...state, storeQuoteKey(store.id, item.id): q};
      }
    } finally {
      _running = false;
    }
  }
}

final storeQuotesProvider =
    NotifierProvider<StoreQuotesNotifier, Map<String, StoreQuote>>(
      StoreQuotesNotifier.new,
    );

/// Prezzo di una riga in un negozio: quello della riga stessa se viene da lì.
PriceQuote? quoteIn(
  PriceStore s,
  CartItem item,
  Map<String, StoreQuote> quotes,
) {
  if (s.id == PriceStore.idOfQuote(item.quote)) return item.quote;
  final q = quotes[storeQuoteKey(s.id, item.id)];
  return q is QuoteFound ? q.result.quote : null;
}

class StoreTotal {
  const StoreTotal(
    this.store, {
    required this.total,
    required this.here,
    required this.matched,
    required this.count,
    this.unavailable,
  });
  final PriceStore store;

  /// Totale nel negozio, solo sulle righe con un prezzo lì.
  final double total;

  /// Le stesse righe al prezzo del carrello.
  final double here;
  final int matched;
  final int count;

  /// Il negozio non si può leggere adesso.
  final String? unavailable;

  int get missing => count - matched;
  bool get complete => matched == count && count > 0;
  double get diff => round2(total - here);
}

/// Totale del carrello in ogni negozio selezionato, calcolato solo sulle
/// righe abbinate (per Everli: abbinamenti confermati).
final storeTotalsProvider = Provider<List<StoreTotal>>((ref) {
  final items = ref
      .watch(cartProvider)
      .where((i) => i.product.productId > 0)
      .toList();
  final quotes = ref.watch(storeQuotesProvider);
  final svc = ref.watch(priceServiceProvider);
  ref.watch(sessionProvider);
  return [
    for (final s in ref.watch(selectedStoresProvider))
      () {
        var total = 0.0, here = 0.0, matched = 0;
        for (final i in items) {
          final q = quoteIn(s, i, quotes);
          if (q == null) continue;
          matched++;
          total += lineTotals(i, quote: q).net;
          here += lineTotals(i).net;
        }
        return StoreTotal(
          s,
          total: round2(total),
          here: round2(here),
          matched: matched,
          count: items.length,
          unavailable: matched == 0 ? svc.unavailableReason(s) : null,
        );
      }(),
  ];
});

// ---- listino offline -------------------------------------------------------

@immutable
class OfflineInfo {
  const OfflineInfo(this.count, this.downloadedAt);
  final int count;
  final DateTime? downloadedAt;
}

final offlineInfoProvider = FutureProvider.family<OfflineInfo, Chain>((
  ref,
  chain,
) async {
  final db = ref.watch(dbProvider);
  final repo = ref.watch(productRepoProvider(chain));
  final at = await db.getValue(repo.downloadedAtKey);
  return OfflineInfo(await db.catalogCount(chain), DateTime.tryParse(at ?? ''));
});

/// Punti di ritiro Click&Coop (i prezzi non dipendono dal punto scelto).
final coopPickupProvider = FutureProvider<List<Store>>(
  (ref) => ref.watch(apiProvider(Chain.coop)).deliveryServiceList(),
);
