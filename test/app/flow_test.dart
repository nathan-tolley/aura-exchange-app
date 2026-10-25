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
}
