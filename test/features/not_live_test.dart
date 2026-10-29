import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/app.dart';
import 'package:aura_exchange/design/icons.dart';
import 'package:aura_exchange/features/system/problem_view.dart';
import 'package:aura_exchange/features/tape/tape_view.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/api_json.dart';
import '../support/fake_http.dart';
import '../support/fake_socket.dart';
import '../support/providers.dart';

/// An endpoint the server doesn't serve yet answers `NOT_FOUND` for the
/// route. That's a part of the app that isn't live, not a crash: the live
/// API did this for the tape and the inbox in v1.0.0.4.
void main() {
  late FakeAdapter http;
  late ProviderContainer container;

  ResponseBody answer(RequestOptions r) => switch (r.path) {
    '/me' => jsonBody(200, meJson([membershipJson()])),
    '/exchanges/$testExchangeId' => jsonBody(
      200,
      exchangeJson(listed: 4, members: 5, meListed: true),
    ),
    '/exchanges/$testExchangeId/market' => jsonBody(200, marketJson()),
    '/exchanges/$testExchangeId/portfolio' => jsonBody(
      200,
      exampleJson('portfolio'),
    ),
    // As the live API answers today.
    _ => errorBody(404, 'NOT_FOUND', params: {'resource': 'route'}),
  };

  Future<void> pumpApp(WidgetTester tester) async {
    container = testContainer(
      http: http,
      sockets: <FakeSocket>[],
      now: DateTime.utc(2026, 10, 24, 13, 21),
    );
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const AuraApp()),
    );
  }

  Future<void> done(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
  }

  setUp(() => http = FakeAdapter(answer));

  test('only a missing route reads as not live', () {
    const route = ApiError(
      code: 'NOT_FOUND',
      params: {'resource': 'route'},
      retryable: false,
      action: ApiAction.none,
    );
    const event = ApiError(
      code: 'NOT_FOUND',
      params: {'resource': 'event'},
      retryable: false,
      action: ApiAction.none,
    );
    expect(route.isNotServed, isTrue);
    expect(event.isNotServed, isFalse);
    expect(problemModel(route).title, notLiveTitle);
    expect(problemModel(route).icon, AuraIcons.clock);
    expect(problemModel(route).secondary, isNull);
    expect(problemModel(event).title, isNot(notLiveTitle));
  });

  testWidgets('the Tape tab says it isn\'t live yet and keeps the tab bar', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Tape'));
    await tester.pumpAndSettle();
    expect(find.byType(ProblemView), findsNothing);
    expect(find.byType(TapeView), findsOneWidget);
    expect(find.text(tapeNotLiveTitle), findsOneWidget);

    // The other tabs are still a tap away.
    await tester.tap(find.bySemanticsLabel('Market'));
    await tester.pumpAndSettle();
    expect(find.byType(TapeView), findsNothing);
    await done(tester);
  });
}
