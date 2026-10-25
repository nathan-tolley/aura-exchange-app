import 'dart:async';

import 'package:aura_exchange/api/client.dart';
import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/api/generated/export.dart';
import 'package:aura_exchange/api/session.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http.dart';

/// `lib/api/client.dart` against a fake adapter: the headers on every
/// request, and refresh-on-401 (API-CONTRACT.md → Transport).
void main() {
  const app = AppIdentity(version: '1.2.0', build: '37');
  const health = {
    'status': 'OK',
    'serverTime': '2026-10-24T13:21:00Z',
    'minBuild': 1,
    'lastGoodUpdate': null,
  };
  const quoteRequest = QuoteRequest(
    listingId: '3f2b8c1e-5d4a-4e7b-9a10-2c6d8e9f0a1b',
    side: Side.buy,
    quantity: '20',
  );

  late FakeAdapter http;
  late MemoryTokenStore store;
  late AuraClient client;

  AuraClient newClient({Tokens? tokens}) {
    store = MemoryTokenStore(tokens);
    return AuraClient(
      config: const ApiConfig(baseUrl: 'http://api.test/v1', app: app),
      tokens: store,
      adapter: http,
    );
  }

  const signedIn = Tokens(accessToken: 'access-1', refreshToken: 'refresh-1');

  /// Health answers 401 AUTH_EXPIRED to `access-1` and 200 to `access-2`;
  /// refresh answers with the `access-2` pair.
  FutureOr<ResponseBody> expiringServer(RequestOptions r) {
    if (r.path == '/auth/refresh') return jsonBody(200, tokenPairJson);
    if (r.headers['Authorization'] == 'Bearer access-1') {
      return errorBody(401, 'AUTH_EXPIRED', action: 'SIGN_IN');
    }
    return jsonBody(200, health);
  }

  setUp(() {
    http = FakeAdapter((_) => jsonBody(200, health));
    client = newClient(tokens: signedIn);
  });

  tearDown(() => client.close());

  group('headers', () {
    test('app version, build and bearer on every request', () async {
      await client.api.system.getHealth();
      final r = http.requests.single;
      expect(r.uri.toString(), 'http://api.test/v1/health');
      expect(r.headers['X-App-Version'], '1.2.0');
      expect(r.headers['X-App-Build'], '37');
      expect(r.headers['Authorization'], 'Bearer access-1');
    });

    test('no bearer when signed out', () async {
      client = newClient();
      await client.api.system.getHealth();
      expect(http.requests.single.headers.containsKey('Authorization'), false);
      expect(client.session.signedIn.value, false);
    });

    test('writes carry the idempotency key they were given', () async {
      http.handler = (_) => errorBody(422, 'INSUFFICIENT_CASH');
      final key = IdempotencyKey();
      for (var attempt = 0; attempt < 2; attempt++) {
        await expectLater(
          guardApi(
            () => client.api.trading.postQuotes(
              idempotencyKey: key.value,
              body: quoteRequest,
            ),
          ),
          throwsA(isA<ApiError>()),
        );
      }
      expect(http.requests.map((r) => r.headers['Idempotency-Key']), [
        key.value,
        key.value,
      ]);
    });
  });

  group('idempotency key', () {
    test('a UUID v4, new for each action', () {
      final a = IdempotencyKey();
      final b = IdempotencyKey();
      expect(
        a.value,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(a, isNot(b));
      expect(const IdempotencyKey.fixed('k'), const IdempotencyKey.fixed('k'));
    });
  });

  group('refresh on 401 AUTH_EXPIRED', () {
    test('refreshes once, stores the new pair and replays', () async {
      http.handler = expiringServer;
      final result = await client.api.system.getHealth();
      expect(result.status, HealthStatus.ok);
      expect(http.to('/auth/refresh'), hasLength(1));
      expect(http.to('/auth/refresh').single.data, {
        'refreshToken': 'refresh-1',
      });
      expect(http.to('/health').map((r) => r.headers['Authorization']), [
        'Bearer access-1',
        'Bearer access-2',
      ]);
      expect((await store.read())?.refreshToken, 'refresh-2');
    });

    test('the replay keeps the original idempotency key', () async {
      http.handler = (r) {
        if (r.path == '/auth/refresh') return jsonBody(200, tokenPairJson);
        if (r.headers['Authorization'] == 'Bearer access-1') {
          return errorBody(401, 'AUTH_EXPIRED', action: 'SIGN_IN');
        }
        return errorBody(422, 'INSUFFICIENT_CASH');
      };
      final key = IdempotencyKey();
      await expectLater(
        guardApi(
          () => client.api.trading.postQuotes(
            idempotencyKey: key.value,
            body: quoteRequest,
          ),
        ),
        throwsA(isA<ApiError>()),
      );
      final quotes = http.to('/quotes');
      expect(quotes, hasLength(2));
      expect(quotes.map((r) => r.headers['Idempotency-Key']).toSet(), {
        key.value,
      });
      expect(
        http.to('/auth/refresh').single.headers['Idempotency-Key'],
        isNot(key.value),
      );
    });

    test('requests that expire together share one refresh', () async {
      final refreshed = Completer<void>();
      http.handler = (r) async {
        if (r.path == '/auth/refresh') {
          await refreshed.future;
          return jsonBody(200, tokenPairJson);
        }
        return expiringServer(r);
      };
      final calls = [for (var i = 0; i < 3; i++) client.api.system.getHealth()];
      await pumpEventQueue();
      refreshed.complete();
      await Future.wait(calls);
      expect(http.to('/auth/refresh'), hasLength(1));
      expect(http.to('/health'), hasLength(6));
    });

    test(
      'a request sent on a replaced token retries without refreshing',
      () async {
        http.handler = expiringServer;
        await client.session.refreshAfter('access-1');
        expect(http.to('/auth/refresh'), hasLength(1));
        // A request that went out on access-1 before the refresh landed.
        final tokens = await client.session.refreshAfter('access-1');
        expect(tokens?.accessToken, 'access-2');
        expect(http.to('/auth/refresh'), hasLength(1));
      },
    );

    test('a rejected refresh token signs out and fails with SIGN_IN', () async {
      http.handler = (r) => r.path == '/auth/refresh'
          ? errorBody(401, 'AUTH_EXPIRED', action: 'SIGN_IN')
          : expiringServer(r);
      final error = await guardApi(client.api.system.getHealth)
          .then<ApiError?>((_) => null, onError: (Object e) => e as ApiError);
      expect(error?.errorCode, ErrorCode.authExpired);
      expect(error?.action, ApiAction.signIn);
      expect(client.session.signedIn.value, false);
      expect(await store.read(), isNull);
      expect(http.to('/health'), hasLength(1));
    });

    test('an unreachable refresh keeps the tokens and fails offline', () async {
      http.handler = (r) =>
          r.path == '/auth/refresh' ? offline(r) : expiringServer(r);
      final error = await guardApi(client.api.system.getHealth)
          .then<ApiError?>((_) => null, onError: (Object e) => e as ApiError);
      expect(error?.code, ApiError.appOffline);
      expect(error?.action, ApiAction.retry);
      expect((await store.read())?.accessToken, 'access-1');
      expect(client.session.signedIn.value, true);
    });

    test(
      'a replay that expires again is not refreshed a second time',
      () async {
        http.handler = (r) => r.path == '/auth/refresh'
            ? jsonBody(200, tokenPairJson)
            : errorBody(401, 'AUTH_EXPIRED', action: 'SIGN_IN');
        await expectLater(
          guardApi(client.api.system.getHealth),
          throwsA(isA<ApiError>()),
        );
        expect(http.to('/auth/refresh'), hasLength(1));
        expect(http.to('/health'), hasLength(2));
      },
    );

    test('other 401s, like a wrong sign-in code, never refresh', () async {
      http.handler = (_) =>
          errorBody(401, 'LOGIN_CODE_INVALID', params: {'attemptsLeft': '3'});
      final error = await guardApi(
        () => client.api.auth.postAuthEmailVerify(
          idempotencyKey: IdempotencyKey().value,
          body: const AuthEmailVerifyRequestBody(
            email: 'nathan@example.com',
            code: '123456',
          ),
        ),
      ).then<ApiError?>((_) => null, onError: (Object e) => e as ApiError);
      expect(error?.errorCode, ErrorCode.loginCodeInvalid);
      expect(error?.params, {'attemptsLeft': '3'});
      expect(http.to('/auth/refresh'), isEmpty);
    });
  });

  group('config', () {
    test('an empty API_BASE_URL means the mock', () {
      expect(ApiConfig.resolveBaseUrl(''), ApiConfig.mockBaseUrl);
      expect(ApiConfig.resolveBaseUrl('  '), ApiConfig.mockBaseUrl);
      expect(
        ApiConfig.resolveBaseUrl('https://aura.example.com/v1/'),
        'https://aura.example.com/v1',
      );
    });

    test('the stream is on the same host and prefix', () {
      ApiConfig at(String url) => ApiConfig(baseUrl: url, app: app);
      expect(
        at('https://aura.example.com/v1').streamUri.toString(),
        'wss://aura.example.com/v1/stream',
      );
      expect(
        at('http://localhost:4010').streamUri.toString(),
        'ws://localhost:4010/stream',
      );
    });
  });
}
