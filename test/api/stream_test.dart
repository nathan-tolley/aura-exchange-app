import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:aura_exchange/api/generated/export.dart';
import 'package:aura_exchange/api/session.dart';
import 'package:aura_exchange/api/stream.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

/// `lib/api/stream.dart` with a fake socket and fake time
/// (API-CONTRACT.md → Realtime).
void main() {
  const exchange = 'ex-1';
  final uri = Uri.parse('wss://aura.test/v1/stream');

  late List<FakeSocket> sockets;
  late List<String> polled;
  late MemoryTokenStore store;
  late int refreshes;
  late Object? Function() refreshOutcome;
  late AuthSession session;
  late AuraStream stream;
  late List<StreamMessage> received;

  /// When true, every new socket fails to open.
  late bool refuseNew;

  /// Runs [body] in fake time with a fresh stream. Sockets open at once
  /// unless [autoOpen] is false.
  void run(
    void Function(FakeAsync async) body, {
    bool autoOpen = true,
    Tokens? tokens = const Tokens(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
    ),
  }) {
    fakeAsync((async) {
      sockets = [];
      refuseNew = false;
      polled = [];
      received = [];
      refreshes = 0;
      refreshOutcome = () =>
          const Tokens(accessToken: 'access-2', refreshToken: 'refresh-2');
      store = MemoryTokenStore(tokens);
      session = AuthSession(
        store: store,
        refresher: (_) async {
          refreshes++;
          final outcome = refreshOutcome();
          if (outcome is Tokens) return outcome;
          throw outcome!;
        },
      );
      stream = AuraStream(
        uri: uri,
        session: session,
        poll: polled.add,
        random: _MidRandom(),
        connector: (uri) {
          final socket = FakeSocket(uri);
          sockets.add(socket);
          if (refuseNew) {
            socket.failToOpen();
          } else if (autoOpen) {
            socket.open();
          }
          return socket;
        },
      );
      stream.messages.listen(received.add);
      body(async);
      stream.dispose();
      async.flushMicrotasks();
    });
  }

  group('connecting', () {
    test('connects with the token and subscribes', () {
      run((async) {
        stream
          ..subscribe(exchange)
          ..start();
        async.flushMicrotasks();
        expect(stream.connected.value, true);
        final socket = sockets.single;
        expect(socket.uri.queryParameters['access_token'], 'access-1');
        expect(socket.uri.path, '/v1/stream');
        expect(socket.sent, [
          {'type': 'subscribe', 'exchangeId': exchange},
        ]);

        stream.subscribe('ex-2');
        stream.unsubscribe(exchange);
        expect(socket.sent.skip(1), [
          {'type': 'subscribe', 'exchangeId': 'ex-2'},
          {'type': 'unsubscribe', 'exchangeId': exchange},
        ]);
      });
    });

    test('stays down when signed out', () {
      run((async) {
        stream
          ..subscribe(exchange)
          ..start();
        async.elapse(const Duration(minutes: 1));
        expect(sockets, isEmpty);
        expect(stream.connected.value, false);
        expect(polled, isEmpty);
      }, tokens: null);
    });
  });

  group('messages', () {
    test('parses ticks, tape, status, notifications and market', () {
      run((async) {
        stream
          ..subscribe(exchange)
          ..start();
        async.flushMicrotasks();
        final socket = sockets.single
          ..receive({
            'type': 'ticks',
            'exchangeId': exchange,
            'asOf': '2026-10-24T10:41:00Z',
            'marketState': 'OPEN',
            'listings': [
              {
                'id': 'anna',
                'price': '124.10',
                'changePct': '6.70',
                'state': 'ACTIVE',
              },
            ],
          })
          ..receive({
            'type': 'status',
            'resource': 'event',
            'id': 'e1',
            'status': 'RULED',
            'at': '2026-10-24T10:41:00Z',
          })
          ..receive({
            'type': 'market',
            'exchangeId': exchange,
            'marketState': 'CLOSED',
            'nextChangeAt': '2026-10-24T20:00:00Z',
          });
        async.flushMicrotasks();
        expect(received, hasLength(3));
        final ticks = received[0] as TicksMessage;
        expect(ticks.asOf, DateTime.utc(2026, 10, 24, 10, 41));
        expect(ticks.marketState, MarketState.open);
        expect(ticks.listings.single.price, '124.10');
        expect(ticks.listings.single.state, ListingState.active);
        expect((received[1] as StatusMessage).status, 'RULED');
        expect((received[2] as MarketMessage).marketState, MarketState.closed);
        expect(socket.sent, hasLength(1));
      });
    });

    test('skips pongs, unknown types and malformed frames', () {
      run((async) {
        stream.start();
        async.flushMicrotasks();
        sockets.single
          ..receive({'type': 'pong'})
          ..receive({'type': 'weather', 'sky': 'grey'})
          ..receive({'type': 'ticks', 'exchangeId': exchange})
          ..receiveRaw('not json');
        async.flushMicrotasks();
        expect(received, isEmpty);
        expect(stream.connected.value, true);
      });
    });
  });

  group('staying alive', () {
    test('pings every 25 s and keeps a socket that answers', () {
      run((async) {
        stream.start();
        async.flushMicrotasks();
        final socket = sockets.single;
        for (var i = 0; i < 3; i++) {
          async.elapse(const Duration(seconds: 25));
          expect(socket.sent.last, {'type': 'ping'});
          socket.receive({'type': 'pong'});
          async.flushMicrotasks();
        }
        expect(sockets, hasLength(1));
        expect(stream.connected.value, true);
      });
    });

    test('replaces a socket that goes quiet for a whole interval', () {
      run((async) {
        stream.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 25)); // ping, no pong
        async.elapse(const Duration(seconds: 25)); // still nothing: dead
        expect(sockets.first.closed, true);
        expect(stream.connected.value, false);
        async.elapse(const Duration(seconds: 1));
        expect(sockets, hasLength(2));
        expect(stream.connected.value, true);
      });
    });
  });

  group('reconnecting', () {
    test('backs off 1, 2, 4 … 30 s while the server is unreachable', () {
      run((async) {
        stream.start();
        async.flushMicrotasks();
        final waits = <int>[];
        var last = 0;
        var elapsed = 0;
        while (sockets.length < 8) {
          sockets.last.failToOpen();
          async.flushMicrotasks();
          final before = sockets.length;
          while (sockets.length == before) {
            async.elapse(const Duration(milliseconds: 100));
            elapsed += 100;
          }
          waits.add(((elapsed - last) / 1000).round());
          last = elapsed;
        }
        expect(waits, [1, 2, 4, 8, 16, 30, 30]);
        expect(stream.connected.value, false);

        sockets.last.open();
        async.flushMicrotasks();
        expect(stream.connected.value, true);
        // A good connection resets the backoff.
        sockets.last.serverClose(1006);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        expect(sockets, hasLength(9));
      }, autoOpen: false);
    });

    test('resubscribes and tells screens to refetch after a reconnect', () {
      run((async) {
        stream
          ..subscribe(exchange)
          ..start();
        async.flushMicrotasks();
        expect(received, isEmpty);
        sockets.single.serverClose(1001);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        expect(sockets, hasLength(2));
        expect(sockets.last.sent.first, {
          'type': 'subscribe',
          'exchangeId': exchange,
        });
        expect(received.single, isA<StreamReconnected>());
      });
    });

    test('polls the market every 15 s only while down', () {
      run((async) {
        stream
          ..subscribe(exchange)
          ..start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 45));
        expect(polled, isEmpty);

        refuseNew = true;
        sockets.single.serverClose(1006);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 46));
        expect(sockets.length, greaterThan(2));
        expect(polled, [exchange, exchange, exchange]);
      });
    });
  });

  group('close code 4401', () {
    test('refreshes the token and reconnects at once', () {
      run((async) {
        stream.start();
        async.flushMicrotasks();
        sockets.single.serverClose(4401);
        async.flushMicrotasks();
        expect(refreshes, 1);
        expect(sockets, hasLength(2));
        expect(sockets.last.uri.queryParameters['access_token'], 'access-2');
        expect(stream.connected.value, true);
      });
    });

    test('stays down when the refresh signs the user out', () {
      run((async) {
        refreshOutcome = () => const RefreshRejected();
        stream
          ..subscribe(exchange)
          ..start();
        async.flushMicrotasks();
        sockets.single.serverClose(4401);
        async.flushMicrotasks();
        async.elapse(const Duration(minutes: 2));
        expect(sockets, hasLength(1));
        expect(session.signedIn.value, false);
        expect(stream.connected.value, false);
        expect(polled, isEmpty);
      });
    });

    test('backs off when the refresh is unreachable', () {
      run((async) {
        refreshOutcome = () => Exception('offline');
        stream.start();
        async.flushMicrotasks();
        sockets.single.serverClose(4401);
        async.flushMicrotasks();
        expect(sockets, hasLength(1));
        async.elapse(const Duration(seconds: 1));
        expect(sockets, hasLength(2));
        expect(session.signedIn.value, true);
      });
    });
  });

  test('stop closes the socket and every timer', () {
    run((async) {
      stream
        ..subscribe(exchange)
        ..start();
      async.flushMicrotasks();
      stream.stop();
      expect(sockets.single.closed, true);
      expect(stream.connected.value, false);
      async.elapse(const Duration(minutes: 5));
      expect(sockets, hasLength(1));
      expect(polled, isEmpty);
      expect(async.pendingTimers, isEmpty);
    });
  });
}

class FakeSocket implements SocketConnection {
  FakeSocket(this.uri);

  final Uri uri;
  final List<Map<String, Object?>> sent = [];
  final _ready = Completer<void>();
  final _incoming = StreamController<Object?>();
  bool closed = false;

  void open() => _ready.complete();

  void failToOpen() => _ready.completeError(StateError('refused'));

  void receive(Map<String, Object?> message) => receiveRaw(jsonEncode(message));

  void receiveRaw(String frame) => _incoming.add(frame);

  void serverClose(int code) {
    closeCode = code;
    unawaited(_incoming.close());
  }

  @override
  int? closeCode;

  @override
  Future<void> get ready => _ready.future;

  @override
  Stream<Object?> get messages => _incoming.stream;

  @override
  void send(String text) => sent.add(jsonDecode(text) as Map<String, Object?>);

  @override
  Future<void> close() async => closed = true;
}

/// Jitter at its midpoint, so backoff waits are exact.
class _MidRandom implements Random {
  @override
  double nextDouble() => 0.5;

  @override
  bool nextBool() => false;

  @override
  int nextInt(int max) => 0;
}
