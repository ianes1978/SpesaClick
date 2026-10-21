import 'package:intl/intl.dart';

final _eur = NumberFormat.currency(locale: 'it_IT', symbol: '€');
final _num = NumberFormat('#,##0.###', 'it_IT');
final _date = DateFormat('dd/MM HH:mm', 'it_IT');

String eur(double v) => _eur.format(v);
String num3(double v) => _num.format(v);
String shortDate(DateTime d) => _date.format(d);

/// Legge "1,25" o "1.25".
double? parseDecimal(String s) =>
    double.tryParse(s.trim().replaceAll(',', '.'));
