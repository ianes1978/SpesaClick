import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api_exceptions.dart';
import '../../domain/cart_item.dart';
import '../../domain/ean.dart';
import '../providers.dart';

/// Esito di una scansione (o di un inserimento manuale).
sealed class ScanOutcome {
  const ScanOutcome();
}

class ScanAdded extends ScanOutcome {
  const ScanAdded(this.item, {required this.isLabel});
  final CartItem item;
  final bool isLabel;
}

class ScanNotFound extends ScanOutcome {
  const ScanNotFound(this.code);
  final String code;
}

class ScanError extends ScanOutcome {
  const ScanError(this.message);
  final String message;
}

/// Cerca il codice e lo aggiunge al carrello. Una sola chiamata per scansione
/// (più le varianti UPC→EAN quando servono).
Future<ScanOutcome> handleScannedCode(WidgetRef ref, String raw) async {
  final code = raw.trim();
  if (!isDigits(code)) return ScanNotFound(code);
  final label = ScaleLabel.tryParse(code);
  final repo = ref.read(productRepoProvider);
  try {
    final r = await repo.lookup(label?.lookupBarcode ?? code);
    if (r == null) return ScanNotFound(code);
    final item = ref.read(cartProvider.notifier).add(r, label: label);
    return ScanAdded(item, isLabel: label != null);
  } on ApiException catch (e) {
    return ScanError(e.message);
  } catch (e) {
    return ScanError('Errore imprevisto: $e');
  }
}

/// Codici d'esempio per "Simula scansione".
const kSampleCodes = <(String, String)>[
  ('8007049920131', 'Mousse Melinda mela e banana'),
  ('2060120000000', 'Trentingrana sfuso (codice di listino)'),
  ('2060120012343', 'Etichetta bilancia Trentingrana 12,34 €'),
  ('0000000000000', 'Codice inesistente'),
];
