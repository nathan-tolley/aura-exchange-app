import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/api/generated/export.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// `lib/api/errors.dart`: the one error shape, and every way dio fails.
void main() {
  final request = RequestOptions(path: '/quotes');

  DioException dio(
    DioExceptionType type, {
    int? status,
    Object? body,
    Object? error,
  }) => DioException(
    requestOptions: request,
    type: type,
    error: error,
    response: status == null
        ? null
        : Response<Object?>(
            requestOptions: request,
            statusCode: status,
            data: body,
          ),
  );

  group('the error shape', () {
    test('keeps code, params, retryable and action; drops message', () {
      final e = ApiError.fromResponse(422, {
        'error': {
          'code': 'INSUFFICIENT_CASH',
          'message': 'You need A\$229.91 more.',
          'params': {'shortBy': '229.91', 'maxQuantity': '18'},
          'retryable': false,
          'action': 'REDUCE_QUANTITY',
        },
      });
      expect(e.errorCode, ErrorCode.insufficientCash);
      expect(e.params, {'shortBy': '229.91', 'maxQuantity': '18'});
      expect(e.retryable, false);
      expect(e.action, ApiAction.reduceQuantity);
      expect(e.status, 422);
      expect(e.toString(), isNot(contains('229.91 more')));
    });

    test('stringifies odd params and drops nulls', () {
      final e = ApiError.fromResponse(429, {
        'error': {
          'code': 'RATE_LIMITED',
          'params': {'retryAfterSeconds': 12, 'extra': null},
          'retryable': true,
          'action': 'WAIT',
        },
      });
      expect(e.params, {'retryAfterSeconds': '12'});
    });

    test('a code or action added later still parses', () {
      final e = ApiError.fromResponse(409, {
        'error': {'code': 'SEASON_OVER', 'action': 'CELEBRATE'},
      });
      expect(e.code, 'SEASON_OVER');
      expect(e.errorCode, ErrorCode.$unknown);
      expect(e.action, ApiAction.unknown);
      expect(e.isLocal, false);
    });

    test("a body that isn't the shape is unexpected", () {
      for (final body in [
        '<html>502 Bad Gateway</html>',
        null,
        {'error': 'nope'},
        {
          'error': {'code': ''},
        },
      ]) {
        final e = ApiError.fromResponse(502, body);
        expect(e.code, ApiError.appUnexpected, reason: '$body');
        expect(e.status, 502);
        expect(e.isLocal, true);
      }
    });
  });

  group("dio's failures", () {
    test('connection errors are offline; timeouts are timeouts', () {
      expect(
        ApiError.fromDio(dio(DioExceptionType.connectionError)).code,
        ApiError.appOffline,
      );
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(ApiError.fromDio(dio(type)).code, ApiError.appTimeout);
      }
    });

    test("a request that couldn't be sent isn't called offline", () {
      final e = ApiError.fromDio(
        dio(
          DioExceptionType.unknown,
          error: const FormatException('Invalid HTTP header field value'),
        ),
      );
      expect(e.code, ApiError.appUnexpected);
    });

    test('an error response goes through the shape', () {
      final e = ApiError.fromDio(
        dio(
          DioExceptionType.badResponse,
          status: 426,
          body: {
            'error': {
              'code': 'UPDATE_REQUIRED',
              'params': {'minBuild': '42'},
              'action': 'UPDATE_APP',
            },
          },
        ),
      );
      expect(e.errorCode, ErrorCode.updateRequired);
      expect(e.action, ApiAction.updateApp);
    });

    test('an ApiError carried by dio comes back as itself', () {
      const inner = ApiError.timeout();
      expect(
        ApiError.fromDio(dio(DioExceptionType.unknown, error: inner)),
        same(inner),
      );
    });
  });

  test('guardApi turns decode failures into unexpected', () async {
    await expectLater(
      guardApi<int>(() async => throw TypeError()),
      throwsA(
        isA<ApiError>().having((e) => e.code, 'code', ApiError.appUnexpected),
      ),
    );
  });
}
