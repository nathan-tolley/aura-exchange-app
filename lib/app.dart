import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'design/gallery/gallery_screen.dart';
import 'design/gallery/screen_states.dart';
import 'design/text.dart';
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
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AuraColors.ink,
        scaffoldBackgroundColor: AuraColors.bg,
        barBackgroundColor: AuraColors.bg,
        textTheme: CupertinoTextThemeData(textStyle: auraBaseTextStyle()),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const _BlankScreen()),
    // The State Gallery: debug builds only (aura://gallery on the phone).
    if (kDebugMode)
      GoRoute(
        path: '/gallery',
        builder: (context, state) => AuraGalleryScreen(
          onOpenScreen: (id) => context.push('/gallery/screens/$id'),
        ),
        routes: [
          // A screen state full size: swipe back to the gallery.
          GoRoute(
            path: 'screens/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              final screen = screenStates.where((s) => s.id == id).firstOrNull;
              return screen == null
                  ? const _BlankScreen()
                  : Builder(builder: screen.build);
            },
          ),
        ],
      ),
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
