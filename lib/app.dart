import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import 'design/tokens.dart';

/// The app shell. Graphite is dark only (design/DESIGN.md), and every screen
/// is a go_router route so `aura://` deep links land on real screens.
class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      title: 'Aura Exchange',
      color: AuraColors.bg,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AuraColors.ink,
        scaffoldBackgroundColor: AuraColors.bg,
        barBackgroundColor: AuraColors.bg,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const _BlankScreen()),
  ],
);

/// Placeholder until Home exists: the one background, nothing on it.
class _BlankScreen extends StatelessWidget {
  const _BlankScreen();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: AuraColors.bg, child: SizedBox.expand());
  }
}
