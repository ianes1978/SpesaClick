import 'package:flutter/material.dart';

import '../../domain/cart_item.dart';
import '../../domain/cart_math.dart';
import '../widgets/format.dart';

class WeightResult {
  const WeightResult(this.weightKg, this.total, this.pricePerKg);
  final double? weightKg;
  final double? total;
  final double? pricePerKg;
}

/// Peso (kg) ↔ totale etichetta (€) sincronizzati, prezzo al kg modificabile.
Future<WeightResult?> showWeightDialog(
  BuildContext context,
  CartItem item, {
  String? title,
}) {
  return showDialog<WeightResult>(
    context: context,
    builder: (_) => _WeightDialog(item, title),
  );
}

class _WeightDialog extends StatefulWidget {
  const _WeightDialog(this.item, this.message);
  final CartItem item;
  final String? message;

  @override
  State<_WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends State<_WeightDialog> {
  late final _ppk = TextEditingController(
    text: _fmt(widget.item.effectivePricePerKg, 2),
  );
  late final _weight = TextEditingController(
    text: _fmt(widget.item.weightKg, 3),
  );
  late final _total = TextEditingController(
    text: _fmt(
      widget.item.labelTotal ??
          (widget.item.weightKg != null &&
                  widget.item.effectivePricePerKg != null
              ? round2(widget.item.weightKg! * widget.item.effectivePricePerKg!)
              : null),
      2,
    ),
  );

  /// Il totale è stato inserito a mano (es. letto sull'etichetta).
  late bool _totalIsLabel = widget.item.labelTotal != null;

  static String _fmt(double? v, int digits) =>
      v == null ? '' : v.toStringAsFixed(digits).replaceAll('.', ',');

  @override
  void dispose() {
    _ppk.dispose();
    _weight.dispose();
    _total.dispose();
    super.dispose();
  }

  void _fromWeight() {
    final w = parseDecimal(_weight.text), p = parseDecimal(_ppk.text);
    _totalIsLabel = false;
    if (w != null && p != null) _total.text = _fmt(round2(w * p), 2);
  }

  void _fromTotal() {
    final t = parseDecimal(_total.text), p = parseDecimal(_ppk.text);
    _totalIsLabel = true;
    if (t != null && p != null && p > 0) _weight.text = _fmt(t / p, 3);
  }

  void _fromPpk() => _totalIsLabel ? _fromTotal() : _fromWeight();

  @override
  Widget build(BuildContext context) {
    final unit = widget.item.product.weightUnit ?? 'kg';
    return AlertDialog(
      title: Text(
        widget.item.product.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(widget.message!),
              ),
            TextField(
              controller: _ppk,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Prezzo al $unit (€)',
                prefixIcon: const Icon(Icons.euro),
              ),
              onChanged: (_) => _fromPpk(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weight,
              autofocus: widget.item.weightKg == null,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Peso ($unit)',
                prefixIcon: const Icon(Icons.scale),
              ),
              onChanged: (_) => _fromWeight(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _total,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Totale etichetta (€)',
                prefixIcon: Icon(Icons.receipt_long),
              ),
              onChanged: (_) => _fromTotal(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () {
            final total = parseDecimal(_total.text);
            Navigator.pop(
              context,
              WeightResult(
                parseDecimal(_weight.text),
                _totalIsLabel ? total : null,
                parseDecimal(_ppk.text),
              ),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
