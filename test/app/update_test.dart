import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/app.dart';
import 'package:aura_exchange/data/api_providers.dart';
import 'package:aura_exchange/data/live_market.dart';
import 'package:aura_exchange/features/market/market_model.dart';
import 'package:aura_exchange/features/system/problem_view.dart';
import 'package:aura_exchange/design/widgets/aura_banner.dart';
import 'package:aura_exchange/data/freshness.dart';
import 'package:aura_exchange/format/time.dart';
import 'package:aura_exchange/api/generated/export.dart' hide Freshness;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/api_json.dart';
import '../support/fake_http.dart';
import '../support/fake_socket.dart';
import '../support/providers.dart';

/// App-wide states (SCREENS.md #23, #24) that can happen on any screen.
void main() {
  testWidgets('a 426 on any request puts the update screen over the app', (
    tester,
  ) async {
    var tooOld = false;
    final http = FakeAdapter(
      (r) => tooOld
          ? errorBody(
              426,
              'UPDATE_REQUIRED',
              params: {'minBuild': '12'},
              action: 'UPDATE_APP',
            )
          : switch (r.path) {
              '/me' => jsonBody(200, meJson([membershipJson()])),
              '/exchanges/$testExchangeId' => jsonBody(
                200,
                exchangeJson(listed: 4, members: 5, meListed: true),
              ),
              '/exchanges/$testExchangeId/market' => jsonBody(
                200,
                marketJson(),
              ),
              '/exchanges/$testExchangeId/portfolio' => jsonBody(
                200,
                exampleJson('portfolio'),
              ),
              _ => jsonBody(200, {'items': <Object?>[], 'nextCursor': null}),
            },
    );
    final container = testContainer(
      http: http,
      sockets: <FakeSocket>[],
      now: DateTime.utc(2026, 10, 24, 10, 41),
    );
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const AuraApp()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProblemView), findsNothing);

    tooOld = true;
    container.read(marketProvider(testExchangeId).notifier).refresh().ignore();
    await tester.pumpAndSettle();
    expect(container.read(updateRequiredProvider)?.params['minBuild'], '12');
    expect(find.text('Update to keep trading'), findsOneWidget);

    tooOld = false;
    await tester.tap(find.text('Check again'));
    await tester.pumpAndSettle();
    expect(find.byType(ProblemView), findsNothing);

    await tester.pumpWidget(const SizedBox());
    container.dispose();
  });

  test('the exchange down after numbers were shown: a down banner', () {
    final market = LiveMarket.from(Market.fromJson(marketJson())).withProblem(
      const ApiError(
        code: 'SERVER',
        params: {'reference': '7F2K'},
        retryable: true,
        action: ApiAction.retry,
        status: 500,
      ),
    );
    final m = marketListModel(
      market: market,
      liveness: Liveness.delayed,
      query: '',
      zone: exchangeZone('Australia/Sydney'),
      now: DateTime.utc(2026, 10, 24, 10, 50),
    );
    expect(m.banner?.tone, AuraBannerTone.down);
    expect(m.banner?.title, 'The exchange is down');
    expect(m.rows, isNotEmpty);
  });
}
