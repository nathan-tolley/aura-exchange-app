import 'package:timezone/timezone.dart' as tz;

import '../../api/generated/export.dart' hide Freshness;
import '../../data/freshness.dart';
import '../../design/widgets/aura_status_chip.dart';
import '../../l10n/strings.dart';

/// The market's status chip for a screen's header or list: Delayed with its
/// age when the numbers aren't live (W11), otherwise the market state, with
/// when it reopens while closed ("Closed · opens 7:00 am").
(AuraStatus, String?) marketChip(
  Freshness freshness,
  Liveness liveness, {
  required tz.Location zone,
  required DateTime now,
}) {
  if (liveness == Liveness.delayed) {
    return (AuraStatus.delayed, asOfStatus(freshness.asOf, zone, now: now));
  }
  final next = freshness.nextChangeAt;
  return switch (freshness.marketState) {
    MarketState.closed => (
      AuraStatus.closed,
      next == null ? null : closedOpens(next, zone, now: now),
    ),
    MarketState.pre => (AuraStatus.pre, null),
    MarketState.after => (AuraStatus.after, null),
    MarketState.halted => (AuraStatus.halted, haltedExchangeWide),
    _ => (AuraStatus.open, null),
  };
}
