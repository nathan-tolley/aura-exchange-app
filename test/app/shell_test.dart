import 'package:aura_exchange/api/generated/export.dart';
import 'package:aura_exchange/data/lifecycle.dart';
import 'package:aura_exchange/data/live_market.dart';
import 'package:aura_exchange/data/me.dart';
import 'package:aura_exchange/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http.dart';
import '../support/fake_socket.dart';
import '../support/providers.dart';

/// The app shell: where the redirect sends you, and the lifecycle (the
/// stream stops in the background, screens refetch on resume).
void main() {
  group('redirect', () {
    const exchange = '7c1d2e3f-0a1b-4c5d-8e9f-a0b1c2d3e4f5';
    Map<String, Object?> membership({bool listed = true}) => {
      'id': '22222222-0000-4000-8000-000000000001',
      'exchangeId': exchange,
      'role': 'ADMIN',
      'listing': listed
          ? {
              'id': '11111111-0000-4000-8000-000000000003',
              'ticker': r'$NATE',
              'displayName': 'Nathan',
              'avatarUrl': null,
            }
          : null,
      'listingConsentAt': listed ? '2026-10-24T13:21:00Z' : null,
      'joinedAt': '2026-10-24T13:20:00Z',
      'badges': <String>[],
      'superInjunctionsLeft': 3,
    };
    AsyncValue<Me?> me(List<Map<String, Object?>> memberships) => AsyncData(
      Me.fromJson({
        'user': tokenPairJson['user'],
        'memberships': memberships,
      }),
    );
    String? go(
      String location, {
      bool? signedIn = true,
      AsyncValue<Me?> me = const AsyncLoading(),
    }) => appRedirect(Uri.parse(location), signedIn: signedIn, me: me);

    test('waits on boot while the Keychain is read', () {
      expect(go(Routes.home, signedIn: null), Routes.boot);
      expect(go(Routes.boot, signedIn: null), isNull);
      expect(
        go('/invite/JAKE-7F2K', signedIn: null),
        '/boot?from=%2Finvite%2FJAKE-7F2K',
      );
    });

    test('signed out goes to sign-in, keeping an invite link', () {
      expect(go(Routes.home, signedIn: false), Routes.signIn);
      expect(go(Routes.signIn, signedIn: false), isNull);
      expect(go('/sign-in/code?email=a', signedIn: false), isNull);
      expect(
        go('/invite/JAKE-7F2K', signedIn: false),
        '/sign-in?from=%2Finvite%2FJAKE-7F2K',
      );
      expect(
        go('/boot?from=%2Finvite%2FJAKE-7F2K', signedIn: false),
        '/sign-in?from=%2Finvite%2FJAKE-7F2K',
      );
    });

    test('signed in waits on boot until /me answers', () {
      expect(go(Routes.home), Routes.boot);
      expect(go(Routes.boot), isNull);
      expect(
        go(Routes.signIn, me: const AsyncError('offline', StackTrace.empty)),
        Routes.boot,
      );
    });

    test('in no exchange: create one, or follow the invite', () {
      final none = me([]);
      expect(go(Routes.boot, me: none), Routes.createExchange);
      expect(go(Routes.home, me: none), Routes.createExchange);
      expect(go(Routes.createExchange, me: none), isNull);
      expect(go('/invite/JAKE-7F2K', me: none), isNull);
      expect(
        go('/sign-in?from=%2Finvite%2FJAKE-7F2K', me: none),
        '/invite/JAKE-7F2K',
      );
    });

    test('not listed yet: your IPO, after inviting friends', () {
      final unlisted = me([membership(listed: false)]);
      expect(go(Routes.home, me: unlisted), Routes.ipo);
      expect(go(Routes.ipo, me: unlisted), isNull);
      expect(go('${Routes.createExchange}/invite', me: unlisted), isNull);
    });

    test('listed: sign-in and boot go forward, everything else stays', () {
      final listed = me([membership()]);
      expect(go(Routes.boot, me: listed), Routes.home);
      expect(go(Routes.signIn, me: listed), Routes.home);
      expect(go('/boot?from=%2Fmarket', me: listed), Routes.market);
      expect(go(Routes.market, me: listed), isNull);
      expect(go(Routes.ipo, me: listed), isNull);
    });

    test('ignores a from that leaves the app', () {
      final listed = me([membership()]);
      expect(go('/boot?from=https%3A%2F%2Fevil.test', me: listed), Routes.home);
      expect(go('/boot?from=%2F%2Fevil.test', me: listed), Routes.home);
    });

    test('the gallery is always reachable', () {
      expect(go(Routes.gallery, signedIn: null), isNull);
      expect(go('${Routes.gallery}/screens/W09', signedIn: false), isNull);
    });
  });

  group('lifecycle', () {
    late List<FakeSocket> sockets;
    late ProviderContainer container;

    setUp(() {
      sockets = [];
      container = testContainer(
        http: FakeAdapter((_) => jsonBody(200, {})),
        sockets: sockets,
        now: DateTime.utc(2026, 10, 24, 10, 41),
      );
    });

    tearDown(() => container.dispose());

    test('the stream stops in the background and restarts on resume', () async {
      final stream = container.read(auraStreamProvider);
      await pumpEventQueue();
      expect(stream.connected.value, true);

      container.read(foregroundProvider.notifier).set(false);
      await pumpEventQueue();
      expect(stream.connected.value, false);

      container.read(foregroundProvider.notifier).set(true);
      await pumpEventQueue();
      expect(sockets, hasLength(2));
      expect(stream.connected.value, true);
    });

    test('coming back fires the refetch signal; going away does not', () {
      expect(container.read(refetchSignalProvider), 0);
      container.read(foregroundProvider.notifier).set(false);
      expect(container.read(refetchSignalProvider), 0);
      container.read(foregroundProvider.notifier).set(true);
      expect(container.read(refetchSignalProvider), 1);
    });

    test('/me follows sign-in and refetches on the signal', () async {
      final http = FakeAdapter(
        (_) => jsonBody(200, {
          'user': tokenPairJson['user'],
          'memberships': <Object?>[],
        }),
      );
      container.dispose();
      container = testContainer(
        http: http,
        sockets: sockets,
        now: DateTime.utc(2026, 10, 24, 10, 41),
      );
      container.listen(meProvider, (_, _) {});
      await pumpEventQueue();
      final me = await container.read(meProvider.future);
      expect(me?.user.displayName, 'Nathan');
      expect(http.to('/me'), hasLength(1));

      container.read(refetchSignalProvider.notifier).fire();
      await container.read(meProvider.future);
      expect(http.to('/me'), hasLength(2));
    });
  });
}
