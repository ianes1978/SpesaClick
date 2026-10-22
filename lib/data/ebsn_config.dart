import '../domain/chain.dart';

/// Configurazione di una catena sulla piattaforma ebsn di Digitelematica.
class EbsnConfig {
  const EbsnConfig({
    required this.chain,
    required this.origin,
    required this.minInterval,
    required this.maxRetries,
    required this.retryServerErrors,
    this.extraHeaders = const {},
    this.supportsSession = false,
    this.emptyQueryListsAll = false,
    this.decodesScaleLabels = false,
    this.preferOfflineWithoutSession = false,
  });

  final Chain chain;
  final String origin;

  /// Pausa minima fra due richieste (mai in parallelo).
  final Duration minInterval;

  /// Nuovi tentativi dopo il primo.
  final int maxRetries;

  /// Ritenta anche quando il server risponde `status != 0` (Click&Coop
  /// fallisce a intermittenza con "Si è verificato un errore nella richiesta").
  final bool retryServerErrors;

  final Map<String, String> extraHeaders;

  /// Login con sessione (`X-Ebsn-Session`, `cart/view`, cambio negozio).
  final bool supportsSession;

  /// `products?q=` vuoto restituisce l'intero listino.
  final bool emptyQueryListsAll;

  /// Etichette della bilancia "2 + articolo + prezzo" verificate per la catena.
  final bool decodesScaleLabels;

  /// Senza sessione lo scanner usa prima il listino offline.
  final bool preferOfflineWithoutSession;

  String get baseUrl => '$origin/ebsn/api';
  Uri get cookieUri => Uri.parse('$origin/ebsn/');

  /// Attesa prima del tentativo n (1, 2, …): 0,5 s, 1,5 s, 2,5 s…
  Duration backoff(int attempt) =>
      Duration(milliseconds: 500 + 1000 * (attempt - 1));

  static const poli = EbsnConfig(
    chain: Chain.poli,
    origin: 'https://www.dupliclick.it',
    minInterval: Duration(milliseconds: 300),
    maxRetries: 1,
    retryServerErrors: false,
    extraHeaders: {'X-Ebsn-Client-Redirect': 'production'},
    supportsSession: true,
    emptyQueryListsAll: true,
    decodesScaleLabels: true,
    preferOfflineWithoutSession: true,
  );

  static const coop = EbsnConfig(
    chain: Chain.coop,
    origin: 'https://www.clickcoop.it',
    minInterval: Duration(milliseconds: 450),
    maxRetries: 5,
    retryServerErrors: true,
    extraHeaders: {'User-Agent': 'SpesaTrento (uso personale)'},
  );

  static EbsnConfig of(Chain c) => c == Chain.poli ? poli : coop;
}
