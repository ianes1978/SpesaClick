import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_exceptions.dart';
import '../data/database.dart';
import '../data/dupliclick_api.dart';
import '../data/product_repository.dart';
import '../data/session_storage.dart';
import '../data/store_repository.dart';
import '../domain/cart_item.dart';
import '../domain/cart_math.dart';
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

final apiProvider = Provider<DupliclickApi>((ref) {
  return DupliclickApi(
    onSessionChanged: (s) => ref.read(sessionStorageProvider).save(s),
    onSessionExpired: () =>
        Future.microtask(() => ref.read(sessionProvider.notifier).markExpired()),
  );
});

final productRepoProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    api: ref.watch(apiProvider),
    db: ref.watch(dbProvider),
    currentStoreId: () => ref.read(sessionProvider).storeId,
  );
});

final storeRepoProvider = Provider<StoreRepository>((ref) {
  return StoreRepository(
    api: ref.watch(apiProvider),
    db: ref.watch(dbProvider),
    products: ref.watch(productRepoProvider),
  );
});

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

  DupliclickApi get _api => ref.read(apiProvider);
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

/// Prezzi in cache dell'altro negozio per gli articoli nel carrello.
final otherQuotesProvider =
    FutureProvider<Map<String, PriceQuote>>((ref) async {
  final items = ref.watch(cartProvider);
  final other = ref.watch(compareStoreProvider);
  return ref
      .read(storeRepoProvider)
      .cachedQuotes(other.addressId, items.map((i) => i.product.barcode));
});

// ---- listino offline -------------------------------------------------------

@immutable
class OfflineInfo {
  const OfflineInfo(this.count, this.downloadedAt);
  final int count;
  final DateTime? downloadedAt;
}

final offlineInfoProvider = FutureProvider<OfflineInfo>((ref) async {
  final db = ref.watch(dbProvider);
  final at = await db.getValue('catalog_downloaded_at');
  return OfflineInfo(await db.catalogCount(), DateTime.tryParse(at ?? ''));
});
