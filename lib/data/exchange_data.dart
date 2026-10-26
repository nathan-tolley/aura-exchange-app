import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/generated/export.dart';
import '../api/stream.dart';
import 'lifecycle.dart';
import 'live_market.dart';
import 'repositories.dart';

/// Your cash, positions and open orders in one exchange, as the server
/// values them. Prices move with every tick, so this refetches when the
/// exchange's ticks or market state arrive (at most every 15 s, the tick
/// rate), when polling is due, and on resume. The app never revalues a
/// portfolio itself.
final portfolioProvider = FutureProvider.autoDispose.family<Portfolio, String>((
  ref,
  exchangeId,
) {
  ref.watch(refetchSignalProvider);
  final messages = ref.watch(auraStreamProvider).messages.listen((m) {
    final moved = switch (m) {
      TicksMessage() => m.exchangeId == exchangeId,
      MarketMessage() => m.exchangeId == exchangeId,
      PollDue() => m.exchangeId == exchangeId,
      _ => false,
    };
    if (moved) ref.invalidateSelf();
  });
  ref.onDispose(() => unawaited(messages.cancel()));
  return ref.read(tradingRepositoryProvider).portfolio(exchangeId);
});

/// The newest thing on an exchange's tape, or null when there's nothing yet
/// (or the tape can't be read, which leaves the line out rather than
/// failing the screen).
final latestTapeProvider = FutureProvider.autoDispose.family<TapeItem?, String>(
  (ref, exchangeId) async {
    ref.watch(refetchSignalProvider);
    try {
      final page = await ref
          .read(tapeRepositoryProvider)
          .tape(exchangeId, limit: 1);
      return page.items.firstOrNull;
    } on Exception {
      return null;
    }
  },
);
