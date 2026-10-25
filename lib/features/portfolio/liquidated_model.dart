import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../api/generated/export.dart' hide Freshness;
import '../../design/widgets/aura_receipt.dart';
import '../../format/money.dart';
import '../../format/time.dart';
import '../../l10n/strings.dart';
import 'liquidated_view.dart';

/// How a liquidation settled, as contract request #7 asks the server to
/// send it. The contract has no such record yet, and the app won't work the
/// settlement out itself (that's the server's rule), so fixtures supply it.
/// Amounts are decimal strings, like the API's.
@immutable
class Liquidation {
  const Liquidation({
    required this.position,
    required this.at,
    required this.triggerPrice,
    required this.maintenanceRatioPct,
    required this.price,
    required this.cost,
    required this.feeRatePct,
    required this.fee,
    required this.returned,
    required this.realizedPnl,
    required this.realizedPnlPct,
  });

  /// The position, now `LIQUIDATED`; its `short.collateral` is what was held.
  final Position position;
  final DateTime at;

  /// The liquidation price the stock crossed.
  final String triggerPrice;
  final String maintenanceRatioPct;

  /// What the shares were bought back at, and what that cost.
  final String price;
  final String cost;
  final String feeRatePct;
  final String fee;

  /// What came back to your cash.
  final String returned;
  final String realizedPnl;
  final String realizedPnlPct;
}

/// The liquidation receipt (W08), with the tape's line about it.
LiquidatedModel liquidatedModel({
  required Liquidation liquidation,
  required TapeItem tape,
  required tz.Location zone,
}) {
  final l = liquidation;
  final ticker = l.position.listing.ticker;
  final quantity = Decimal.parse(l.position.quantity);
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
      AuraReceiptRow(
        collateralHeld,
        formatMoney(d(l.position.short!.collateral)),
      ),
      AuraReceiptRow(boughtBack(quantity, d(l.price)), formatMoney(-d(l.cost))),
      AuraReceiptRow(feeLabel(d(l.feeRatePct)), formatMoney(-d(l.fee))),
    ],
    total: AuraReceiptRow(returned, formatMoney(d(l.returned))),
    tapeLabel: onTheTape,
    tape: quoted(tape.headline),
    tapeSource: nameNotInIt(at),
    seeStock: seeStock(ticker),
    portfolio: seePortfolio,
  );
}
