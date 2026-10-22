import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/api_exceptions.dart';
import '../../data/export.dart';
import '../../data/product_repository.dart';
import '../../domain/chain.dart';
import '../providers.dart';
import '../widgets/format.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _share(String name, String content) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, name));
    await file.writeAsString(content);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path)],
      subject: name,
    ));
  }

  Future<void> _export(String what, String format) async {
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    if (what == 'cart') {
      final items = ref.read(cartProvider);
      await _share('carrello_$stamp.$format',
          format == 'csv' ? cartToCsv(items) : cartToJson(items));
    } else {
      final products = await ref.read(dbProvider).allCatalog();
      if (products.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Scarica prima il listino offline.')));
        }
        return;
      }
      await _share('listino_$stamp.$format',
          format == 'csv' ? productsToCsv(products) : productsToJson(products));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        children: [
          _Header('Account DupliClick (Poli)'),
          ListTile(
            leading: Icon(session.status == SessionStatus.connected
                ? Icons.check_circle
                : Icons.link_off),
            title: Text(session.label),
            subtitle: const Text(
                'Con il login i prezzi sono quelli del punto vendita scelto.'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(spacing: 8, children: [
              FilledButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login),
                label: Text(session.status == SessionStatus.none
                    ? 'Collega DupliClick'
                    : 'Ricollega'),
              ),
              if (session.status != SessionStatus.none) ...[
                OutlinedButton(
                  onPressed: () => ref.read(sessionProvider.notifier).verify(),
                  child: const Text('Verifica'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      ref.read(sessionProvider.notifier).disconnect(),
                  child: const Text('Scollega'),
                ),
              ],
            ]),
          ),
          _Header('Click&Coop (Coop Trentino)'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Nessun login necessario'),
            subtitle: Text('Prezzi del listino online Click&Coop, uguali per '
                'tutti i punti di ritiro: in negozio possono differire.'),
          ),
          const _CoopPickupTile(),
          _Header('Listino offline'),
          const _OfflineCatalogTile(Chain.poli),
          const _OfflineCatalogTile(Chain.coop),
          _Header('Esporta'),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text('Carrello'),
            trailing: Wrap(spacing: 4, children: [
              TextButton(
                  onPressed: () => _export('cart', 'csv'),
                  child: const Text('CSV')),
              TextButton(
                  onPressed: () => _export('cart', 'json'),
                  child: const Text('JSON')),
            ]),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Catalogo (listini offline)'),
            trailing: Wrap(spacing: 4, children: [
              TextButton(
                  onPressed: () => _export('catalog', 'csv'),
                  child: const Text('CSV')),
              TextButton(
                  onPressed: () => _export('catalog', 'json'),
                  child: const Text('JSON')),
            ]),
          ),
          _Header('Informazioni'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Text(
              'Progetto personale e non ufficiale, non collegato a Poli, '
              'DupliClick, Coop Trentino o Click&Coop. Usa API non documentate '
              'che possono cambiare: i prezzi sono indicativi, fa fede lo '
              'scontrino.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineCatalogTile extends ConsumerStatefulWidget {
  const _OfflineCatalogTile(this.chain);
  final Chain chain;

  @override
  ConsumerState<_OfflineCatalogTile> createState() =>
      _OfflineCatalogTileState();
}

class _OfflineCatalogTileState extends ConsumerState<_OfflineCatalogTile> {
  DownloadProgress? _progress;
  bool _downloading = false;
  bool _cancel = false;

  Future<void> _download() async {
    setState(() {
      _downloading = true;
      _cancel = false;
      _progress = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      await for (final pr in ref
          .read(productRepoProvider(widget.chain))
          .downloadCatalog(cancelled: () => _cancel)) {
        if (mounted) setState(() => _progress = pr);
      }
      messenger.showSnackBar(SnackBar(
          content: Text(_cancel
              ? 'Download interrotto.'
              : 'Listino ${widget.chain.serviceName} scaricato: '
                  '${_progress?.items ?? 0} prodotti.')));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      ref.invalidate(offlineInfoProvider(widget.chain));
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(offlineInfoProvider(widget.chain)).value;
    final pr = _progress;
    String subtitle;
    if (info == null || info.count == 0) {
      subtitle = 'Nessun listino scaricato';
    } else if (info.downloadedAt == null) {
      subtitle = '${info.count} prodotti (download incompleto)';
    } else {
      subtitle =
          '${info.count} prodotti · ${shortDate(info.downloadedAt!)}';
    }
    return Column(children: [
      ListTile(
        leading: const Icon(Icons.cloud_download_outlined),
        title: Text(widget.chain.serviceName),
        subtitle: Text(subtitle),
        trailing: _downloading
            ? TextButton(
                onPressed: () => setState(() => _cancel = true),
                child: const Text('Interrompi'))
            : TextButton(onPressed: _download, child: const Text('Scarica')),
      ),
      if (_downloading)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(children: [
            LinearProgressIndicator(value: pr?.fraction),
            const SizedBox(height: 4),
            Text(pr == null
                ? 'Avvio…'
                : '${pr.label ?? 'Pagina ${pr.done}/${pr.total}'} · '
                    '${pr.items} prodotti'),
          ]),
        ),
    ]);
  }
}

class _CoopPickupTile extends ConsumerWidget {
  const _CoopPickupTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stores = ref.watch(coopPickupProvider);
    return ExpansionTile(
      leading: const Icon(Icons.store_outlined),
      title: const Text('Punti di ritiro'),
      children: stores.when(
        data: (list) => [
          for (final s in list)
            ListTile(
              dense: true,
              title: Text(s.name),
              subtitle: Text([s.address, s.city]
                  .whereType<String>()
                  .where((e) => e.isNotEmpty)
                  .join(', ')),
            ),
        ],
        loading: () => const [LinearProgressIndicator()],
        error: (e, _) => [ListTile(title: Text('Non disponibili: $e'))],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}
