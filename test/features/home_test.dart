import 'dart:async';

import 'package:aura_exchange/app.dart';
import 'package:aura_exchange/features/home/home_loading_view.dart';
import 'package:aura_exchange/features/home/home_view.dart';
import 'package:aura_exchange/features/system/problem_view.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/api_json.dart';
import '../support/fake_http.dart';
import '../support/fake_socket.dart';
import '../support/providers.dart';

/// Home live (SCREENS.md #5) through the real app against a fake server.
void main() {
  late FakeAdapter http;
  late ProviderContainer container;
  late Map<String, Object?> exchange;

  ResponseBody answer(RequestOptions r) => switch (r.path) {
    '/me' => jsonBody(200, meJson([membershipJson()])),
    '/exchanges/$testExchangeId' => jsonBody(200, exchange),
    '/exchanges/$testExchangeId/market' => jsonBody(200, marketJson()),
    '/exchanges/$testExchangeId/portfolio' => jsonBody(
      200,
      exampleJson('portfolio'),
    ),
    '/exchanges/$testExchangeId/tape' => jsonBody(200, {
      'items': <Object?>[],
      'nextCursor': null,
    }),
    _ => errorBody(404, 'NOT_FOUND'),
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

  /// Unmounts the app and stops the stream's timers before the test ends.
  Future<void> done(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
  }

  setUp(() {
    exchange = exchangeJson(listed: 4, members: 5, meListed: true);
    http = FakeAdapter(answer);
  });

  testWidgets('shows the server numbers once they arrive', (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);
    expect(find.text(r'$ANNA'), findsWidgets);
    // Net worth, as the server valued it.
    expect(find.textContaining('12,486'), findsWidgets);
    expect(find.text(fileAnEvent), findsOneWidget);
    await done(tester);
  });

  testWidgets('skeletons first, never a spinner', (tester) async {
    final market = Completer<ResponseBody>();
    http.handler = (r) =>
        r.path.endsWith('/market') ? market.future : answer(r);
    await pumpApp(tester);
    await tester.pumpAndSettle();
    expect(find.byType(HomeLoadingView), findsOneWidget);
    market.complete(jsonBody(200, marketJson()));
    await tester.pumpAndSettle();
    expect(find.byType(HomeLoadingView), findsNothing);
    expect(find.byType(HomeView), findsOneWidget);
    await done(tester);
  });

  testWidgets('IPO day until enough are listed', (tester) async {
    exchange = exchangeJson(listed: 1, meListed: true);
    await pumpApp(tester);
    await tester.pumpAndSettle();
    expect(find.text(listedOf(1, 3)), findsOneWidget);
    expect(find.text(inviteSomeone), findsOneWidget);
    expect(find.text(fileAnEvent), findsNothing);
    await done(tester);
  });

  testWidgets('offline before anything loaded: the problem screen', (
    tester,
  ) async {
    http.handler = (r) => r.path.contains('/market') ? offline(r) : answer(r);
    await pumpApp(tester);
    await tester.pumpAndSettle();
    expect(find.byType(ProblemView), findsOneWidget);
    expect(find.text(offlineAtLaunchTitle), findsOneWidget);

    http.handler = answer;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);
    await done(tester);
  });
}
