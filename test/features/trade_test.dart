import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/api/generated/export.dart' hide Freshness;
import 'package:aura_exchange/features/trade/trade_flow.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http.dart';
import '../support/fake_socket.dart';
import '../support/providers.dart';

/// The trade flow (SCREENS.md #9, #10) against a fake server.
void main() {
  // Haptics go through a platform channel.
  TestWidgetsFlutterBinding.ensureInitialized();
  const listing = '11111111-0000-4000-8000-000000000001';
  var quoteN = 0;
  Map<String, Object?> quote({String? previous}) => {
    'asOf': DateTime.now().toUtc().toIso8601String(),
    'marketState': 'OPEN',
    'nextChangeAt': null,
    'id': '22222222-0000-4000-8000-00000000000${++quoteN}',
    'listingId': listing,
    'side': 'BUY',
    'quantity': '12',
    'price': '124.10',
    'gross': '1489.20',
    'feeRate': '0.50',
    'fee': '7.45',
    'total': '1496.65',
    'priceImpactPct': '0.40',
    'currentPrice': '124.10',
    'expiresAt': DateTime.now()
        .toUtc()
        .add(const Duration(seconds: 15))
        .toIso8601String(),
    'previous': previous == null
        ? null
        : {
            'quoteId': previous,
            'price': '123.00',
            'total': '1483.00',
            'changePct': '0.89',
          },
    'short': null,
    'cashAfter': '767.85',
  };
  final trade = {
    'id': '33333333-0000-4000-8000-000000000001',
    'quoteId': '22222222-0000-4000-8000-000000000001',
    'listing': {
      'id': listing,
      'ticker': r'$ANNA',
      'displayName': 'Anna',
      'avatarUrl': null,
    },
    'side': 'BUY',
    'quantity': '12',
    'price': '124.10',
    'fee': '7.45',
    'total': '1496.65',
    'cashAfter': '767.85',
    'position': null,
    'executedAt': '2026-10-24T10:41:00Z',
  };

  late FakeAdapter http;
  late ProviderContainer container;
  const args = (
    listingId: listing,
    side: Side.buy,
    marketOpen: true,
    quantity: 1,
  );

  setUp(() {
    quoteN = 0;
    http = FakeAdapter(
      (r) => switch (r.path) {
        '/quotes' => jsonBody(
          201,
          quote(previous: (r.data as Map)['previousQuoteId'] as String?),
        ),
        '/trades' => jsonBody(201, trade),
        _ => errorBody(404, 'NOT_FOUND'),
      },
    );
    container = testContainer(
      http: http,
      sockets: <FakeSocket>[],
      now: DateTime.utc(2026, 10, 24, 10, 41),
    );
    container.listen(tradeFlowProvider(args), (_, _) {});
  });

  tearDown(() => container.dispose());

  TradeFlow flow() => container.read(tradeFlowProvider(args).notifier);
  TradeFlowState state() => container.read(tradeFlowProvider(args));
  String? keyOf(RequestOptions r) => r.headers['Idempotency-Key'] as String?;

  test('prices on open, and trades the quote when the slide lands', () async {
    await pumpEventQueue();
    expect(state().quote, isNotNull);
    expect(state().orderType, orderMarket);
    final filled = await flow().trade();
    expect(filled?.id, '33333333-0000-4000-8000-000000000001');
    expect(http.to('/trades').single.data, {
      'quoteId': '22222222-0000-4000-8000-000000000001',
    });
  });

  test('offline, then Retry: the same trade key, so it trades once', () async {
    await pumpEventQueue();
    http.handler = offline;
    await flow().trade();
    expect(state().problem?.code, ApiError.appOffline);
    http.handler = (_) => jsonBody(201, trade);
    await flow().retry();
    final trades = http.to('/trades');
    expect(trades, hasLength(2));
    expect(keyOf(trades[0]), keyOf(trades[1]));
    expect(state().filled, isNotNull);
  });

  test('a stale quote requotes with the previous id (W06)', () async {
    await pumpEventQueue();
    final first = state().quote!.id;
    final answer = http.handler;
    http.handler = (r) => r.path == '/trades'
        ? errorBody(
            409,
            'QUOTE_STALE',
            params: {
              'oldPrice': '124.10',
              'newPrice': '125.36',
              'changePct': '1.02',
            },
            retryable: true,
            action: 'REQUOTE',
          )
        : answer(r);
    await flow().trade();
    expect(state().stale?.code, 'QUOTE_STALE');
    expect(state().quote?.previous?.quoteId, first);
    expect(
      http.to('/quotes').last.data,
      containsPair('previousQuoteId', first),
    );

    http.handler = answer;
    await flow().trade();
    final trades = http.to('/trades');
    expect(keyOf(trades[0]), isNot(keyOf(trades[1])));
    expect(state().filled, isNotNull);
  });

  test('a refusal offers the fix, and the fix sets the quantity', () async {
    await pumpEventQueue();
    http.handler = (r) => r.path == '/trades'
        ? errorBody(
            422,
            'INSUFFICIENT_CASH',
            params: {'shortBy': '229.91', 'maxQuantity': '18'},
            action: 'REDUCE_QUANTITY',
          )
        : jsonBody(201, quote());
    await flow().trade();
    expect(state().problem?.action, ApiAction.reduceQuantity);
    flow().applyFix();
    expect(state().quantity, 18);
    expect(state().problem, isNull);
  });

  test('a limit order needs a price, and rests', () async {
    await pumpEventQueue();
    flow().setOrderType(orderLimit);
    expect(await flow().placeOrder(), isNull);
    http.handler = (_) => jsonBody(201, {
      'id': '66666666-0000-4000-8000-000000000001',
      'listing': trade['listing'],
      'type': 'LIMIT_BUY',
      'quantity': '1',
      'triggerPrice': '118.00',
      'status': 'RESTING',
      'reservedCash': '118.59',
      'createdAt': '2026-10-24T10:41:00Z',
      'filledAt': null,
      'fillPrice': null,
      'rejectCode': null,
    });
    flow().setPrice('118');
    final order = await flow().placeOrder();
    expect(order?.status, OrderStatus.resting);
    expect(http.to('/orders').single.data, {
      'listingId': listing,
      'type': OrderType.limitBuy,
      'quantity': '1',
      'triggerPrice': '118.00',
    });
  });
}
