import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/chain.dart';
import '../../domain/price_store.dart';
import '../providers.dart';
import '../widgets/store_selector.dart';

/// Lista dei negozi da cui leggere e confrontare i prezzi, presi fra le
/// catene disponibili. Nessun negozio di una catena = catena esclusa.
class StoresScreen extends ConsumerWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedStoresProvider);
    final available = ref.watch(availableStoresProvider);
    final session = ref.watch(sessionProvider);
    final svc = ref.watch(priceServiceProvider);
    final notifier = ref.read(selectedStoresProvider.notifier);
    final theme = Theme.of(context);

    Widget header(String t) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        t,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Negozi')),
      body: ListView(
        children: [
          header('Nel confronto (trascina per ordinare)'),
          if (selected.isEmpty)
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Nessun negozio selezionato'),
              subtitle: Text('Aggiungine almeno uno qui sotto.'),
            ),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorderItem: notifier.reorder,
            children: [
              for (var i = 0; i < selected.length; i++)
                ListTile(
                  key: ValueKey(selected[i].id),
                  leading: ReorderableDragStartListener(
                    index: i,
                    child: const Icon(Icons.drag_handle),
                  ),
                  title: Text(selected[i].name),
                  subtitle: Text(
                    svc.unavailableReason(selected[i]) ??
                        (i == 0
                            ? 'Proposto per primo · prezzi in diretta'
                            : 'Prezzi in diretta'),
                  ),
                  trailing: IconButton(
                    tooltip: 'Togli',
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => notifier.toggle(selected[i]),
                  ),
                ),
            ],
          ),
          SwitchListTile(
            title: const Text('Chiedi quale prezzo usare'),
            subtitle: const Text(
              'Quando un prodotto è in più negozi. '
              'Se disattivato si usa il primo della lista.',
            ),
            value: ref.watch(askStoreChoiceProvider),
            onChanged: ref.read(askStoreChoiceProvider.notifier).set,
          ),
          header('Aggiungi'),
          ...available.when(
            data: (list) => [
              for (final chain in Chain.values) ...[
                ListTile(
                  dense: true,
                  title: Text(
                    '${chain.label} · ${chain.serviceName}',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                for (final s in list.where((s) => s.chain == chain))
                  CheckboxListTile(
                    value: selected.any((e) => e.id == s.id),
                    onChanged: (_) => notifier.toggle(s),
                    title: Text(s.isOnline ? s.name : s.shortLabel),
                    subtitle: Text(_hint(s)),
                  ),
                if (chain.isEverli && !list.any((s) => s.chain == chain))
                  ListTile(
                    leading: const Icon(Icons.cloud_off),
                    title: Text('${chain.label}: nessun negozio da Everli'),
                    subtitle: const Text(
                      'Everli non risponde o non serve Trento. Riprova più tardi.',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => ref.invalidate(everliStoresProvider),
                    ),
                  ),
              ],
            ],
            loading: () => const [LinearProgressIndicator()],
            error: (e, _) => [
              ListTile(title: Text('Negozi non disponibili: $e')),
            ],
          ),
          header('Carrello DupliClick'),
          ListTile(
            leading: const Icon(Icons.shopping_cart_checkout),
            title: Text(session.label),
            subtitle: const Text(
              'I prezzi di un punto vendita Poli si leggono '
              'in diretta solo per il negozio attivo nel carrello DupliClick. '
              'Per gli altri usa "Aggiorna prezzi dei negozi Poli" nel '
              'riepilogo del carrello.',
            ),
            isThreeLine: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                if (session.status == SessionStatus.connected)
                  OutlinedButton.icon(
                    onPressed: () => pickCartStore(context, ref),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Cambia negozio del carrello'),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => context.push('/login'),
                    icon: const Icon(Icons.login),
                    label: const Text('Collega DupliClick'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static String _hint(PriceStore s) => switch (s) {
    PriceStore(chain: Chain.coop) =>
      'Un unico listino per tutti i punti di ritiro',
    PriceStore(chain: Chain.aldi) =>
      'Nessuna fonte online (non è su Everli): il prezzo lo inserisci tu '
          'dalla riga del carrello e viene ricordato',
    PriceStore(chain: Chain.lidl || Chain.md || Chain.pam) =>
      'Prezzi Everli, in negozio possono differire. Niente EAN: si '
          'propongono prodotti equivalenti da confermare',
    PriceStore(chain: Chain.poli, isOnline: true) =>
      'Senza login, uguale per tutti i negozi',
    _ => [
      s.address,
      'prezzi del punto vendita, serve il login',
    ].whereType<String>().where((e) => e.isNotEmpty).join(' · '),
  };
}
