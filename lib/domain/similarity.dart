/// Confronto "per nome" fra prodotti, usato per Everli che non ha EAN.
library;

import 'product.dart';

const _accents = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ä': 'a',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'ö': 'o',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ç': 'c',
};

/// Parole che non distinguono un prodotto.
const _stopwords = {
  'di',
  'del',
  'della',
  'dei',
  'delle',
  'degli',
  'da',
  'dal',
  'con',
  'e',
  'ed',
  'al',
  'alla',
  'allo',
  'ai',
  'agli',
  'alle',
  'in',
  'per',
  'il',
  'lo',
  'la',
  'i',
  'gli',
  'le',
  'un',
  'una',
  'uno',
  'a',
  'su',
  'senza',
  'tipo',
  'gr',
  'g',
  'kg',
  'ml',
  'cl',
  'l',
  'lt',
  'pz',
  'x',
  'conf',
  'confezione',
  'bottiglia',
  'busta',
  'vaschetta',
  'pezzi',
  'pezzo',
};

/// Minuscole, senza accenti né punteggiatura.
String normalizeText(String s) {
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    b.write(_accents[ch] ?? ch);
  }
  return b.toString().replaceAll(RegExp(r"[^a-z0-9]+"), ' ').trim();
}

/// Radice grezza per tollerare singolare/plurale ("banana"/"banane").
String stem(String t) =>
    t.length > 3 ? t.replaceFirst(RegExp(r'[aeiou]+$'), '') : t;

/// Termini significativi: niente parole vuote, unità o numeri.
List<String> significantTerms(String s) => [
  for (final t in normalizeText(s).split(' '))
    if (t.length >= 2 && !_stopwords.contains(t) && !RegExp(r'^\d').hasMatch(t))
      t,
];

/// Tutti i termini significativi di [query] compaiono in [text]?
/// Serve a scartare i risultati "fuzzy" di Everli senza corrispondenze vere.
bool matchesAllTerms(String query, String text) {
  final terms = significantTerms(query);
  if (terms.isEmpty) return false;
  final stems = normalizeText(text).split(' ').map(stem).toSet();
  return terms.every((t) {
    final s = stem(t);
    return stems.any(
      (w) => w.startsWith(s) || s.startsWith(w) && w.length >= 4,
    );
  });
}

/// Quantità della confezione in kg o l, letta da descrizioni come
/// "500 g", "2x100 g", "80g", "Bottiglia 1l", "busta 0.350kg".
({double amount, String unit})? parseQuantity(String? s) {
  if (s == null) return null;
  final t = s.toLowerCase().replaceAll(',', '.');
  final m = RegExp(r'(?:(\d+)\s*x\s*)?(\d+(?:\.\d+)?)\s*(kg|gr|g|lt|l|ml|cl)\b')
      .firstMatch(t);
  if (m == null) return null;
  final times = int.tryParse(m.group(1) ?? '') ?? 1;
  var v = double.parse(m.group(2)!) * times;
  final u = m.group(3)!;
  switch (u) {
    case 'g' || 'gr':
      return (amount: v / 1000, unit: 'kg');
    case 'kg':
      return (amount: v, unit: 'kg');
    case 'ml':
      return (amount: v / 1000, unit: 'l');
    case 'cl':
      return (amount: v / 100, unit: 'l');
    default:
      return (amount: v, unit: 'l');
  }
}

/// Somiglianza (0–1) fra un prodotto di riferimento (trovato per EAN) e un
/// candidato Everli. Non dice che sono lo stesso articolo: solo che sono
/// confrontabili.
double similarity(Product ref, Product cand) {
  final refTerms = significantTerms(ref.name).map(stem).toSet();
  if (refTerms.isEmpty) return 0;
  final candText = [
    cand.name,
    cand.brand ?? '',
    cand.packageDescr ?? '',
  ].join(' ');
  final candStems = significantTerms(candText).map(stem).toSet();
  final common = refTerms
      .where((t) => candStems.any((c) => c.startsWith(t) || t.startsWith(c)))
      .length;
  var score = common / refTerms.length;
  if (score < 0.5) return score * 0.5;

  final brand = ref.brand == null ? <String>[] : significantTerms(ref.brand!);
  if (brand.isNotEmpty && brand.every((b) => candStems.contains(stem(b)))) {
    score += 0.15;
  }

  final qa = parseQuantity(ref.packageDescr);
  final qb = parseQuantity(cand.packageDescr);
  if (qa != null && qb != null) {
    if (qa.unit != qb.unit) {
      score -= 0.3;
    } else {
      final r = qa.amount / qb.amount;
      if (r >= 0.75 && r <= 1.34) score += 0.15;
    }
  }
  final ua = ref.weightUnit, ub = cand.weightUnit;
  if (ua != null && ub != null && ua != ub) score -= 0.2;
  return score.clamp(0.0, 1.0);
}

/// Parole chiave per cercare equivalenti: i primi termini significativi del
/// nome (la marca spesso non c'è, Lidl e MD vendono marche proprie).
String equivalentKeyword(Product ref, {int maxTerms = 3}) =>
    significantTerms(ref.name).take(maxTerms).join(' ');
