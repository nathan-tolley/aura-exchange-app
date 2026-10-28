import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'generated/models/listing_state.dart';
import 'generated/models/market_state.dart';
import 'generated/models/notification.dart';
import 'generated/models/tape_item.dart';
import 'session.dart';

// ---------------------------------------------------------------------------
// Messages (API-CONTRACT.md → Realtime). The spec has no schemas for these,
// so they're parsed here; tape and notification items use the generated
// models. Prices stay decimal strings, as in the generated models.
// ---------------------------------------------------------------------------

/// Something that arrived on the stream.
sealed class StreamMessage {
  const StreamMessage();

  /// Parses one server message. Unknown types and malformed messages give
  /// null and are skipped: the socket is an accelerator, never the source of
  /// truth, and the next refetch corrects anything missed.
  static StreamMessage? parse(Object? json) {
    if (json is! Map<String, Object?>) return null;
    try {
      return switch (json['type']) {
        'ticks' => TicksMessage(
          exchangeId: json['exchangeId']! as String,
          asOf: DateTime.parse(json['asOf']! as String),
          marketState: MarketState.fromJson(json['marketState']! as String),
          listings: [
            for (final l in json['listings']! as List<Object?>)
              ListingTick.fromJson(l! as Map<String, Object?>),
          ],
        ),
        'tape' => TapeMessage(
          exchangeId: json['exchangeId']! as String,
          item: TapeItem.fromJson(json['item']! as Map<String, Object?>),
        ),
        'status' => StatusMessage(
          resource: json['resource']! as String,
          id: json['id']! as String,
          status: json['status']! as String,
          at: DateTime.parse(json['at']! as String),
        ),
        'notification' => NotificationMessage(
          Notification.fromJson(json['item']! as Map<String, Object?>),
        ),
        'market' => MarketMessage(
          exchangeId: json['exchangeId']! as String,
          marketState: MarketState.fromJson(json['marketState']! as String),
          nextChangeAt: switch (json['nextChangeAt']) {
            final String at => DateTime.parse(at),
            _ => null,
          },
        ),
        'pong' => const PongMessage(),
        _ => null,
      };
    } on Object {
      return null;
    }
  }
}

/// New prices for the listings that changed (at most every 15 s).
final class TicksMessage extends StreamMessage {
  const TicksMessage({
    required this.exchangeId,
    required this.asOf,
    required this.marketState,
    required this.listings,
  });

  final String exchangeId;
  final DateTime asOf;
  final MarketState marketState;
  final List<ListingTick> listings;
}

@immutable
class ListingTick {
  const ListingTick({
    required this.id,
    required this.price,
    this.changeAbs,
    required this.changePct,
    required this.state,
  });

  factory ListingTick.fromJson(Map<String, Object?> json) => ListingTick(
    id: json['id']! as String,
    price: json['price']! as String,
    changeAbs: json['changeAbs'] as String?,
    changePct: json['changePct']! as String,
    state: ListingState.fromJson(json['state']! as String),
  );

  final String id;

  /// Decimal string, 2 dp.
  final String price;

  /// Since the previous close, decimal string, 2 dp (draft.7). Null from a
  /// server that doesn't send it yet.
  final String? changeAbs;

  /// Percent units, decimal string, 2 dp.
  final String changePct;
  final ListingState state;
}

final class TapeMessage extends StreamMessage {
  const TapeMessage({required this.exchangeId, required this.item});

  final String exchangeId;
  final TapeItem item;
}

/// An event, halt, order, position or SEC case changed status.
final class StatusMessage extends StreamMessage {
  const StatusMessage({
    required this.resource,
    required this.id,
    required this.status,
    required this.at,
  });

  /// `event`, `halt`, `order`, `position` or `sec`.
  final String resource;
  final String id;

  /// One of the contract's status words for that resource.
  final String status;
  final DateTime at;
}

final class NotificationMessage extends StreamMessage {
  const NotificationMessage(this.item);

  final Notification item;
}

/// The market opened, closed or halted.
final class MarketMessage extends StreamMessage {
  const MarketMessage({
    required this.exchangeId,
    required this.marketState,
    required this.nextChangeAt,
  });

  final String exchangeId;
  final MarketState marketState;
  final DateTime? nextChangeAt;
}

