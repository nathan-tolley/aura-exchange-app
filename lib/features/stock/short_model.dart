import 'package:decimal/decimal.dart';

import '../../api/generated/export.dart' hide Freshness;
import '../../design/tone.dart';
import '../../design/widgets/aura_banner.dart';
import '../../format/money.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';
import 'short_view.dart';

/// Your short on its stock page, from the listing and your position (whose
/// `short` carries the collateral, the thresholds and the liquidation price
/// the server computed). The warning shows once the collateral ratio is at
/// or under the server's warning line (W07).
ShortPageModel shortPageModel({
  required ListingDetail listing,
  required Position position,
}) {
  final short = position.short!;
  final price = Decimal.parse(listing.price);
  final liquidation = Decimal.parse(short.liquidationPrice);
  final quantity = Decimal.parse(position.quantity);
  final collateral = Decimal.parse(short.collateralRatioPct);
  final pnl = Decimal.parse(position.unrealizedPnl);
  // How far the price can rise before liquidation, as a share of the price.
  final away = ((liquidation - price) * Decimal.fromInt(100) / price).toDecimal(
    scaleOnInfinitePrecision: 8,
  );
  final warn = collateral <= Decimal.parse(short.warningRatioPct);
  return ShortPageModel(
    line: stockLine(
      listing.ticker,
      listing.displayName,
      badges: listing.badges,
    ),
    price: price,
    changeAbs: Decimal.parse(listing.changeAbs),
    changePct: Decimal.parse(listing.changePct),
    warning: warn
        ? BannerModel(
            tone: AuraBannerTone.warn,
            title: nearLiquidationTitle(listing.ticker),
            body: nearLiquidationBody(
              away,
              Decimal.parse(listing.shortInterestPct),
            ),
          )
        : null,
    sectionTitle: yourShort,
    rangeLabel: entryToLiquidation,
    entry: Decimal.parse(position.avgPrice),
    liquidation: liquidation,
    rangeNote: awayFromLiquidation(away),
    stats: [
      ShortStat(statPosition, shortQuantity(quantity)),
      ShortStat(
        statReturn,
        formatMoney(pnl),
        tone: pnl.sign < 0 ? AuraTone.down : AuraTone.up,
      ),
      ShortStat(
        statCollateral,
        ratio(collateral),
        trailing: minimumRatio(Decimal.parse(short.maintenanceRatioPct)),
        trailingTone: warn ? AuraTone.warn : AuraTone.neutral,
      ),
      ShortStat(statBorrowFee, perDay(Decimal.parse(short.borrowFeeDailyPct))),
    ],
    explainer: liquidationExplainer(liquidation, quantity),
    coverPart: cover(
      (quantity / Decimal.fromInt(2)).toDecimal(scaleOnInfinitePrecision: 4),
    ),
    coverAll: coverAll(quantity),
  );
}
