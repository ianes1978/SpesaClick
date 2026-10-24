import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../../domain/ean.dart';
import '../providers.dart';

final loyaltyCardProvider = FutureProvider<String?>(
  (ref) => ref.watch(sessionStorageProvider).loyaltyCard(),
);

class CardScreen extends ConsumerStatefulWidget {
  const CardScreen({super.key});

  @override
  ConsumerState<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends ConsumerState<CardScreen> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final input = _ctrl.text.replaceAll(RegExp(r'\s'), '');
    final full = completeEan13(input);
    if (full == null) {
      setState(
        () => _error = input.length == 13
            ? 'Cifra di controllo errata'
            : 'Inserisci 12 o 13 cifre',
      );
      return;
    }
    setState(() => _error = null);
    await ref.read(sessionStorageProvider).setLoyaltyCard(full);
    ref.invalidate(loyaltyCardProvider);
    _ctrl.clear();
    if (mounted && input.length == 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cifra di controllo calcolata: ${full[12]}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = ref.watch(loyaltyCardProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Tessera fedeltà')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (card != null) ...[
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.push('/card/show'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      BarcodeWidget(
                        barcode: Barcode.ean13(),
                        data: card,
                        height: 100,
                        color: Colors.black,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      const Text('Tocca per mostrarla alla cassa'),
                    ],
                  ),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await ref.read(sessionStorageProvider).setLoyaltyCard(null);
                ref.invalidate(loyaltyCardProvider);
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Rimuovi tessera'),
            ),
            const Divider(height: 32),
          ],
          Text(
            card == null ? 'Aggiungi la tua tessera' : 'Cambia tessera',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(13),
            ],
            decoration: InputDecoration(
              labelText: 'Numero tessera (12 o 13 cifre)',
              helperText: 'Con 12 cifre calcolo io la cifra di controllo',
              errorText: _error,
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: const Text('Salva')),
        ],
      ),
    );
  }
}

/// Codice a tutto schermo con luminosità al massimo.
class CardFullscreen extends ConsumerStatefulWidget {
  const CardFullscreen({super.key});

  @override
  ConsumerState<CardFullscreen> createState() => _CardFullscreenState();
}

class _CardFullscreenState extends ConsumerState<CardFullscreen> {
  @override
  void initState() {
    super.initState();
    ScreenBrightness.instance
        .setApplicationScreenBrightness(1.0)
        .catchError((_) {});
  }

  @override
  void dispose() {
    ScreenBrightness.instance.resetApplicationScreenBrightness().catchError(
      (_) {},
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = ref.watch(loyaltyCardProvider).value;
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: SafeArea(
          child: Center(
            child: card == null
                ? const Text('Nessuna tessera')
                : RotatedBox(
                    quarterTurns: MediaQuery.of(context).size.width < 500
                        ? 1
                        : 0,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: BarcodeWidget(
                        barcode: Barcode.ean13(),
                        data: card,
                        width: 420,
                        height: 180,
                        color: Colors.black,
                        backgroundColor: Colors.white,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