/// The server's answer to a ping. [AuraStream] uses it to tell a live
/// socket from a dead one and doesn't pass it on.
final class PongMessage extends StreamMessage {
  const PongMessage();
}

/// Not from the server: the socket came back after being down. Whatever is
/// on screen refetches, since messages may have been missed meanwhile.
final class StreamReconnected extends StreamMessage {
  const StreamReconnected();
}

/// Not from the server: the socket is down, so it's time to refetch this
/// exchange's market (`GET /exchanges/{id}/market`), every 15 s.
final class PollDue extends StreamMessage {
  const PollDue(this.exchangeId);

  final String exchangeId;
}

// ---------------------------------------------------------------------------
// The connection
// ---------------------------------------------------------------------------

/// The one WebSocket the stream uses. A seam, so tests can drive it.
abstract interface class SocketConnection {
  /// Completes once connected; throws if the connection failed.
  Future<void> get ready;

  /// Text frames from the server; done when the socket closes.
  Stream<Object?> get messages;

  void send(String text);

  /// The close code once [messages] is done (4401: the token expired).
  int? get closeCode;

  Future<void> close();
}

typedef SocketConnector = SocketConnection Function(Uri uri);

/// The real socket, through web_socket_channel.
SocketConnection connectWebSocket(Uri uri) =>
    _WebSocketConnection(WebSocketChannel.connect(uri));

class _WebSocketConnection implements SocketConnection {
  _WebSocketConnection(this._channel);

  final WebSocketChannel _channel;

  @override
  Future<void> get ready => _channel.ready;

  @override
  Stream<Object?> get messages => _channel.stream;

  @override
  void send(String text) => _channel.sink.add(text);

  @override
  int? get closeCode => _channel.closeCode;

  @override
  Future<void> close() async => _channel.sink.close();
}

/// `GET /v1/stream`: live ticks, tape, statuses, notifications and market
/// changes for the exchanges the app is showing.
///
/// - Connects with the current access token and subscribes to every
///   exchange in [subscribe]d, again after each reconnect.
/// - Pings every 25 s. A socket that answers nothing for a whole ping
///   interval is treated as dead and replaced.
/// - Reconnects with exponential backoff (1 s doubling to 30 s, with
///   jitter). Close code 4401 means the token expired: it refreshes through
///   the [AuthSession] and reconnects at once; if that signs the user out,
///   it stays down.
/// - While it's down, sends [PollDue] for each subscribed exchange every
///   15 s, so screens refetch `GET /exchanges/{id}/market` and show Delayed.
/// - [connected] drives the Delayed state.
///
/// The app [start]s it in the foreground and [stop]s it in the background.
class AuraStream {
  AuraStream({
    required this.uri,
    required this._session,
    this._connector = connectWebSocket,
    this.pingEvery = const Duration(seconds: 25),
    this.pollEvery = const Duration(seconds: 15),
    this.maxBackoff = const Duration(seconds: 30),
    Random? random,
  }) : _random = random ?? Random();

  /// `ApiConfig.streamUri`: `wss://host/v1/stream`.
  final Uri uri;

  final Duration pingEvery;
  final Duration pollEvery;
  final Duration maxBackoff;

  final AuthSession _session;
  final SocketConnector _connector;
  final Random _random;

  /// Whether the socket is up. False means every price is Delayed.
  final ValueNotifier<bool> connected = ValueNotifier(false);

  final _messages = StreamController<StreamMessage>.broadcast();

  /// Everything from the server except pongs, plus [StreamReconnected] and
  /// [PollDue].
  Stream<StreamMessage> get messages => _messages.stream;

  final Set<String> _exchanges = {};
  SocketConnection? _socket;
  StreamSubscription<Object?>? _listening;
  Timer? _pingTimer;
  Timer? _pollTimer;
  Timer? _retryTimer;
  int _failures = 0;
  bool _running = false;
  bool _heardSincePing = true;
  bool _wasConnected = false;

  /// The exchanges subscribed to.
  Set<String> get exchanges => Set.unmodifiable(_exchanges);

  /// Delivers [message] as if the stream had produced it.
  @visibleForTesting
  void inject(StreamMessage message) => _messages.add(message);

  void subscribe(String exchangeId) {
    if (_exchanges.add(exchangeId)) {
      _send({'type': 'subscribe', 'exchangeId': exchangeId});
    }
  }

