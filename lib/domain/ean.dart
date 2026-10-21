/// Utilità per codici EAN/UPC ed etichette della bilancia.
library;

final _digits = RegExp(r'^\d+$');

bool isDigits(String s) => s.isNotEmpty && _digits.hasMatch(s);

/// Cifra di controllo GS1 per un codice senza cifra di controllo
/// (7 cifre per EAN-8, 11 per UPC-A, 12 per EAN-13).
int gs1CheckDigit(String body) {
  if (!isDigits(body)) {
    throw ArgumentError.value(body, 'body', 'solo cifre');
  }
  var sum = 0;
  // Da destra: pesi 3,1,3,1...
  for (var i = 0; i < body.length; i++) {
    final d = body.codeUnitAt(body.length - 1 - i) - 48;
    sum += i.isEven ? d * 3 : d;
  }
  return (10 - sum % 10) % 10;
}

bool hasValidCheckDigit(String code) {
  if (!isDigits(code) || code.length < 2) return false;
  final body = code.substring(0, code.length - 1);
  return gs1CheckDigit(body) == code.codeUnitAt(code.length - 1) - 48;
}

bool isValidEan13(String code) => code.length == 13 && hasValidCheckDigit(code);
bool isValidEan8(String code) => code.length == 8 && hasValidCheckDigit(code);

/// Completa un EAN-13 a partire da 12 cifre, o verifica un codice da 13.
/// Restituisce il codice completo oppure null se non valido.
String? completeEan13(String input) {
  final s = input.replaceAll(RegExp(r'\s'), '');
  if (!isDigits(s)) return null;
  if (s.length == 12) return '$s${gs1CheckDigit(s)}';
  if (s.length == 13) return isValidEan13(s) ? s : null;
  return null;
}

/// Espande un UPC-E (8 cifre) in UPC-A (12 cifre).
String? expandUpcE(String upce) {
  if (upce.length != 8 || !isDigits(upce)) return null;
  final ns = upce[0];
  if (ns != '0' && ns != '1') return null;
  final d = upce.substring(1, 7);
  final check = upce[7];
  final last = d[5];
  String mfr, item;
  switch (last) {
    case '0' || '1' || '2':
      mfr = '${d.substring(0, 2)}${last}00';
      item = '00${d.substring(2, 5)}';
    case '3':
      mfr = '${d.substring(0, 3)}00';
      item = '000${d.substring(3, 5)}';
    case '4':
      mfr = '${d.substring(0, 4)}0';
      item = '0000${d[4]}';
    default:
      mfr = d.substring(0, 5);
      item = '0000$last';
  }
  return '$ns$mfr$item$check';
}

/// Codici da provare, in ordine, per cercare un prodotto scansionato.
List<String> barcodeCandidates(String raw) {
  final code = raw.trim();
  final out = <String>[code];
  if (code.length == 12 && isDigits(code)) {
    out.add('0$code'); // UPC-A -> EAN-13
  } else if (code.length == 8 && isDigits(code) && !isValidEan8(code)) {
    final upca = expandUpcE(code);
    if (upca != null) out.add('0$upca');
  } else if (code.length == 13 && code.startsWith('0')) {
    out.add(code.substring(1));
  }
  return out;
}

/// Etichetta della bilancia: EAN-13 "2" + articolo (6) + centesimi (5) + controllo.
class ScaleLabel {
  const ScaleLabel({
    required this.raw,
    required this.lookupBarcode,
    required this.articleCode,
    required this.total,
  });

  final String raw;

  /// Codice con cui il prodotto sfuso compare nel listino:
  /// primi 7 caratteri + "000000" (es. 2060120000000).
  final String lookupBarcode;
  final String articleCode;

  /// Prezzo stampato (totale della riga) in euro.
  final double total;

  /// Riconosce un'etichetta della bilancia. Restituisce null se il codice non
  /// lo è, oppure se la parte prezzo è zero (in quel caso è già il codice
  /// "di listino" del prodotto sfuso e va cercato così com'è).
  static ScaleLabel? tryParse(String code) {
    if (code.length != 13 || !code.startsWith('2') || !isDigits(code)) {
      return null;
    }
    final cents = int.parse(code.substring(7, 12));
    if (cents == 0) return null;
    return ScaleLabel(
      raw: code,
      lookupBarcode: '${code.substring(0, 7)}000000',
      articleCode: code.substring(1, 7),
      total: cents / 100,
    );
  }
}
