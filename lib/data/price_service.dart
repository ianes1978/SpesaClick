import 'package:flutter/foundation.dart';

import '../domain/chain.dart';
import '../domain/ean.dart';
import '../domain/price_quote.dart';
import '../domain/price_store.dart';
import '../domain/product.dart';
import 'api_exceptions.dart';
import 'ebsn_api.dart';
import 'everli_repository.dart';
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

/// Everli: nessun abbinamento confermato, ma prodotti simili da proporre.
/// Non entrano nei totali finché l'utente non conferma.
class QuoteSimilar extends StoreQuote {
  const QuoteSimilar(this.candidates);
  final List<ScoredProduct> candidates;
}

/// Negozio a prezzi manuali (Aldi) senza un prezzo per questo articolo.
class QuoteManualMissing extends StoreQuote {
  const QuoteManualMissing();
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
/// * Lidl / MD → Everli: niente EAN. Vale l'abbinamento confermato
///   dall'utente; altrimenti si propongono prodotti simili al riferimento.
class PriceService {
  PriceService({
    required this.poliOnline,
    required this.poliSession,
    required this.coop,
    required this.everli,
    required this.cartStoreId,
  });

  final ProductRepository poliOnline;
  final ProductRepository poliSession;
  final ProductRepository coop;
  final EverliRepository everli;

  /// Negozio attivo nel carrello DupliClick, null se non collegato.
  final int? Function() cartStoreId;

  /// Il negozio risponde in diretta (ricerca testuale compresa)?
  bool isLive(PriceStore s) =>
      s.chain != Chain.poli || s.isOnline || s.storeId == cartStoreId();

  String? unavailableReason(PriceStore s) {
    if (isLive(s)) return null;
    return cartStoreId() == null
        ? 'Collega DupliClick per i prezzi di ${s.shortLabel}'
        : 'Prezzi di ${s.shortLabel} da aggiornare (cambio negozio)';
  }

  ProductRepository _repo(PriceStore s) => switch (s.chain) {
    Chain.coop => coop,
    Chain.poli => s.isOnline ? poliOnline : poliSession,
    Chain.lidl || Chain.md || Chain.pam || Chain.aldi => throw ArgumentError(
      '${s.chain.label} non ha un listino per EAN',
    ),
  };

  /// Prezzo di [code] nel negozio [s]. Per Everli serve [reference]: il
  /// prodotto trovato per EAN altrove, da cui si cercano gli equivalenti.
  Future<StoreQuote> quote(
    PriceStore s,
    String code, {
    Product? reference,
  }) async {
    try {
      if (s.chain.isEverli) return await _everliQuote(s, code, reference);
      if (s.chain.isManual) return await _manualQuote(s, code);
      if (!isDigits(code)) return const QuoteNotFound();
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

  Future<StoreQuote> _everliQuote(
    PriceStore s,
    String code,
    Product? reference,
  ) async {
    final storeId = s.storeId!;
    final matched = await everli.match(code, storeId);
    if (matched != null) {
      final r = await everli.product(storeId, s.chain, matched);
      if (r != null) {
        return QuoteFound(
          LookupResult(
            r.product,
            r.product.quote(PriceSource.online, r.readAt, storeId: storeId),
          ),
        );
      }
    }
    if (reference == null) {
      return const QuoteUnavailable(
        'Everli non ha EAN: serve il nome del prodotto da un altro negozio',
      );
    }
    final c = await everli.equivalents(storeId, s.chain, reference);
    return c.isEmpty ? const QuoteNotFound() : QuoteSimilar(c);
  }

  static const manualKey = 'manual';

  Future<StoreQuote> _manualQuote(PriceStore s, String code) async {
    final c = await poliSession.db.cachedPrice(s.chain, manualKey, code);
    if (c == null) return const QuoteManualMissing();
    return QuoteFound(
      LookupResult(c.product, c.product.quote(PriceSource.manual, c.readAt)),
    );
  }

  /// Salva (o toglie, con [price] null) il prezzo inserito a mano per
  /// [code] nel negozio manuale [s]. Il prezzo resta finché non lo cambi.
  Future<StoreQuote> setManualPrice(
    PriceStore s,
    String code,
    Product product, {
    double? price,
    double? pricePerKg,
  }) async {
    final db = poliSession.db;
    if (price == null) {
      await db.deletePrice(s.chain, manualKey, code);
      return const QuoteManualMissing();
    }
    final p = product.copyWith(
      chain: s.chain,
      barcode: code,
      price: price,
      listPrice: null,
      pricePerKg: pricePerKg,
    );
    final now = DateTime.now();
    await db.putPrice(manualKey, p, now);
    return QuoteFound(LookupResult(p, p.quote(PriceSource.manual, now)));
  }

  /// La ricerca testuale si può fare in questo negozio?
  bool isSearchable(PriceStore s) => isLive(s) && !s.chain.isManual;

  /// Conferma (o toglie, con null) l'abbinamento di [code] a un prodotto
  /// Everli del negozio [s].
  Future<void> setEverliMatch(PriceStore s, String code, Product? p) =>
      everli.setMatch(code, s.storeId!, p?.productId);

  /// Ricerca testuale in un negozio "in diretta".
  Future<({ProductPage page, bool offline})> search(
    PriceStore s,
    String q, {
    int page = 1,
  }) async {
    if (s.chain.isEverli) {
      final r = await everli.search(s.storeId!, s.chain, q, page: page);
      return (
        page: ProductPage(
          products: r.products,
          page: page,
          totPages: r.hasMore ? page + 1 : page,
          totItems: r.products.length,
        ),
        offline: false,
      );
    }
    return _repo(s).search(q, page: page);
  }

  Future<ProductPage> byCategory(
    PriceStore s,
    int categoryId, {
    int page = 1,
  }) => _repo(s).byCategory(categoryId, page: page);
}
