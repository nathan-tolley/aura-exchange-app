import 'dart:convert';
import 'dart:io';

import 'package:aura_exchange/api/client.dart';
import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/api/generated/export.dart' hide Freshness;
import 'package:aura_exchange/api/stream.dart';
import 'package:aura_exchange/data/api_providers.dart';
import 'package:aura_exchange/data/freshness.dart';
import 'package:aura_exchange/data/live_market.dart';
import 'package:aura_exchange/data/repositories.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http.dart';
import '../support/fake_socket.dart';
import '../support/providers.dart';

/// The data layer: the live market (REST with ticks on top), the Freshness
/// rule, and the stream following sign-in.
void main() {
  // The spec's example market: one listing, $ANNA at 124.10, asOf 13:21 UTC.
  const exchange = '3f2b8c1e-5d4a-4e7b-9a10-2c6d8e9f0a1b';
  const anna = '3f2b8c1e-5d4a-4e7b-9a10-2c6d8e9f0a1b';
  final asOf = DateTime.utc(2026, 10, 24, 13, 21);
  final marketJson = jsonDecode(
    File('test/fixtures/api/market.json').readAsStringSync(),
  ) as Map<String, Object?>;

  late FakeAdapter http;
  late List<FakeSocket> sockets;
  late ProviderContainer container;

  setUp(() {
    http = FakeAdapter((_) => jsonBody(200, marketJson));
    sockets = [];
    container = testContainer(http: http, sockets: sockets, now: asOf);
  });

  tearDown(() => container.dispose());

  /// Keeps the market alive and waits for it to load.
  Future<LiveMarket> load() async {
    container.listen(marketProvider(exchange), (_, _) {});
    return container.read(marketProvider(exchange).future);
  }

  LiveMarket shown() => container.read(marketProvider(exchange)).requireValue;

  void tick(String price, String pct, {DateTime? at, String id = anna}) {
    sockets.last.receive({
      'type': 'ticks',
      'exchangeId': id == anna ? exchange : 'other',
      'asOf': (at ?? asOf.add(const Duration(seconds: 15))).toIso8601String(),
      'marketState': 'OPEN',
      'listings': [
        {'id': anna, 'price': price, 'changePct': pct, 'state': 'ACTIVE'},
      ],
    });
  }

  group('live market', () {
    test('loads over REST and subscribes on the socket', () async {
      final market = await load();
      expect(http.requests.single.path, '/exchanges/$exchange/market');
      expect(market.freshness.asOf, asOf);
      final listing = market.listings.single;
      expect(listing.price, Decimal.parse('124.10'));
      expect(listing.changeAbs, Decimal.parse('7.79'));
      expect(sockets.single.sent, [
        {'type': 'subscribe', 'exchangeId': exchange},
      ]);
    });

    test('ticks move prices and freshness', () async {
      await load();
      tick('124.10', '6.70');
      await pumpEventQueue();
      final listing = shown().listings.single;
      expect(listing.price, Decimal.parse('124.10'));
      expect(listing.changePct, Decimal.parse('6.70'));
      // Derived from the tick's own numbers (contract request #3).
      expect(listing.changeAbs, Decimal.parse('7.79'));
      expect(shown().freshness.asOf, asOf.add(const Duration(seconds: 15)));
      expect(shown().freshness.marketState, MarketState.open);

      tick('101.90', '-9.34');
      await pumpEventQueue();
      expect(shown().listings.single.changeAbs, Decimal.parse('-10.50'));
    });

    test("ignores old ticks and other exchanges' ticks", () async {
      await load();
      tick('130.00', '10.00', at: asOf.subtract(const Duration(minutes: 1)));
      tick('130.00', '10.00', id: 'elsewhere');
      await pumpEventQueue();
      expect(shown().listings.single.price, Decimal.parse('124.10'));
      expect(shown().freshness.asOf, asOf);
    });

    test('market messages change the state', () async {
      await load();
      sockets.last.receive({
        'type': 'market',
        'exchangeId': exchange,
        'marketState': 'CLOSED',
        'nextChangeAt': '2026-10-24T20:00:00Z',
      });
      await pumpEventQueue();
      expect(shown().freshness.marketState, MarketState.closed);
      expect(shown().freshness.nextChangeAt, DateTime.utc(2026, 10, 24, 20));
    });

    test('refetches after a reconnect, dropping old ticks', () async {
      await load();
      tick('130.00', '10.00');
      await pumpEventQueue();
      sockets.last.serverClose(1006);
      await pumpEventQueue();
      // The stream's backoff is a real 1 s timer here.
      await Future<void>.delayed(const Duration(milliseconds: 1300));
      await pumpEventQueue();
      expect(sockets, hasLength(2));
      expect(http.to('/exchanges/$exchange/market'), hasLength(2));
      expect(shown().ticks, isEmpty);
      expect(shown().listings.single.price, Decimal.parse('124.10'));
    });

    test('a failed refetch keeps the numbers and says why', () async {
      await load();
      http.handler = offline;
      await container.read(marketProvider(exchange).notifier).refresh();
      expect(shown().listings.single.price, Decimal.parse('124.10'));
      expect(shown().problem?.code, ApiError.appOffline);

      http.handler = (_) => jsonBody(200, marketJson);
      await container.read(marketProvider(exchange).notifier).refresh();
      expect(shown().problem, isNull);
    });

    test('a first load that fails is an ApiError', () async {
      http.handler = (_) => errorBody(
        503,
        'MAINTENANCE',
        params: {'reference': '7F2K'},
        retryable: true,
        action: 'RETRY',
      );
      container.listen(marketProvider(exchange), (_, _) {});
      await expectLater(
        container.read(marketProvider(exchange).future),
        throwsA(isA<ApiError>().having((e) => e.code, 'code', 'MAINTENANCE')),
      );
    });

    test(
      'refetches each time a poll is due while the socket is down',
      () async {
        await load();
        sockets.last.serverClose(1006);
        await pumpEventQueue();
        // The stream sends PollDue every 15 s while down; drive one by hand.
        final stream = container.read(auraStreamProvider);
        expect(stream.connected.value, false);
        expect(stream.exchanges, {exchange});
        stream
          ..inject(const PollDue('another-exchange'))
          ..inject(const PollDue(exchange));
        await pumpEventQueue();
        expect(http.to('/exchanges/$exchange/market'), hasLength(2));
      },
    );
  });

  group('freshness', () {
    Liveness? labelled() => container.read(marketLivenessProvider(exchange));

    test('the rule', () {
      final at = DateTime.utc(2026, 10, 24, 10, 41);
      Liveness rule(MarketState state, int ageSeconds, {bool up = true}) =>
          liveness(
            Freshness(asOf: at, marketState: state),
            connected: up,
            now: at.add(Duration(seconds: ageSeconds)),
          );
      expect(rule(MarketState.open, 15), Liveness.live);
      expect(rule(MarketState.open, 60), Liveness.live);
      expect(rule(MarketState.open, 61), Liveness.delayed);
      expect(rule(MarketState.open, 5, up: false), Liveness.delayed);
      expect(rule(MarketState.closed, 3600), Liveness.closed);
      expect(rule(MarketState.closed, 5, up: false), Liveness.delayed);
    });

    test('goes Delayed on its own as the numbers age', () async {
      await load();
      container.listen(marketLivenessProvider(exchange), (_, _) {});
      // The fixture's state is PRE.
      expect(labelled(), Liveness.live);
      (container.read(clockProvider.notifier) as FixedClock).set(
        asOf.add(const Duration(seconds: 61)),
      );
      expect(labelled(), Liveness.delayed);
      tick('124.10', '6.70', at: asOf.add(const Duration(seconds: 60)));
      await pumpEventQueue();
      expect(labelled(), Liveness.live);
    });

    test('Delayed while the socket is down', () async {
      await load();
      container.listen(marketLivenessProvider(exchange), (_, _) {});
      expect(labelled(), Liveness.live);
      sockets.last.serverClose(1006);
      await pumpEventQueue();
      expect(container.read(streamConnectedProvider), false);
      expect(labelled(), Liveness.delayed);
    });
  });

  group('the stream follows sign-in', () {
    test(
      'stays down signed out, connects on sign-in, stops on sign-out',
      () async {
        container.dispose();
        container = testContainer(
          http: http,
          sockets: sockets,
          now: asOf,
          tokens: null,
        );
        final stream = container.read(auraStreamProvider);
        await pumpEventQueue();
        expect(sockets, isEmpty);

        http.handler = (_) => jsonBody(200, tokenPairJson);
        await container
            .read(authRepositoryProvider)
            .verifyCode('nathan@example.com', '123456', IdempotencyKey());
        await pumpEventQueue();
        expect(sockets, hasLength(1));
        expect(sockets.single.uri.queryParameters['access_token'], 'access-2');
        expect(stream.connected.value, true);

        http.handler = (_) => ResponseBody.fromString('', 204);
        await container.read(authRepositoryProvider).signOut(IdempotencyKey());
        expect(stream.connected.value, false);
        expect(container.read(authSessionProvider).signedIn.value, false);
        expect(http.to('/auth/logout').single.data, {
          'refreshToken': 'refresh-2',
        });
      },
    );
  });
}
