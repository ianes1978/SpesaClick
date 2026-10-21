import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'ui/card/card_screen.dart';
import 'ui/cart/cart_screen.dart';
import 'ui/cart/scanner_screen.dart';
import 'ui/catalog/catalog_screen.dart';
import 'ui/login/login_screen.dart';
import 'ui/settings/settings_screen.dart';

const kBrandGreen = Color(0xFF008C45);

final _rootKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/cart',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _HomeShell(shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/catalog', builder: (_, _) => const CatalogScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/card', builder: (_, _) => const CardScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/settings', builder: (_, _) => const SettingsScreen()),
        ]),
      ],
    ),
    GoRoute(
      path: '/scanner',
      parentNavigatorKey: _rootKey,
      builder: (_, _) => const ScannerScreen(),
    ),
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootKey,
      builder: (_, _) => const LoginScreen(),
    ),
    GoRoute(
      path: '/card/show',
      parentNavigatorKey: _rootKey,
      builder: (_, _) => const CardFullscreen(),
    ),
  ],
);

class SpesaTrentoApp extends StatelessWidget {
  const SpesaTrentoApp({super.key});

  ThemeData _theme(Brightness b) {
    final scheme = ColorScheme.fromSeed(
      seedColor: kBrandGreen,
      brightness: b,
    ).copyWith(
      primary: b == Brightness.light ? kBrandGreen : null,
      onPrimary: b == Brightness.light ? Colors.white : null,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Spesa Trento',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      routerConfig: router,
      locale: const Locale('it', 'IT'),
      supportedLocales: const [Locale('it', 'IT')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}

class _HomeShell extends StatelessWidget {
  const _HomeShell(this.shell);
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Carrello'),
          NavigationDestination(
              icon: Icon(Icons.search), label: 'Catalogo'),
          NavigationDestination(
              icon: Icon(Icons.credit_card), label: 'Tessera'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Altro'),
        ],
      ),
    );
  }
}
