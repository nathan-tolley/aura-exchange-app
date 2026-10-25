import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/api/generated/export.dart';
import 'package:aura_exchange/app.dart';
import 'package:aura_exchange/design/widgets/aura_banner.dart';
import 'package:aura_exchange/features/onboarding/join_model.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:aura_exchange/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http.dart';
import '../support/fake_socket.dart';
import '../support/providers.dart';

/// Join an exchange (SCREENS.md #2).
void main() {
  const exchangeId = '7c1d2e3f-0a1b-4c5d-8e9f-a0b1c2d3e4f5';
  Map<String, Object?> previewJson(String status) => {
    'code': 'JAKE-7F2K',
    'exchangeName': 'The Group Chat',
    'listed': [
      {
        'id': '11111111-0000-4000-8000-000000000002',
        'ticker': r'$JAKE',
        'displayName': 'Jake',
        'avatarUrl': null,
      },
    ],
    'memberCount': 4,
    'expiresAt': '2026-10-31T10:41:00Z',
    'status': status,
  };
  JoinModel model({
    String status = 'VALID',
    ApiError? previewError,
    ApiError? joinError,
    bool inAnExchange = false,
    bool noPreview = false,
  }) => joinModel(
    code: 'JAKE-7F2K',
    preview: noPreview ? null : InvitePreview.fromJson(previewJson(status)),
    previewError: previewError,
    joinError: joinError,
    joining: false,
    inAnExchange: inAnExchange,
  );

  group('wording', () {
    test('a valid invite shows who is in it and who is listed', () {
      final m = model();
      expect(m.title, 'Join The Group Chat');
      expect(
        m.body,
        '4 people are in it, 1 listed. You pick your ticker after you join.',
      );
      expect(m.listed, [(r'$JAKE', 'Jake')]);
      expect(m.kind, JoinKind.join);
      expect(m.note, 'Invite JAKE-7F2K');
    });

    test('expired and full offer a way out, depending on where you are', () {
      expect(model(status: 'EXPIRED').title, 'This invite has expired');
      expect(model(status: 'EXPIRED').kind, JoinKind.startOwn);
      expect(model(status: 'FULL').title, 'The Group Chat is full');
      expect(
        model(status: 'FULL', inAnExchange: true).kind,
        JoinKind.openExchange,
      );
      expect(model(status: 'FULL', inAnExchange: true).action, openTheExchange);
    });

    test('a join refused at the last moment shows the same', () {
      final m = model(
        joinError: const ApiError(
          code: 'EXCHANGE_FULL',
          params: {'maxMembers': '12'},
          retryable: false,
          action: ApiAction.none,
          status: 409,
        ),
      );
      expect(m.title, 'The Group Chat is full');
      expect(m.body, startsWith('It has 12 people'));
    });

    test('a link that leads nowhere, loading, and offline', () {
      final missing = model(
        noPreview: true,
        previewError: const ApiError(
          code: 'NOT_FOUND',
          retryable: false,
          action: ApiAction.none,
          status: 404,
        ),
      );
      expect(missing.title, inviteDoesntWork);
      final loading = model(noPreview: true);
      expect(loading.kind, JoinKind.loading);
      expect(loading.canAct, isFalse);
      final offline = model(
        noPreview: true,
        previewError: const ApiError.offline(),
      );
      expect(offline.banner?.tone, AuraBannerTone.offline);
    });
  });

  testWidgets('an invite link signed out: sign in, then join, then IPO', (
    tester,
  ) async {
    var joined = false;
    final membership = {
      'id': '22222222-0000-4000-8000-000000000009',
      'exchangeId': exchangeId,
      'role': 'MEMBER',
      'listing': null,
      'listingConsentAt': null,
      'joinedAt': '2026-10-24T10:40:00Z',
      'badges': <String>[],
      'superInjunctionsLeft': 3,
    };
    final http = FakeAdapter((r) {
      switch (r.path) {
        case '/auth/email/start':
          return jsonBody(200, <String, Object?>{});
        case '/auth/email/verify':
          return jsonBody(200, tokenPairJson);
        case '/me':
          return jsonBody(200, {
            'user': tokenPairJson['user'],
            'memberships': joined ? [membership] : <Object?>[],
          });
        case '/invites/JAKE-7F2K':
          return jsonBody(200, previewJson('VALID'));
        case '/invites/JAKE-7F2K/accept':
          joined = true;
          return jsonBody(200, membership);
      }
      return errorBody(404, 'NOT_FOUND');
    });
    final container = testContainer(
      http: http,
      sockets: <FakeSocket>[],
      now: DateTime.utc(2026, 10, 24, 10, 41),
      tokens: null,
    );
    addTearDown(container.dispose);
    // Reduce Motion: skeletons hold still, so the app can settle.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const AuraApp()),
    );
    await tester.pumpAndSettle();
    // aura://invite/JAKE-7F2K arrives as this route.
    container.read(routerProvider).go(Routes.invite('JAKE-7F2K'));
    await tester.pumpAndSettle();
    expect(find.text(signInTitle), findsOneWidget);

    await tester.enterText(find.byType(CupertinoTextField), 'nate@example.com');
    await tester.pump();
    await tester.tap(find.text(sendCode));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), '482913');
    await tester.pumpAndSettle();

    expect(find.text('Join The Group Chat'), findsOneWidget);
    await tester.tap(find.text(joinTheExchange));
    await tester.pumpAndSettle();
    expect(find.text(ipoTitle), findsOneWidget);
    expect(http.to('/invites/JAKE-7F2K/accept'), hasLength(1));
  });
}
