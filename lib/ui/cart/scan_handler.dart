import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/price_service.dart';
import '../../data/product_repository.dart';
import '../../domain/cart_item.dart';
import '../../domain/chain.dart';
import '../../domain/ean.dart';
import '../../domain/price_quote.dart';
import '../../domain/price_store.dart';
import '../../domain/product.dart';
import '../providers.dart';
import 'store_choice_sheet.dart';
import 'weight_dialog.dart';

/// Esito di una scansione (o di un inserimento manuale).
sealed class ScanOutcome {
  const ScanOutcome();
}

class ScanAdded extends ScanOutcome {
  const ScanAdded(this.item, {required this.isLabel, this.store});
  final CartItem item;
  final bool isLabel;
  final PriceStore? store;

  /// Prodotto a peso senza peso né totale: va chiesto all'utente.
  bool get needsWeight =>
      item.isVariableWeight && item.weightKg == null && item.labelTotal == null;
}

class ScanNotFound extends ScanOutcome {
  const ScanNotFound(this.code, {this.detail});
  final String code;
  final String? detail;
}

/// Codice della bilancia (inizia con 2) non trovato: si chiede all'utente
/// il peso o il totale.
class ScanNeedsWeight extends ScanOutcome {
  const ScanNeedsWeight(this.code, this.chain);
  final String code;
  final Chain chain;
}

class ScanError extends ScanOutcome {
  const ScanError(this.message);
  final String message;
}

class ScanCancelled extends ScanOutcome {
  const ScanCancelled();
}

/// Cerca il codice in tutti i negozi selezionati. Se il prodotto c'è in più
/// negozi fa scegliere il prezzo (o usa il primo negozio della lista, se
/// l'utente ha disattivato la domanda), lo aggiunge al carrello e completa
/// peso/totale quando servono.
Future<ScanOutcome> processScan(
  BuildContext context,
  WidgetRef ref,
  String raw,
) async {
  final code = raw.trim();
  if (!isDigits(code)) return ScanNotFound(code);
  final stores = ref.read(selectedStoresProvider);
  if (stores.isEmpty) {
    return const ScanError('Nessun negozio selezionato: aggiungine uno.');
  }
  // Etichette della bilancia verificate solo per Poli.
  final label = ScaleLabel.tryParse(code);
  final svc = ref.read(priceServiceProvider);
  final results = await Future.wait([
    for (final s in stores)
      svc.quote(
        s,
        s.chain == Chain.poli && label != null ? label.lookupBarcode : code,
      ),
  ]);
  final byStore = {
    for (var i = 0; i < stores.length; i++) stores[i].id: results[i],
  };
  final found = <(PriceStore, LookupResult)>[
    for (var i = 0; i < stores.length; i++)
      if (results[i] case QuoteFound(:final result)) (stores[i], result),
  ];

  if (found.isEmpty) {
    final failed = results.whereType<QuoteFailed>().firstOrNull;
    if (code.length == 13 && code.startsWith('2')) {
      final chain =
          stores.where((s) => !s.chain.isEverli).firstOrNull?.chain ??
          Chain.poli;
      final outcome = ScanNeedsWeight(code, chain);
      if (!context.mounted) return outcome;
      return await completeWeight(context, ref, outcome)
          ? outcome
          : const ScanCancelled();
    }
    if (failed != null &&
        results.every(
          (r) =>
              r is QuoteFailed || r is QuoteUnavailable || r is QuoteNotFound,
        ) &&
        results.any((r) => r is QuoteFailed)) {
      return ScanError(failed.message);
    }
    final unavailable = results.whereType<QuoteUnavailable>().firstOrNull;
    return ScanNotFound(code, detail: unavailable?.reason);
  }

  var choice = 0;
  if (found.length > 1 && ref.read(askStoreChoiceProvider)) {
    if (!context.mounted) return const ScanCancelled();
    final c = await showStoreChoice(context, found);
    if (c == null) return const ScanCancelled();
    choice = c;
  }
  final (store, result) = found[choice];
  final usedLabel = store.chain == Chain.poli ? label : null;
  final item = ref.read(cartProvider.notifier).add(result, label: usedLabel);
  ref.read(storeQuotesProvider.notifier).prefill(item.id, byStore);
  final outcome = ScanAdded(item, isLabel: usedLabel != null, store: store);
  if (outcome.needsWeight && context.mounted) {
    await completeWeight(context, ref, outcome);
  }
  return outcome;
}

