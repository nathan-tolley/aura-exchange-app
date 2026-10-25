import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A dio adapter that answers from a handler instead of the network, and
/// records every request it sees.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  /// Returns the response for a request, or throws a [DioException] (e.g.
  /// [offline]) to fail it before any response.
  FutureOr<ResponseBody> Function(RequestOptions request) handler;

  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // A copy: a replay reuses and changes the same options object.
    requests.add(options.copyWith(headers: Map.of(options.headers)));
    return handler(options);
  }

  @override
  void close({bool force = false}) {}

  /// Requests to [path], in order.
  List<RequestOptions> to(String path) =>
      requests.where((r) => r.path == path).toList();
}

ResponseBody jsonBody(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

/// The contract's error shape.
ResponseBody errorBody(
  int status,
  String code, {
  Map<String, String> params = const {},
  bool retryable = false,
  String action = 'NONE',
}) => jsonBody(status, {
  'error': {
    'code': code,
    'message': 'English for logs; never shown.',
    'params': params,
    'retryable': retryable,
    'action': action,
  },
});

/// What dio throws when nothing answers.
Never offline(RequestOptions request) => throw DioException.connectionError(
  requestOptions: request,
  reason: 'Connection refused',
);

const tokenPairJson = {
  'accessToken': 'access-2',
  'refreshToken': 'refresh-2',
  'expiresIn': 900,
  'user': {
    'id': '3f2b8c1e-5d4a-4e7b-9a10-2c6d8e9f0a1b',
    'displayName': 'Nathan',
    'email': 'nathan@example.com',
    'createdAt': '2026-10-24T13:21:00Z',
  },
};
