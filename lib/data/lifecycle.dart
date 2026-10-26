import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the app is on screen. There's no background refresh without the
/// paid program (CLAUDE.md → Platform limits), so the stream stops when the
/// app leaves the foreground and every screen refetches when it comes back.
/// `AuraApp` reports the changes from an `AppLifecycleListener`.
final foregroundProvider = NotifierProvider<Foreground, bool>(Foreground.new);

class Foreground extends Notifier<bool> {
  @override
  bool build() => true;

  void set(bool foreground) {
    if (foreground == state) return;
    state = foreground;
    if (foreground) ref.read(refetchSignalProvider.notifier).fire();
  }
}

/// Bumps whenever what's on screen may be out of date: the app came back to
/// the foreground, or the stream reconnected after missing messages. A screen's
/// provider watches it to refetch; the numbers already shown stay until the
/// new ones arrive (Riverpod keeps the previous value while reloading).
final refetchSignalProvider = NotifierProvider<RefetchSignal, int>(
  RefetchSignal.new,
);

class RefetchSignal extends Notifier<int> {
  @override
  int build() => 0;

  void fire() => state++;
}
