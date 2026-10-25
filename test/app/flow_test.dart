import 'package:aura_exchange/app.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http.dart';
import '../support/fake_socket.dart';
import '../support/providers.dart';

/// Flows through the real app: router, redirect, screens and repositories,
/// against a fake server.
void main() {
  testWidgets('sign in from scratch lands on creating an exchange', (
    tester,
  ) async {
    final http = FakeAdapter(
      (r) => switch (r.path) {
        '/auth/email/start' => ResponseBody.fromString('', 204),
        '/auth/email/verify' => jsonBody(200, tokenPairJson),
        '/me' => jsonBody(200, {
          'user': tokenPairJson['user'],
          'memberships': <Object?>[],
        }),
        _ => errorBody(404, 'NOT_FOUND'),
      },
    );
    final container = testContainer(
      http: http,
      sockets: <FakeSocket>[],
      now: DateTime.utc(2026, 10, 24, 10, 41),
      tokens: null,
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const AuraApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text(signInTitle), findsOneWidget);

    await tester.enterText(
      find.byType(CupertinoTextField),
      'nathan@example.com',
    );
    await tester.pump();
    await tester.tap(find.text(sendCode));
    await tester.pumpAndSettle();
    expect(find.text(checkYourEmail), findsOneWidget);
    expect(find.text(codeSentTo('nathan@example.com')), findsOneWidget);

    // The sixth digit signs in by itself.
    await tester.enterText(find.byType(CupertinoTextField), '482913');
    await tester.pumpAndSettle();
    expect(find.text(checkYourEmail), findsNothing);
    expect(find.text(signInTitle), findsNothing);
    expect(http.to('/auth/email/verify'), hasLength(1));
    expect(http.to('/me'), hasLength(1));
  });

  testWidgets('create an exchange, invite, then on to your IPO', (
    tester,
  ) async {
    const id = '7c1d2e3f-0a1b-4c5d-8e9f-a0b1c2d3e4f5';
    final membership = {
      'id': '22222222-0000-4000-8000-000000000001',
      'exchangeId': id,
      'role': 'ADMIN',
      'listing': null,
      'listingConsentAt': null,
      'joinedAt': '2026-10-24T10:40:00Z',
      'badges': <String>[],
      'superInjunctionsLeft': 3,
    };
    final exchange = {
      'id': id,
      'name': 'Test Exchange',
      'timezone': 'Australia/Sydney',
      'hours': {
        'preOpen': '07:00',
        'open': '09:00',
        'close': '22:00',
        'afterClose': '02:00',
      },
      'feeRate': '0.50',
      'extendedFeeRate': '1.50',
      'listedCount': 0,
      'memberCount': 1,
      'minListingsToOpen': 3,
      'season': {
        'id': '33333333-0000-4000-8000-000000000001',
        'number': 1,
        'startsAt': '2026-10-24T10:30:00Z',
        'endsAt': '2026-12-19T10:30:00Z',
      },
      'me': membership,
    };
    var created = false;
    final http = FakeAdapter((r) {
      switch (r.path) {
        case '/me':
          return jsonBody(200, {
            'user': tokenPairJson['user'],
            'memberships': created ? [membership] : <Object?>[],
          });
        case '/exchanges':
          created = true;
          return jsonBody(201, exchange);
        case '/exchanges/$id':
          return jsonBody(200, exchange);
        case '/exchanges/$id/invites':
          return jsonBody(201, {
            'code': 'NATE-7F2K',
            'url': 'https://aura.example/i/NATE-7F2K',
            'expiresAt': '2026-10-31T10:41:00Z',
          });
      }
      return errorBody(404, 'NOT_FOUND');
    });
    final container = testContainer(
      http: http,
      sockets: <FakeSocket>[],
      now: DateTime.utc(2026, 10, 24, 10, 41),
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const AuraApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text(createTitle), findsOneWidget);

    await tester.enterText(find.byType(CupertinoTextField), 'Test Exchange');
    await tester.pump();
    await tester.tap(find.text(continueLabel));
    await tester.pumpAndSettle();
    expect(find.text(whenItTradesTitle), findsOneWidget);

    await tester.tap(find.text(createExchange));
    await tester.pumpAndSettle();
    expect(find.text(inviteTitle), findsOneWidget);
    expect(find.text('NATE-7F2K'), findsOneWidget);

    await tester.tap(find.text(continueLabel));
    await tester.pumpAndSettle();
    expect(find.text(waitingTitle), findsOneWidget);
    expect(find.text('0 of 3'), findsOneWidget);

    await tester.tap(find.text(listYourself));
    await tester.pumpAndSettle();
    expect(find.text(waitingTitle), findsNothing);
    expect(http.to('/exchanges').single.data, {
      'name': 'Test Exchange',
      'timezone': isA<String>(),
    });
  });
}
