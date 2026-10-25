import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/lifecycle.dart';
import 'design/text.dart';
import 'design/tokens.dart';
import 'router.dart';

/// The app shell. Graphite is dark only (design/DESIGN.md), and every screen
/// is a go_router route (`router.dart`) so `aura://` deep links land on real
/// screens.
///
/// There's no background refresh without the paid program, so the app
/// follows its own lifecycle: leaving the foreground stops the stream, and
/// coming back restarts it and refetches what's on screen
/// (`foregroundProvider`).
class AuraApp extends ConsumerStatefulWidget {
  const AuraApp({super.key});

  @override
  ConsumerState<AuraApp> createState() => _AuraAppState();
}

class _AuraAppState extends ConsumerState<AuraApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onShow: () => ref.read(foregroundProvider.notifier).set(true),
      onHide: () => ref.read(foregroundProvider.notifier).set(false),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

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
      routerConfig: ref.watch(routerProvider),
    );
  }
}
