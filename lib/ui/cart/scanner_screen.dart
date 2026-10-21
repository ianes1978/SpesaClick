import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../domain/cart_math.dart';
import '../feedback.dart';
import '../providers.dart';
import '../widgets/format.dart';
import '../widgets/product_image.dart';
import '../widgets/source_badge.dart';
import 'scan_handler.dart';

/// Fotocamera a schermo intero per la scansione continua.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  static const _debounce = Duration(milliseconds: 2500);

  final _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
    detectionSpeed: DetectionSpeed.normal,
  );
  final _feedback = ScanFeedback();

  String? _lastCode;
  DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _busy = false;
  ScanOutcome? _outcome;

  @override
  void dispose() {
    _controller.dispose();
    _feedback.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final code = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (code == null || _busy) return;
    final now = DateTime.now();
    // Antirimbalzo: stesso codice ignorato per 2,5 s.
    if (code == _lastCode && now.difference(_lastAt) < _debounce) return;
    _lastCode = code;
    _lastAt = now;
    _busy = true;
    _feedback.ok();
    final outcome = await handleScannedCode(ref, code);
    if (outcome is! ScanAdded) _feedback.error();
    _lastAt = DateTime.now();
    if (mounted) setState(() => _outcome = outcome);
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    final totals = ref.watch(cartTotalsProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Fotocamera non disponibile: ${error.errorCode.name}.\n'
                  'Controlla il permesso nelle impostazioni.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const _ScanWindow(),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Text(
                      '${totals.pieces} pz · ${eur(totals.total)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.flashlight_on_outlined),
                      onPressed: _controller.toggleTorch,
                    ),
                  ],
                ),
                const Spacer(),
                if (_outcome != null) _OutcomeCard(_outcome!),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanWindow extends StatelessWidget {
  const _ScanWindow();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 280,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF008C45), width: 4),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _OutcomeCard extends StatelessWidget {
  const _OutcomeCard(this.outcome);

  final ScanOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final child = switch (outcome) {
      ScanAdded(:final item, :final isLabel) => ListTile(
          leading: ProductImage(item.product.thumbUrl, size: 48),
          title: Text(item.product.name,
              maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Row(children: [
            SourceBadge(item.quote),
            const SizedBox(width: 8),
            Text(isLabel ? 'etichetta' : 'quantità ${item.quantity}'),
          ]),
          trailing: Text(eur(lineTotals(item).net),
              style: Theme.of(context).textTheme.titleMedium),
        ),
      ScanNotFound(:final code) => ListTile(
          leading: const Icon(Icons.search_off, color: Colors.red),
          title: const Text('Prodotto non trovato'),
          subtitle: Text(code),
        ),
      ScanError(:final message) => ListTile(
          leading: const Icon(Icons.error_outline, color: Colors.red),
          title: const Text('Errore'),
          subtitle: Text(message),
        ),
    };
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }
}
