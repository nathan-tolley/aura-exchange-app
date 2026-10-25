import 'package:dio/dio.dart';

import 'generated/models/error_code.dart';

/// What the app should do about an error: the contract's `action`
/// (API-CONTRACT.md → One error shape). [unknown] is an action added to the
/// contract after this build; treat it like [none].
enum ApiAction {
  retry('RETRY'),
  requote('REQUOTE'),
  reduceQuantity('REDUCE_QUANTITY'),
  sellSomething('SELL_SOMETHING'),
  wait('WAIT'),
  signIn('SIGN_IN'),
  updateApp('UPDATE_APP'),
  contactAdmin('CONTACT_ADMIN'),
  none('NONE'),
  unknown('');

  const ApiAction(this.json);

  final String json;

  static ApiAction parse(Object? json) => values.firstWhere(
    (a) => a != unknown && a.json == json,
    orElse: () => unknown,
  );
}

/// Every way a request can fail, in the one error shape.
///
/// Errors from the server keep its `code`, `params`, `retryable` and `action`;
/// its `message` is dropped, because the app never shows it (copy comes from
/// `code` + `params` in `l10n/strings.dart`). Failures that never got the
/// error shape back (offline, a timeout, a body that isn't the shape) get
/// local codes starting `APP_`, which can't collide with a server code.
class ApiError implements Exception {
  const ApiError({
    required this.code,
    this.params = const {},
    required this.retryable,
    required this.action,
    this.status,
  });

  /// No answer at all: no connection, or the server isn't reachable.
  const ApiError.offline()
    : code = appOffline,
      params = const {},
      retryable = true,
      action = ApiAction.retry,
      status = null;

  /// The server didn't answer in time.
  const ApiError.timeout()
    : code = appTimeout,
      params = const {},
      retryable = true,
      action = ApiAction.retry,
      status = null;

  /// An answer that isn't the contract's shape: a proxy's HTML 502, or a
  /// success body the client couldn't decode.
  const ApiError.badResponse([this.status])
    : code = appBadResponse,
      params = const {},
      retryable = true,
      action = ApiAction.retry;

  static const appOffline = 'APP_OFFLINE';
  static const appTimeout = 'APP_TIMEOUT';
  static const appBadResponse = 'APP_BAD_RESPONSE';

  /// Parses a non-2xx body. Anything that isn't `{"error": {"code": …}}` is
  /// [ApiError.badResponse]. Params are strings by contract; anything else is
  /// stringified rather than dropped.
  factory ApiError.fromResponse(int? status, Object? body) {
    final error = body is Map ? body['error'] : null;
    final code = error is Map ? error['code'] : null;
    if (error is! Map || code is! String || code.isEmpty) {
      return ApiError.badResponse(status);
    }
    final params = error['params'];
    return ApiError(
      code: code,
      params: params is Map
          ? {
              for (final MapEntry(:key, :value) in params.entries)
                if (value != null) '$key': '$value',
            }
          : const {},
      retryable: error['retryable'] == true,
      action: ApiAction.parse(error['action']),
      status: status,
    );
  }

  /// Turns whatever dio threw into the one shape.
  factory ApiError.fromDio(DioException e) {
    if (e.error case final ApiError error) return error;
    return switch (e.type) {
      DioExceptionType.badResponse => ApiError.fromResponse(
        e.response?.statusCode,
        e.response?.data,
      ),
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const ApiError.timeout(),
      DioExceptionType.connectionError => const ApiError.offline(),
      // No response at all means the server was never reached.
      _ when e.response == null => const ApiError.offline(),
      _ => ApiError.badResponse(e.response?.statusCode),
    };
  }

  /// The server's code, or a local `APP_` code.
  final String code;

  /// Strings, formatted like the contract's numbers (`"229.91"`).
  final Map<String, String> params;

  final bool retryable;
  final ApiAction action;

  /// The HTTP status, when there was a response.
  final int? status;

  /// [code] as the contract's enum; `ErrorCode.$unknown` for a code added
  /// after this build and for the local `APP_` codes.
  ErrorCode get errorCode => ErrorCode.fromJson(code);

  /// Whether this failure happened on the way to the server rather than in it.
  bool get isLocal => code.startsWith('APP_');

  /// The server's reference for `SERVER` and `MAINTENANCE`, shown so Nathan
  /// can find the log line.
  String? get reference => params['reference'];

  @override
  String toString() =>
      'ApiError($code${status == null ? '' : ' $status'}, ${action.json})';
}

/// Runs one API call and turns every failure into an [ApiError]: dio's
/// exceptions, and a success body the generated models couldn't decode.
Future<T> guardApi<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw ApiError.fromDio(e);
  } on TypeError {
    throw const ApiError.badResponse();
  } on FormatException {
    throw const ApiError.badResponse();
  }
}
