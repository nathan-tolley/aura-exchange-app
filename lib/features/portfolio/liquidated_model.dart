import 'package:decimal/decimal.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../api/generated/export.dart' hide Freshness;
import '../../design/widgets/aura_receipt.dart';
import '../../format/money.dart';
import '../../format/time.dart';
import '../../l10n/strings.dart';
import 'liquidated_view.dart';

/// The liquidation receipt (W08), from a `LIQUIDATED` position and how it
/// settled (`Position.liquidation`), with the tape's line about it once
/// it's found ([tape] is null until then, or if the tape doesn't have it).
LiquidatedModel liquidatedModel({
  required Position position,
  TapeItem? tape,
  required tz.Location zone,
}) {
  final l = position.liquidation!;
  final ticker = position.listing.ticker;
  final quantity = Decimal.parse(position.quantity);
  final at = formatClock(l.at, zone);
  Decimal d(String s) => Decimal.parse(s);
  return LiquidatedModel(
    title: liquidatedTitle(ticker),
    why: liquidatedWhy(
      at: at,
      ticker: ticker,
      triggerPrice: d(l.triggerPrice),
      maintenancePct: d(l.maintenanceRatioPct),
    ),
    heroLabel: returnedToCash,
    returned: d(l.returned),
    pnl: d(l.realizedPnl),
    pnlPct: d(l.realizedPnlPct),
    period: onTheTrade,
    rows: [
      AuraReceiptRow(collateralHeld, formatMoney(d(l.collateral))),
      AuraReceiptRow(boughtBack(quantity, d(l.price)), formatMoney(-d(l.cost))),
      AuraReceiptRow(feeLabel(d(l.feeRate)), formatMoney(-d(l.fee))),
    ],
    total: AuraReceiptRow(returned, formatMoney(d(l.returned))),
    tapeLabel: onTheTape,
    tape: tape == null ? null : quoted(tape.headline),
    tapeSource: nameNotInIt(at),
    seeStock: seeStock(ticker),
    portfolio: seePortfolio,
  );
}

/// The tape's line about this liquidation, from the stock's tape: its
/// `LIQUIDATION` item nearest the time it happened, within five minutes.
TapeItem? liquidationTapeItem(List<TapeItem> tape, Position position) {
  final at = position.liquidation?.at;
  if (at == null) return null;
  TapeItem? nearest;
  for (final t in tape) {
    if (t.type != TapeItemType.liquidation) continue;
    final gap = t.at.difference(at).abs();
    if (gap > const Duration(minutes: 5)) continue;
    if (nearest == null || gap < nearest.at.difference(at).abs()) nearest = t;
  }
  return nearest;
}
