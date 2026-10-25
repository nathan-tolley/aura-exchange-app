@Tags(['prism'])
library;

import 'dart:io';

import 'package:aura_exchange/api/client.dart';
import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/api/generated/export.dart' hide Freshness;
import 'package:aura_exchange/api/session.dart';
import 'package:aura_exchange/data/api_providers.dart';
import 'package:aura_exchange/data/live_market.dart';
import 'package:aura_exchange/data/repositories.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_socket.dart';
import '../support/providers.dart';

/// The A2 check (ROADMAP.md): the repositories against Prism, which serves
/// `api/openapi.yaml`'s examples, including every error code forced with
/// `Prefer: code=…, example=…` mapping to the right `ApiError`.
///
///   npx @stoplight/prism-cli mock api/openapi.yaml
///   flutter test --tags prism --run-skipped
void main() {
  const prism = 'http://127.0.0.1:4010';
  const id = '3f2b8c1e-5d4a-4e7b-9a10-2c6d8e9f0a1b';

  late ProviderContainer container;
  late List<FakeSocket> sockets;
  String? prefer;

  setUpAll(() async {
    // flutter_test answers every HTTP request with 400 unless told not to.
    HttpOverrides.global = null;
    try {
      await Dio().get<Object?>('$prism/health');
    } on DioException catch (e) {
      fail(
        'Prism is not answering on :4010 ($e). Start it with: '
        'npx @stoplight/prism-cli mock api/openapi.yaml',
      );
    }
  });

  /// The app's providers against Prism, with a `Prefer` header when set.
  ProviderContainer open({Tokens? tokens = signedInTokens}) {
    final opened = testContainer(
      http: HttpClientAdapter(),
      sockets: sockets,
      now: DateTime.now(),
      baseUrl: prism,
      tokens: tokens,
    );
    opened
        .read(auraClientProvider)
        .dio
        .interceptors
        .add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (prefer case final String value) {
                options.headers['Prefer'] = value;
              }
              // Prism checks that a bearer is there, not what it is.
              options.headers.putIfAbsent('Authorization', () => 'Bearer x');
              handler.next(options);
            },
          ),
        );
    return opened;
  }

  setUp(() {
    sockets = [];
    prefer = null;
    container = open();
  });

  tearDown(() => container.dispose());

  group('repositories decode the examples', () {
    test('system: health', () async {
      final health = await container.read(systemRepositoryProvider).health();
      expect(health.status, HealthStatus.ok);
    });

    test('market: the live market and a listing', () async {
      container.listen(marketProvider(id), (_, _) {});
      final market = await container.read(marketProvider(id).future);
      final anna = market.listings.single;
      expect(anna.summary.ticker, r'$ANNA');
      expect(anna.price, Decimal.parse('124.10'));
      expect(anna.changeAbs, Decimal.parse('7.79'));
      final listing = await container
          .read(marketRepositoryProvider)
          .listing(id);
      expect(Decimal.parse(listing.price), greaterThan(Decimal.zero));
    });

    test('trading: quote, trade and portfolio', () async {
      final trading = container.read(tradingRepositoryProvider);
      final quote = await trading.quote(
        const QuoteRequest(listingId: id, side: Side.buy, quantity: '20'),
        IdempotencyKey(),
      );
      expect(quote.total, '2494.41');
      final trade = await trading.trade(quote.id, IdempotencyKey());
      expect(Decimal.parse(trade.total), greaterThan(Decimal.zero));
      final portfolio = await trading.portfolio(id);
      expect(portfolio.netWorth, '12486.20');
    });

    test('auth: send a code, verify it, sign out', () async {
      final auth = container.read(authRepositoryProvider);
      final session = container.read(authSessionProvider);
      await auth.sendCode('nathan@example.com', IdempotencyKey());
      final user = await auth.verifyCode(
        'nathan@example.com',
        '123456',
        IdempotencyKey(),
      );
      expect(user.displayName, isNotEmpty);
      expect(session.signedIn.value, true);
      await auth.signOut(IdempotencyKey());
      expect(session.signedIn.value, false);
    });
  });

  group('every error code, forced', () {
    // The contract's table: | HTTP | code | params | retryable | action | …
    final table = RegExp(
      r'^\| (\d{3}) \| `([A-Z_]+)` \|[^|]*\| (yes|no) \| ([A-Z_]+) \|',
      multiLine: true,
    ).allMatches(File('docs/aura/API-CONTRACT.md').readAsStringSync());

    test('the table covers the spec', () {
      expect(
        table.map((m) => m.group(2)).toSet(),
        ErrorCode.$valuesDefined.map((c) => c.json).toSet(),
      );
    });

    for (final row in table) {
      final status = int.parse(row.group(1)!);
      final code = row.group(2)!;
      final retryable = row.group(3) == 'yes';
      final action = ApiAction.parse(row.group(4));

      test('$status $code → ${action.json}', () async {
        if (code == 'AUTH_EXPIRED') {
          // Signed in, the client would refresh against Prism and replay with
          // Prism's example token, `eyJhbGciOi…`, whose "…" can't go in a
          // header (contract request #5). Signed out, it passes the error on.
          // test/api/client_test.dart covers the refresh and replay.
          container.dispose();
          container = open(tokens: null);
        }
        prefer = 'code=$status, example=$code';
        final trading = container.read(tradingRepositoryProvider);
        // POST /quotes declares every error status but 404.
        final call = status == 404
            ? container.read(marketRepositoryProvider).listing(id)
            : trading.quote(
                const QuoteRequest(
                  listingId: id,
                  side: Side.buy,
                  quantity: '20',
                ),
                IdempotencyKey(),
              );
        final error = await call.then<ApiError?>(
          (_) => null,
          onError: (Object e) => e as ApiError,
        );
        expect(error, isNotNull, reason: 'Prism answered 2xx');
        expect(error!.code, code);
        expect(error.status, status);
        expect(error.action, action);
        expect(error.retryable, retryable);
        final copy = errorCopy(error);
        expect(copy.title, isNot('Something went wrong'));
      });
    }
  });
}
