import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api_exceptions.dart';
import '../../data/ebsn_config.dart';
import '../../domain/cart_item.dart';
import '../../domain/chain.dart';
import '../../domain/ean.dart';
import '../../domain/price_quote.dart';
import '../../domain/product.dart';
import '../providers.dart';
import 'weight_dialog.dart';

/// Esito di una scansione (o di un inserimento manuale).
sealed class ScanOutcome {
  const ScanOutcome();
}

class ScanAdded extends ScanOutcome {
  const ScanAdded(this.item, {required this.isLabel});
  final CartItem item;
  final bool isLabel;

  /// Prodotto a peso senza peso né totale: va chiesto all'utente.
  bool get needsWeight =>
      item.isVariableWeight && item.weightKg == null && item.labelTotal == null;
}

class ScanNotFound extends ScanOutcome {
  const ScanNotFound(this.code);
  final String code;
}

/// Codice della bilancia (inizia con 2) non decodificabile per la catena:
/// si chiede all'utente il peso o il totale.
class ScanNeedsWeight extends ScanOutcome {
  const ScanNeedsWeight(this.code, this.chain);
  final String code;
  final Chain chain;
}

class ScanError extends ScanOutcome {
  const ScanError(this.message);
  final String message;
}

/// Cerca il codice nella catena attiva e lo aggiunge al carrello.
/// Una sola chiamata per scansione (più le varianti UPC→EAN quando servono).
Future<ScanOutcome> handleScannedCode(WidgetRef ref, String raw) async {
  final code = raw.trim();
  if (!isDigits(code)) return ScanNotFound(code);
  final chain = ref.read(activeChainProvider);
  final config = EbsnConfig.of(chain);
  // Le etichette della bilancia sono verificate solo per Poli: su Coop il
  // prezzo NON va decodificato dal codice.
  final label = config.decodesScaleLabels ? ScaleLabel.tryParse(code) : null;
  final repo = ref.read(productRepoProvider(chain));
  try {
    final r = await repo.lookup(label?.lookupBarcode ?? code);
    if (r == null) {
      if (!config.decodesScaleLabels && code.length == 13 && code.startsWith('2')) {
        return ScanNeedsWeight(code, chain);
      }
      return ScanNotFound(code);
    }
    final item = ref.read(cartProvider.notifier).add(r, label: label);
    return ScanAdded(item, isLabel: label != null);
  } on ApiException catch (e) {
    return ScanError(e.message);
  } catch (e) {
    return ScanError('Errore imprevisto: $e');
  }
}

/// Completa un esito che richiede il peso: per i prodotti a peso appena
/// aggiunti chiede peso/totale, per i codici bilancia sconosciuti crea una
/// riga "Articolo a peso". Restituisce false se l'utente annulla.
Future<bool> completeWeight(
    BuildContext context, WidgetRef ref, ScanOutcome outcome) async {
  switch (outcome) {
    case ScanAdded(:final item) when outcome.needsWeight:
      final r = await showWeightDialog(context, item);
      if (r == null) return false;
      ref.read(cartProvider.notifier).setWeight(item.id,
          weightKg: r.weightKg, labelTotal: r.total, pricePerKg: r.pricePerKg);
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
            price: 0, source: PriceSource.label, readAt: now, chain: chain),
        addedAt: now,
      );
      final r = await showWeightDialog(context, placeholder,
          title: 'Codice bilancia non riconosciuto: inserisci il totale '
              "stampato sull'etichetta oppure peso e prezzo al kg.");
      if (r == null) return false;
      final total = r.total ??
          ((r.weightKg != null && r.pricePerKg != null)
              ? double.parse((r.weightKg! * r.pricePerKg!).toStringAsFixed(2))
              : null);
      if (total == null) return false;
      ref.read(cartProvider.notifier).addManual(placeholder.copyWith(
            labelTotal: total,
            weightKg: r.weightKg,
            pricePerKgOverride: r.pricePerKg,
            quote: placeholder.quote.copyWith(price: total),
          ));
      return true;
    default:
      return true;
  }
}

/// Codici d'esempio per "Simula scansione".
const kSampleCodes = <(Chain, String, String)>[
  (Chain.poli, '8007049920131', 'Mousse Melinda mela e banana'),
  (Chain.poli, '2060120000000', 'Trentingrana sfuso (codice di listino)'),
  (Chain.poli, '2060120012343', 'Etichetta bilancia Trentingrana 12,34 €'),
  (Chain.coop, '8013755002023', 'Trentingrana grattugiato 80 g (promo)'),
  (Chain.coop, '2877992', 'Trentingrana 20 mesi sfuso (codice interno)'),
  (Chain.coop, '8007049920131', 'Mousse Melinda mela e banana'),
  (Chain.poli, '0000000000000', 'Codice inesistente'),
];
