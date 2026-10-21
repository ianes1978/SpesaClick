// Conversioni tolleranti per le risposte non documentate dell'API.

String? asString(Object? v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

int? asInt(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

double? asDouble(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.trim().replaceAll('€', '').replaceAll(' ', '');
    if (s.isEmpty) return null;
    // "1.234,56" -> 1234.56 ; "1,25" -> 1.25
    if (s.contains(',')) {
      return double.tryParse(s.replaceAll('.', '').replaceAll(',', '.'));
    }
    return double.tryParse(s);
  }
  return null;
}

Map<String, dynamic>? asMap(Object? v) =>
    v is Map ? v.cast<String, dynamic>() : null;
