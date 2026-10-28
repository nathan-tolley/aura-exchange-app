import 'package:aura_exchange/app.dart';
import 'package:aura_exchange/features/portfolio/liquidated_view.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:aura_exchange/router.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/api_json.dart';
import '../support/fake_http.dart';
import '../support/fake_socket.dart';
import '../support/providers.dart';

/// A position through the real app (SCREENS.md #22): a liquidated short
/// opens its receipt (W08) from `Position.liquidation`.
void main() {
  const positionId = '55555555-0000-4000-8000-000000000001';
  const jake = '11111111-0000-4000-8000-000000000002';
  late FakeAdapter http;
  late ProviderContainer container;
  late List<Map<String, Object?>> tape;

  final liquidated = {
    'id': positionId,
    'listing': {
      'id': jake,
      'ticker': r'$JAKE',
      'displayName': 'Jake',
      'avatarUrl': null,
    },
    'side': 'SHORT',
    'status': 'LIQUIDATED',
    'quantity': '60',
    'avgPrice': '97.50',
    'marketPrice': '118.10',
    'marketValue': '0.00',
    'unrealizedPnl': '0.00',
    'unrealizedPnlPct': '0.00',
    'short': null,
    'openedAt': '2026-10-20T01:00:00Z',
    'closedAt': '2026-10-24T04:12:00Z',
    'liquidation': {
      'at': '2026-10-24T04:12:00Z',
      'triggerPrice': '117.00',
      'maintenanceRatioPct': '125.00',
      'collateral': '8775.00',
      'price': '118.10',
      'cost': '7086.00',
      'feeRate': '0.50',
      'fee': '35.43',
      'returned': '1653.57',
      'realizedPnl': '-1271.43',
      'realizedPnlPct': '-21.73',
    },
  };
  Map<String, Object?> tapeItem(String type, String at, String headline) => {
    'id': '66666666-0000-4000-8000-00000000000${tape.length + 1}',
    'type': type,
    'at': at,
    'listing': liquidated['listing'],
    'headline': headline,
    'body': null,
    'impact': null,
    'priceMovePct': '15.00',
    'eventId': null,
    'haltId': null,
  };

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
    '/exchanges/$testExchangeId/tape' => jsonBody(200, {
      'items': tape,
      'nextCursor': null,
    }),
    '/positions/$positionId' => jsonBody(200, liquidated),
    _ => errorBody(404, 'NOT_FOUND'),
  };

  Future<void> openPosition(WidgetTester tester) async {
    container = testContainer(
      http: http,
      sockets: <FakeSocket>[],
      now: DateTime.utc(2026, 10, 24, 4, 20),
    );
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const AuraApp()),
    );
    await tester.pumpAndSettle();
    container.read(routerProvider).go(Routes.position(positionId));
    await tester.pumpAndSettle();
  }

  Future<void> done(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
  }

  setUp(() {
    tape = [];
    http = FakeAdapter(answer);
  });

  testWidgets('a liquidated short opens its receipt, with the tape line', (
    tester,
  ) async {
    tape = [
      tapeItem('WHALE', '2026-10-24T04:00:00Z', r'Someone loads up on $JAKE'),
      tapeItem(
        'LIQUIDATION',
        '2026-10-24T04:12:05Z',
        'One short seller forcibly removed from the position.',
      ),
    ];
    await openPosition(tester);
    expect(find.byType(LiquidatedView), findsOneWidget);
    expect(find.text(liquidatedTitle(r'$JAKE')), findsOneWidget);
    // In Sydney's time, from the settlement the server sent: the why line
    // and the tape line's source.
    expect(find.textContaining('3:12 pm'), findsNWidgets(2));
    expect(find.text(r'A$8,775.00'), findsOneWidget);
    expect(find.text(feeLabel(Decimal.parse('0.50'))), findsOneWidget);
    expect(find.textContaining('forcibly removed'), findsOneWidget);
    expect(find.textContaining('loads up'), findsNothing);
    await done(tester);
  });

  testWidgets('without the tape line, the receipt stands alone', (
    tester,
  ) async {
    await openPosition(tester);
    expect(find.byType(LiquidatedView), findsOneWidget);
    expect(find.text(onTheTape), findsNothing);
    await done(tester);
  });
}
