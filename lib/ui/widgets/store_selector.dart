import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/api_exceptions.dart';
import '../../domain/store.dart';
import '../providers.dart';

/// Negozio attivo nel carrello DupliClick, con possibilità di cambiarlo.
class StoreSelector extends ConsumerWidget {
  const StoreSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final color = Theme.of(context).colorScheme.onPrimary;
    final style = TextStyle(color: color, fontSize: 13);

    switch (session.status) {
      case SessionStatus.none:
      case SessionStatus.expired:
      case SessionStatus.error:
        return TextButton.icon(
          onPressed: () => context.push('/login'),
          icon: Icon(Icons.link, color: color, size: 18),
          label: Text(
            session.status == SessionStatus.expired
                ? 'Sessione scaduta · ricollegati'
                : 'Prezzi online · collega',
            style: style,
          ),
        );
      case SessionStatus.checking:
        return Text('Verifica…', style: style);
      case SessionStatus.offline:
        return Text('Offline', style: style);
      case SessionStatus.connected:
        return TextButton.icon(
          onPressed: () => pickCartStore(context, ref),
          icon: Icon(Icons.store, color: color, size: 18),
          label: Text(
            session.address?.addressName ?? 'Negozio?',
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        );
    }
  }
}

/// Cambia il negozio del carrello DupliClick reale (con conferma).
Future<void> pickCartStore(BuildContext context, WidgetRef ref) async {
  {
    final current = ref.read(sessionProvider).storeId;
    final stores = await ref.read(storesProvider.future);
    if (!context.mounted) return;
    final chosen = await showModalBottomSheet<Store>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          const ListTile(
            title: Text('Punto vendita'),
            subtitle: Text(
              'Cambia il negozio del tuo carrello DupliClick reale.',
            ),
          ),
          for (final s in stores)
            ListTile(
              leading: Icon(
                s.addressId == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text(s.name),
              subtitle: Text(
                [
                  s.address,
                  s.city,
                ].whereType<String>().where((e) => e.isNotEmpty).join(', '),
              ),
              onTap: () => Navigator.pop(ctx, s),
            ),
        ],
      ),
    );
    if (chosen == null || chosen.addressId == current || !context.mounted) {
      return;
    }
    final ok = await confirmStoreSwitch(context);
    if (!ok || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final addr = await ref.read(storeRepoProvider).select(chosen.addressId);
      ref.read(sessionProvider.notifier).setAddress(addr);
      messenger.showSnackBar(
        SnackBar(content: Text('Negozio: ${addr?.addressName}')),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      ref.read(sessionProvider.notifier).verify();
    }
  }
}

/// Avviso prima di toccare il carrello DupliClick reale.
Future<bool> confirmStoreSwitch(
  BuildContext context, {
  bool restore = false,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.warning_amber),
      title: const Text('Attenzione'),
      content: Text(
        'Questa operazione cambia il punto vendita del tuo carrello '
        'DupliClick reale${restore ? ' (che poi verrà ripristinato)' : ''}. '
        'Una fascia oraria di ritiro già prenotata potrebbe andare persa.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Procedi'),
        ),
      ],
    ),
  );
  return r ?? false;
}
