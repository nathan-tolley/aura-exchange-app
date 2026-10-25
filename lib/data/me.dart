import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/generated/export.dart';
import 'api_providers.dart';
import 'lifecycle.dart';
import 'repositories.dart';

/// Whether someone is signed in, following the session: null until the
/// Keychain has been read, then true or false. Reading it starts that read.
final signedInProvider = NotifierProvider<SignedIn, bool?>(SignedIn.new);

class SignedIn extends Notifier<bool?> {
  @override
  bool? build() {
    final session = ref.watch(authSessionProvider);
    void follow() => state = session.signedIn.value;
    session.signedIn.addListener(follow);
    ref.onDispose(() => session.signedIn.removeListener(follow));
    // The first read of the Keychain sets `signedIn`.
    session.current().ignore();
    return session.signedIn.value;
  }
}

/// You and your memberships (`GET /me`), while signed in; null when signed
/// out. Refetched on resume and after a reconnect, and by onboarding after it
/// creates or joins an exchange or lists you.
final meProvider = AsyncNotifierProvider<MeNotifier, Me?>(MeNotifier.new);

class MeNotifier extends AsyncNotifier<Me?> {
  @override
  Future<Me?> build() async {
    if (ref.watch(signedInProvider) != true) return null;
    ref.watch(refetchSignalProvider);
    return ref.read(meRepositoryProvider).me();
  }

  /// Refetches after onboarding changed your memberships. The previous value
  /// stays on screen until the new one arrives.
  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}

/// The exchange you chose this session, such as the one you just joined.
/// Not kept across launches yet: several exchanges per person is an open
/// question in DECISIONS.md.
final selectedExchangeProvider = NotifierProvider<SelectedExchange, String?>(
  SelectedExchange.new,
);

class SelectedExchange extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String exchangeId) => state = exchangeId;
}

/// The membership the app is showing: the one you chose this session if
/// you're in it, otherwise your first. Null while signed out, while `/me`
/// loads, and when you're in no exchange yet.
final currentMembershipProvider = Provider<Membership?>((ref) {
  final me = ref.watch(meProvider).value;
  if (me == null || me.memberships.isEmpty) return null;
  final chosen = ref.watch(selectedExchangeProvider);
  return me.memberships.where((m) => m.exchangeId == chosen).firstOrNull ??
      me.memberships.first;
});

/// The exchange the app is showing, by id.
final currentExchangeIdProvider = Provider<String?>(
  (ref) => ref.watch(currentMembershipProvider)?.exchangeId,
);

/// One exchange (`GET /exchanges/{id}`): name, timezone, hours, season and
/// how many are listed. Refetched on resume.
final exchangeProvider = FutureProvider.autoDispose.family<Exchange, String>((
  ref,
  exchangeId,
) {
  ref.watch(refetchSignalProvider);
  return ref.read(exchangesRepositoryProvider).exchange(exchangeId);
});
