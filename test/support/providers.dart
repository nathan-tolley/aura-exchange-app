import 'package:aura_exchange/api/client.dart';
import 'package:aura_exchange/api/session.dart';
import 'package:aura_exchange/data/api_providers.dart';
import 'package:aura_exchange/data/freshness.dart';
import 'package:aura_exchange/data/live_market.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'fake_socket.dart';

const signedInTokens = Tokens(
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
);

/// A clock that only moves when told.
class FixedClock extends Clock {
  FixedClock(this._start);

  final DateTime _start;

  @override
  DateTime build() => _start;

  void set(DateTime now) => state = now;
}

/// The app's providers on a fake network and fake sockets, signed in unless
/// [tokens] is null. Sockets open at once; they're collected in [sockets].
ProviderContainer testContainer({
  required HttpClientAdapter http,
  required List<FakeSocket> sockets,
  required DateTime now,
  Tokens? tokens = signedInTokens,
  String baseUrl = 'http://api.test/v1',
  List<Override> overrides = const [],
}) => ProviderContainer(
  retry: noRetry,
  overrides: [
    apiConfigProvider.overrideWithValue(
      ApiConfig(baseUrl: baseUrl, app: AppIdentity.unknown),
    ),
    tokenStoreProvider.overrideWithValue(MemoryTokenStore(tokens)),
    httpAdapterProvider.overrideWithValue(http),
    socketConnectorProvider.overrideWithValue((uri) {
      final socket = FakeSocket(uri)..open();
      sockets.add(socket);
      return socket;
    }),
    clockProvider.overrideWith(() => FixedClock(now)),
    ...overrides,
  ],
);