  void unsubscribe(String exchangeId) {
    if (_exchanges.remove(exchangeId)) {
      _send({'type': 'unsubscribe', 'exchangeId': exchangeId});
    }
  }

  /// Connects (the app came to the foreground, or someone signed in).
  void start() {
    if (_running) return;
    _running = true;
    _startPolling();
    unawaited(_connect());
  }

  /// Disconnects and stops every timer (the app went to the background).
  void stop() {
    _running = false;
    _retryTimer?.cancel();
    _pollTimer?.cancel();
    _pollTimer = null;
    _drop();
  }

  void dispose() {
    stop();
    unawaited(_messages.close());
    connected.dispose();
  }

  Future<void> _connect() async {
    _retryTimer?.cancel();
    if (!_running) return;
    final tokens = await _session.current();
    if (!_running) return;
    if (tokens == null) {
      // Signed out: nothing to connect as. Sign-in starts the stream again.
      stop();
      return;
    }
    final socket = _connector(
      uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          'access_token': tokens.accessToken,
        },
      ),
    );
    _socket = socket;
    try {
      await socket.ready;
    } on Object {
      if (identical(_socket, socket)) _lost(socket, tokens.accessToken);
      return;
    }
    if (!identical(_socket, socket) || !_running) {
      unawaited(socket.close());
      return;
    }
    _listening = socket.messages.listen(
      _receive,
      onDone: () => _lost(socket, tokens.accessToken),
      onError: (Object _) => _lost(socket, tokens.accessToken),
      cancelOnError: true,
    );
    _failures = 0;
    _heardSincePing = true;
    connected.value = true;
    _pollTimer?.cancel();
    _pollTimer = null;
    for (final id in _exchanges) {
      _send({'type': 'subscribe', 'exchangeId': id});
    }
    _pingTimer = Timer.periodic(pingEvery, (_) => _ping());
    if (_wasConnected) _messages.add(const StreamReconnected());
    _wasConnected = true;
  }

  void _receive(Object? frame) {
    _heardSincePing = true;
    final message = StreamMessage.parse(
      frame is String ? _decode(frame) : null,
    );
    if (message == null || message is PongMessage) return;
    _messages.add(message);
  }

  Object? _decode(String frame) {
    try {
      return jsonDecode(frame);
    } on FormatException {
      return null;
    }
  }

  void _ping() {
    if (!_heardSincePing) {
      // Nothing back since the last ping: the socket is dead without knowing.
      final socket = _socket;
      if (socket != null) _lost(socket, null);
      return;
    }
    _heardSincePing = false;
    _send({'type': 'ping'});
  }

  /// The socket closed, failed to open, or went quiet.
  void _lost(SocketConnection socket, String? accessToken) {
    if (!identical(_socket, socket)) return;
    final expired = socket.closeCode == 4401;
    _drop();
    if (!_running) return;
    _startPolling();
    if (expired) {
      unawaited(_refreshAndReconnect(accessToken));
    } else {
      _retryLater();
    }
  }

  Future<void> _refreshAndReconnect(String? accessToken) async {
    try {
      final tokens = await _session.refreshAfter(accessToken);
      if (tokens == null) {
        stop();
        return;
      }
      await _connect();
    } on Object {
      // The refresh couldn't reach the server: back off like any failure.
      _retryLater();
    }
  }

  void _retryLater() {
    if (!_running) return;
    final exponent = min(_failures, 5);
    _failures++;
    final base = Duration(seconds: 1 << exponent);
    final capped = base > maxBackoff ? maxBackoff : base;
    // Up to a fifth either way, so phones don't all reconnect at once.
    final jitter = 0.8 + _random.nextDouble() * 0.4;
    _retryTimer = Timer(capped * jitter, () => unawaited(_connect()));
  }

  void _startPolling() {
    if (_pollTimer != null || !_running) return;
    _pollTimer = Timer.periodic(pollEvery, (_) {
      if (connected.value) return;
      for (final id in _exchanges) {
        _messages.add(PollDue(id));
      }
    });
  }

  void _drop() {
    _pingTimer?.cancel();
    _pingTimer = null;
    unawaited(_listening?.cancel());
    _listening = null;
    final socket = _socket;
    _socket = null;
    if (socket != null) unawaited(socket.close());
    connected.value = false;
  }

  void _send(Map<String, Object?> message) {
    if (!connected.value) return;
    _socket?.send(jsonEncode(message));
  }
}
