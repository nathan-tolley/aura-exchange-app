import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/generated/models/market_state.dart';

/// How old a payload's numbers are (API-CONTRACT.md → Freshness). Every
/// market, listing, portfolio and quote payload carries these, and every
/// tick updates them.
@immutable
class Freshness {
  const Freshness({
    required this.asOf,
    required this.marketState,
    this.nextChangeAt,
  });

  /// When these numbers were true.
  final DateTime asOf;
  final MarketState marketState;

  /// When [marketState] next changes: the open, the close, a halt ending.
  final DateTime? nextChangeAt;

  @override
  bool operator ==(Object other) =>
      other is Freshness &&
      other.asOf == asOf &&
      other.marketState == marketState &&
      other.nextChangeAt == nextChangeAt;

  @override
  int get hashCode => Object.hash(asOf, marketState, nextChangeAt);
}

/// How a price screen labels its numbers.
enum Liveness {
  /// Shown as live: the socket is up and the numbers are under a minute old.
  live,

  /// The market is closed, so the numbers are the close's: "at the close"
  /// (W09). Not Delayed, because nothing is moving.
  closed,

  /// Never shown as live: "Delayed · as of 9:41 pm" (W11).
  delayed,
}

/// Numbers older than this are Delayed (API-CONTRACT.md → Freshness).
const staleAfter = Duration(seconds: 60);

/// Delayed when the socket is down or the numbers are more than 60 s old;
/// a closed market with the socket up reads "at the close".
Liveness liveness(
  Freshness freshness, {
  required bool connected,
  required DateTime now,
}) {
  if (!connected) return Liveness.delayed;
  if (freshness.marketState == MarketState.closed) return Liveness.closed;
  if (now.difference(freshness.asOf) > staleAfter) return Liveness.delayed;
  return Liveness.live;
}

/// The current time, ticking every second, so data goes Delayed on its own
/// as it ages. Tests override it with a fixed time.
final clockProvider = NotifierProvider<Clock, DateTime>(Clock.new);

class Clock extends Notifier<DateTime> {
  @override
  DateTime build() {
    final timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => state = DateTime.now(),
    );
    ref.onDispose(timer.cancel);
    return DateTime.now();
  }
}