/// Aggiunge un prodotto scelto dal catalogo (stesse regole della scansione).
Future<void> addFromCatalog(
  BuildContext context,
  WidgetRef ref,
  List<(PriceStore, LookupResult)> options,
) async {
  var choice = 0;
  if (options.length > 1 && ref.read(askStoreChoiceProvider)) {
    final c = await showStoreChoice(context, options);
    if (c == null) return;
    choice = c;
  }
  final (store, r) = options[choice];
  final item = ref.read(cartProvider.notifier).add(r);
  ref.read(storeQuotesProvider.notifier).prefill(item.id, {
    for (final (s, o) in options) s.id: QuoteFound(o),
  });
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 1),
      content: Text('Aggiunto: ${r.product.name} (${store.shortLabel})'),
    ),
  );
  final outcome = ScanAdded(item, isLabel: false, store: store);
  if (outcome.needsWeight) await completeWeight(context, ref, outcome);
}

/// Completa un esito che richiede il peso: per i prodotti a peso appena
/// aggiunti chiede peso/totale, per i codici bilancia sconosciuti crea una
/// riga "Articolo a peso". Restituisce false se l'utente annulla.
Future<bool> completeWeight(
  BuildContext context,
  WidgetRef ref,
  ScanOutcome outcome,
) async {
  switch (outcome) {
    case ScanAdded(:final item) when outcome.needsWeight:
      final r = await showWeightDialog(context, item);
      if (r == null) return false;
      ref
          .read(cartProvider.notifier)
          .setWeight(
            item.id,
            weightKg: r.weightKg,
            labelTotal: r.total,
            pricePerKg: r.pricePerKg,
          );
      return true;
    case ScanNeedsWeight(:final code, :final chain):
      final now = DateTime.now();
      final placeholder = CartItem(
        id: 'manuale:$code:${now.millisecondsSinceEpoch}',
        product: Product(
          productId: -1,
          barcode: code,
          name: 'Articolo a peso ($code)',
          tipologia: 'Sfuso',
          price: 0,
          chain: chain,
        ),
        quote: PriceQuote(
          price: 0,
          source: PriceSource.label,
          readAt: now,
          chain: chain,
        ),
        addedAt: now,
      );
      final r = await showWeightDialog(
        context,
        placeholder,
        title:
            'Codice bilancia non riconosciuto: inserisci il totale '
            "stampato sull'etichetta oppure peso e prezzo al kg.",
      );
      if (r == null) return false;
      final total =
          r.total ??
          ((r.weightKg != null && r.pricePerKg != null)
              ? double.parse((r.weightKg! * r.pricePerKg!).toStringAsFixed(2))
              : null);
      if (total == null) return false;
      ref
          .read(cartProvider.notifier)
          .addManual(
            placeholder.copyWith(
              labelTotal: total,
              weightKg: r.weightKg,
              pricePerKgOverride: r.pricePerKg,
              quote: placeholder.quote.copyWith(price: total),
            ),
          );
      return true;
    default:
      return true;
  }
}

/// Codici d'esempio per "Simula scansione".
const kSampleCodes = <(String, String)>[
  ('8007049920131', 'Mousse Melinda mela e banana'),
  ('8013755002023', 'Trentingrana grattugiato 80 g'),
  ('2060120000000', 'Trentingrana sfuso Poli (codice di listino)'),
  ('2060120012343', 'Etichetta bilancia Poli Trentingrana 12,34 €'),
  ('2877992', 'Trentingrana 20 mesi sfuso Coop (codice interno)'),
  ('0000000000000', 'Codice inesistente'),
];
