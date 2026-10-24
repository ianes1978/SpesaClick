import 'package:flutter/foundation.dart';

import '../domain/chain.dart';
import '../domain/price_store.dart';
import 'api_exceptions.dart';
import 'ebsn_api.dart';
import 'product_repository.dart';

/// Esito della lettura di un prezzo in un negozio.
sealed class StoreQuote {
  const StoreQuote();
}

class QuoteFound extends StoreQuote {
  const QuoteFound(this.result);
  final LookupResult result;
}

class QuoteNotFound extends StoreQuote {
  const QuoteNotFound();
}

/// Il prezzo non si può leggere adesso (es. negozio Poli diverso da quello
/// attivo nel carrello DupliClick, senza prezzo in cache).
class QuoteUnavailable extends StoreQuote {
  const QuoteUnavailable(this.reason);
  final String reason;
}

class QuoteFailed extends StoreQuote {
  const QuoteFailed(this.message);
  final String message;
}

/// Legge prezzi e risultati di ricerca da un qualsiasi [PriceStore].
///
/// * Poli, listino online → client DupliClick **senza** sessione.
/// * Poli, punto vendita → client con sessione, solo se è il negozio attivo
///   nel carrello DupliClick; per gli altri negozi si usano i prezzi in cache
///   letti con "Aggiorna prezzi Poli" (che sposta il carrello e lo ripristina).
/// * Coop → listino online Click&Coop (uguale per tutti i punti di ritiro).
class PriceService {
  PriceService({
    required this.poliOnline,
    required this.poliSession,
    required this.coop,
    required this.cartStoreId,
  });

  final ProductRepository poliOnline;
  final ProductRepository poliSession;
  final ProductRepository coop;

  /// Negozio attivo nel carrello DupliClick, null se non collegato.
  final int? Function() cartStoreId;

  /// Il negozio risponde in diretta (ricerca testuale compresa)?
  bool isLive(PriceStore s) =>
      s.chain == Chain.coop || s.isOnline || s.storeId == cartStoreId();

  String? unavailableReason(PriceStore s) {
    if (isLive(s)) return null;
    return cartStoreId() == null
        ? 'Collega DupliClick per i prezzi di ${s.shortLabel}'
        : 'Prezzi di ${s.shortLabel} da aggiornare (cambio negozio)';
  }

  ProductRepository _repo(PriceStore s) => switch (s.chain) {
    Chain.coop => coop,
    Chain.poli => s.isOnline ? poliOnline : poliSession,
  };

  Future<StoreQuote> quote(PriceStore s, String code) async {
    try {
      if (!isLive(s)) {
        final q = await poliSession.cachedQuote(s.storeId!, code);
        if (q == null) return QuoteUnavailable(unavailableReason(s)!);
        final cached = await poliSession.cachedProduct(s.storeId!, code);
        return cached == null
            ? QuoteUnavailable(unavailableReason(s)!)
            : QuoteFound(LookupResult(cached, q));
      }
      final r = await _repo(s).lookup(code);
      return r == null ? const QuoteNotFound() : QuoteFound(r);
    } on ApiException catch (e) {
      debugPrint('Prezzo ${s.shortLabel} per $code: $e');
      return QuoteFailed(e.message);
    }
  }

  /// Ricerca testuale in un negozio "in diretta".
  Future<({ProductPage page, bool offline})> search(
    PriceStore s,
    String q, {
    int page = 1,
  }) => _repo(s).search(q, page: page);

  Future<ProductPage> byCategory(
    PriceStore s,
    int categoryId, {
    int page = 1,
  }) => _repo(s).byCategory(categoryId, page: page);
}
