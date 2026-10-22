import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_exceptions.dart';
import '../data/database.dart';
import '../data/ebsn_api.dart';
import '../data/ebsn_config.dart';
import '../data/product_repository.dart';
import '../data/session_storage.dart';
import '../data/store_repository.dart';
import '../domain/cart_item.dart';
import '../domain/cart_math.dart';
import '../domain/chain.dart';
import '../domain/ean.dart';
import '../domain/price_quote.dart';
import '../domain/store.dart';

// ---- infrastruttura ---------------------------------------------------------

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final sessionStorageProvider = Provider<SessionStorage>((_) => SessionStorage());

/// Un client per catena (ognuno con il suo rate limit).
final apiProvider = Provider.family<EbsnApi, Chain>((ref, chain) {
  if (chain == Chain.coop) return EbsnApi(EbsnConfig.coop);
  return EbsnApi(
    EbsnConfig.poli,
    onSessionChanged: (s) => ref.read(sessionStorageProvider).save(s),
    onSessionExpired: () =>
        Future.microtask(() => ref.read(sessionProvider.notifier).markExpired()),
  );
});

final productRepoProvider =
    Provider.family<ProductRepository, Chain>((ref, chain) {
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

/// Catena in cui si sta facendo la spesa (scanner e catalogo).
class ActiveChainNotifier extends Notifier<Chain> {
  static const _key = 'active_chain';

  @override
  Chain build() {
    Future.microtask(() async {
      final v = await ref.read(dbProvider).getValue(_key);
      final c = Chain.values.where((c) => c.name == v).firstOrNull;
      if (c != null) state = c;
    });
    return Chain.poli;
  }

  void set(Chain c) {
    state = c;
    ref.read(dbProvider).setValue(_key, c.name);
  }
}

final activeChainProvider =
    NotifierProvider<ActiveChainNotifier, Chain>(ActiveChainNotifier.new);

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
    debugPrint('Sessione DupliClick: JSESSIONID=${s.jsessionId != null}, '
        'X-Ebsn-Session=${s.ebsnSession != null}, '
        'X-Ebsn-Account=${s.ebsnAccount != null}');
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

final sessionProvider =
    NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

final storesProvider = FutureProvider<List<Store>>(
    (ref) => ref.watch(storeRepoProvider).trentoStores());

/// Negozio con cui confrontare il carrello: l'altro dei due di Trento.
final compareStoreProvider = Provider<Store>((ref) {
  final cur = ref.watch(sessionProvider).storeId;
  return cur == kIperPoliTrentoId ? kKnownTrentoStores[1] : kKnownTrentoStores[0];
});

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
    final id = label?.raw ?? '${r.product.chain.name}:${r.product.barcode}';
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
      (i) => i.copyWith(
          discountPercent: i.discountPercent == pct ? 0 : pct));

  void setWeight(String id,
      {double? weightKg, double? labelTotal, double? pricePerKg}) {
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

  void _update(String id, CartItem Function(CartItem) f) {
    final idx = state.indexWhere((i) => i.id == id);
    if (idx < 0) return;
    _set([...state]..[idx] = f(state[idx]));
  }
}

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartTotalsProvider =
    Provider<CartTotals>((ref) => cartTotals(ref.watch(cartProvider)));

/// Prezzi in cache dell'altro negozio Poli per gli articoli Poli nel carrello.
final otherQuotesProvider =
    FutureProvider<Map<String, PriceQuote>>((ref) async {
  final items = ref.watch(cartProvider);
  final other = ref.watch(compareStoreProvider);
  return ref.read(storeRepoProvider).cachedQuotes(
      other.addressId,
      items
          .where((i) => i.product.chain == Chain.poli)
          .map((i) => i.product.barcode));
});

/// Prezzi dell'altra catena (Coop per le righe Poli e viceversa), per
/// `CartItem.id`. Un valore null significa "non a listino". Le richieste
/// partono una alla volta, con cache di 6 ore.
class CrossChainNotifier extends Notifier<Map<String, PriceQuote?>> {
  final _failed = <String>{};
  bool _running = false;

  @override
  Map<String, PriceQuote?> build() {
    ref.listen(cartProvider, (_, _) => _fill());
    Future.microtask(_fill);
    return const {};
  }

  /// Riprova anche le righe andate in errore.
  void refresh() {
    _failed.clear();
    _fill();
  }

  Future<void> _fill() async {
    if (_running) return;
    _running = true;
    try {
      while (true) {
        final todo = ref
            .read(cartProvider)
            .where((i) =>
                i.product.productId > 0 &&
                !state.containsKey(i.id) &&
                !_failed.contains(i.id))
            .firstOrNull;
        if (todo == null) break;
        final other = todo.product.chain.other;
        try {
          final r =
              await ref.read(productRepoProvider(other)).lookup(todo.product.barcode);
          state = {...state, todo.id: r?.quote};
        } on ApiException catch (e) {
          debugPrint('Prezzo ${other.serviceName} per ${todo.product.barcode}: $e');
          _failed.add(todo.id);
        }
      }
    } finally {
      _running = false;
    }
  }
}

final crossChainProvider =
    NotifierProvider<CrossChainNotifier, Map<String, PriceQuote?>>(
        CrossChainNotifier.new);

// ---- listino offline -------------------------------------------------------

@immutable
class OfflineInfo {
  const OfflineInfo(this.count, this.downloadedAt);
  final int count;
  final DateTime? downloadedAt;
}

final offlineInfoProvider =
    FutureProvider.family<OfflineInfo, Chain>((ref, chain) async {
  final db = ref.watch(dbProvider);
  final repo = ref.watch(productRepoProvider(chain));
  final at = await db.getValue(repo.downloadedAtKey);
  return OfflineInfo(
      await db.catalogCount(chain), DateTime.tryParse(at ?? ''));
});

/// Punti di ritiro Click&Coop (i prezzi non dipendono dal punto scelto).
final coopPickupProvider = FutureProvider<List<Store>>(
    (ref) => ref.watch(apiProvider(Chain.coop)).deliveryServiceList());
