import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'errors.dart';
import 'generated/aura_api.dart';
import 'generated/clients/auth_client.dart';
import 'generated/models/auth_refresh_request_body.dart';
import 'generated/models/error_code.dart';
import 'session.dart';

/// Which build is talking. Sent on every request as `X-App-Version` and
/// `X-App-Build`, so the server can answer 426 `UPDATE_REQUIRED` to builds
/// below its minimum. On the phone these are the bundle's version and build
/// (the release workflow sets the build to the run number).
@immutable
class AppIdentity {
  const AppIdentity({required this.version, required this.build});

  /// For tests and anything that runs before the bundle is read.
  static const unknown = AppIdentity(version: '0.0.0', build: '0');

  final String version;
  final String build;
}

/// Where the API is.
@immutable
class ApiConfig {
  const ApiConfig({required this.baseUrl, required this.app});

  /// The base URL from `--dart-define=API_BASE_URL`, e.g.
  /// `https://aura.example.com/v1`.
  factory ApiConfig.fromEnvironment(AppIdentity app) => ApiConfig(
    baseUrl: resolveBaseUrl(const String.fromEnvironment('API_BASE_URL')),
    app: app,
  );

  /// The Prism mock (`npx @stoplight/prism-cli mock api/openapi.yaml`), which
  /// serves the paths without `/v1`.
  static const mockBaseUrl = 'http://localhost:4010';

  /// The release workflow always passes `API_BASE_URL`, so an unset repo
  /// variable arrives as `''`: that means "not set" and falls back to the
  /// mock. On a phone the mock isn't reachable, which lands on the designed
  /// exchange-down screen rather than on URLs built on an empty base.
  static String resolveBaseUrl(String value) {
    final url = value.trim();
    if (url.isEmpty) return mockBaseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  final String baseUrl;
  final AppIdentity app;

  /// The WebSocket: the same host and path prefix, on `ws` or `wss`.
  Uri get streamUri {
    final base = Uri.parse(baseUrl);
    return base.replace(
      scheme: base.scheme == 'https' ? 'wss' : 'ws',
      path: '${base.path}/stream',
    );
  }
}

const _uuid = Uuid();

/// The `Idempotency-Key` for one user action (API-CONTRACT.md → Transport).
///
/// Create it when the user commits (the slide lands, File is tapped), not
/// per network attempt, and pass the same key to every retry of that action,
/// so a retry after a dropped connection can't trade twice. A new action gets
/// a new key. So does each sign-in code the user submits: the server replays
/// a stored `LOGIN_CODE_INVALID` for a repeated key and body.
@immutable
final class IdempotencyKey {
  IdempotencyKey() : value = _uuid.v4();

  /// A known key, for tests and fixtures.
  const IdempotencyKey.fixed(this.value);

  /// A UUID v4.
  final String value;

  @override
  bool operator ==(Object other) =>
      other is IdempotencyKey && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// The app's one connection to `/v1`: dio with the app's headers and the
/// bearer token, the generated client on top, and the signed-in session.
///
/// On 401 `AUTH_EXPIRED` it refreshes the tokens once (shared by every
/// request that expired together) and replays the request with the same
/// headers, including its `Idempotency-Key`. If the server rejects the
/// refresh token, the session signs out and the request fails with
/// `AUTH_EXPIRED` (action `SIGN_IN`); if the refresh can't reach the server,
/// the request fails with that failure instead and the tokens are kept.
class AuraClient {
  AuraClient({
    required this.config,
    required TokenStore tokens,
    HttpClientAdapter? adapter,
  }) {
    dio = _newDio(adapter);
    _refreshDio = _newDio(adapter);
    session = AuthSession(store: tokens, refresher: _refresh);
    dio.interceptors.add(_AuthInterceptor(session, dio));
    api = AuraApi(dio, baseUrl: config.baseUrl);
  }

  final ApiConfig config;
  late final Dio dio;
  late final AuraApi api;
  late final AuthSession session;

  /// Refreshes go around the auth interceptor, so a failing refresh can't
  /// trigger another refresh.
  late final Dio _refreshDio;

  Dio _newDio(HttpClientAdapter? adapter) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'X-App-Version': config.app.version,
          'X-App-Build': config.app.build,
        },
      ),
    );
    if (adapter != null) dio.httpClientAdapter = adapter;
    return dio;
  }

  Future<Tokens> _refresh(String refreshToken) async {
    try {
      final pair = await AuthClient(_refreshDio, baseUrl: config.baseUrl)
          .postAuthRefresh(
            idempotencyKey: IdempotencyKey().value,
            body: AuthRefreshRequestBody(refreshToken: refreshToken),
          );
      return Tokens(
        accessToken: pair.accessToken,
        refreshToken: pair.refreshToken,
      );
    } on DioException catch (e) {
      if (_rejectsRefresh(e.response?.statusCode)) {
        throw const RefreshRejected();
      }
      rethrow;
    }
  }

  /// A 4xx answer to a refresh means the refresh token is no good, apart
  /// from the ones that are about the request or the app rather than the
  /// token: a timeout, update required, rate limited.
  static bool _rejectsRefresh(int? status) =>
      status != null &&
      status >= 400 &&
      status < 500 &&
      status != 408 &&
      status != 426 &&
      status != 429;

  void close() {
    dio.close();
    _refreshDio.close();
    session.dispose();
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._session, this._dio);

  final AuthSession _session;
  final Dio _dio;

  /// Set on a replay, so a replay that fails with 401 again isn't refreshed
  /// a second time.
  static const _replayed = 'aura.replayed';

  static const _authorization = 'Authorization';
  static const _bearer = 'Bearer ';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.headers.containsKey(_authorization)) {
      final tokens = await _session.current();
      if (tokens != null) {
        options.headers[_authorization] = '$_bearer${tokens.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final expired =
        err.response?.statusCode == 401 &&
        ApiError.fromResponse(401, err.response?.data).errorCode ==
            ErrorCode.authExpired;
    if (!expired || options.extra[_replayed] == true) {
      return handler.next(err);
    }

    final sent = options.headers[_authorization];
    final Tokens? tokens;
    try {
      tokens = await _session.refreshAfter(
        sent is String && sent.startsWith(_bearer)
            ? sent.substring(_bearer.length)
            : null,
      );
    } on DioException catch (e) {
      return handler.next(e);
    } on Object {
      // The refresh answered with something the client couldn't decode.
      return handler.next(
        DioException(
          requestOptions: options,
          error: const ApiError.unexpected(),
        ),
      );
    }
    if (tokens == null) return handler.next(err);

    options
      ..headers[_authorization] = '$_bearer${tokens.accessToken}'
      ..extra[_replayed] = true;
    try {
      handler.resolve(await _dio.fetch<Object?>(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
