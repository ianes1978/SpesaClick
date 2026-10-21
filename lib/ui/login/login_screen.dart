import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dupliclick_api.dart';
import '../providers.dart';

/// "Collega DupliClick": l'utente fa login nel sito vero (reCAPTCHA compreso,
/// che NON viene automatizzato), poi l'app copia i dati di sessione.
///
/// NB: non provato con un account reale; i log in debug aiutano ad adattare i
/// nomi di cookie/chiavi se differiscono.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  InAppWebViewController? _web;
  double _progress = 0;
  bool _linking = false;

  Future<EbsnSession> _readSession() async {
    final cookies = await CookieManager.instance()
        .getCookies(url: WebUri('$kDupliclickOrigin/ebsn/'));
    final js = cookies.where((c) => c.name == 'JSESSIONID').firstOrNull;
    String? session, account;
    final web = _web;
    if (web != null) {
      session = _clean(await web.evaluateJavascript(
          source: "sessionStorage.getItem('X-Ebsn-Session')"));
      account = _clean(await web.evaluateJavascript(
          source: "localStorage.getItem('X-Ebsn-Account')"));
    }
    if (kDebugMode) {
      debugPrint('Cookie ebsn: ${cookies.map((c) => c.name).toList()}');
      debugPrint('X-Ebsn-Session presente: ${session != null}, '
          'X-Ebsn-Account presente: ${account != null}');
    }
    return EbsnSession(
      jsessionId: js?.value?.toString(),
      ebsnSession: session,
      ebsnAccount: account,
    );
  }

  static String? _clean(dynamic v) {
    if (v == null) return null;
    var s = v.toString();
    if (s == 'null' || s.isEmpty) return null;
    if (s.startsWith('"') && s.endsWith('"') && s.length >= 2) {
      s = s.substring(1, s.length - 1);
    }
    return s;
  }

  Future<void> _link() async {
    setState(() => _linking = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      final s = await _readSession();
      if (s.isEmpty) {
        messenger.showSnackBar(const SnackBar(
            content: Text('Nessuna sessione trovata: hai fatto il login?')));
        return;
      }
      await ref.read(sessionProvider.notifier).connect(s);
      final state = ref.read(sessionProvider);
      messenger.showSnackBar(SnackBar(content: Text(state.label)));
      if (state.status == SessionStatus.connected) nav.pop();
    } finally {
      if (mounted) setState(() => _linking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collega DupliClick'),
        actions: [
          IconButton(
            tooltip: 'Ricarica',
            icon: const Icon(Icons.refresh),
            onPressed: () => _web?.reload(),
          ),
        ],
        bottom: _progress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(value: _progress),
              )
            : null,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.secondaryContainer,
            padding: const EdgeInsets.all(12),
            child: const Text(
              '1. Accedi con il tuo account DupliClick.\n'
              '2. Scegli "Ritiro in negozio" e il punto vendita.\n'
              '3. Tocca "Collega" qui sotto.',
            ),
          ),
          Expanded(
            child: InAppWebView(
              initialUrlRequest:
                  URLRequest(url: WebUri('$kDupliclickOrigin/')),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                thirdPartyCookiesEnabled: true,
              ),
              onWebViewCreated: (c) => _web = c,
              onProgressChanged: (_, p) => setState(() => _progress = p / 100),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _linking ? null : _link,
            icon: _linking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.link),
            label: const Text('Collega'),
          ),
        ),
      ),
    );
  }
}
