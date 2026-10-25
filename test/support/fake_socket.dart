import 'dart:async';
import 'dart:convert';

import 'package:aura_exchange/api/stream.dart';

/// A socket the test drives: open it, fail it, push frames, close it with a
/// code, and read what the app sent.
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
