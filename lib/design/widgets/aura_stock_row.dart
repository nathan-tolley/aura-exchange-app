import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../text.dart';
import '../../format/change.dart';
import '../../format/money.dart';
import '../../format/ticker.dart';
import '../surface.dart';
import '../tokens.dart';
import '../tone.dart';
import 'aura_avatar.dart';
import 'aura_money.dart';
import 'aura_pressable.dart';
import 'aura_price_change.dart';
import 'aura_sparkline.dart';
import 'aura_tag.dart';

/// The row for one listing in watchlists, the market list and search
/// results: avatar, ticker, name and tag, sparkline, price and change, on a
/// hairline. 64 pt tall. Tap opens the stock page; long-press opens a quick
/// trade.
class AuraStockRow extends StatelessWidget {
  const AuraStockRow({
    super.key,
    required this.ticker,
    required this.name,
    required this.price,
    required this.pct,
    required this.abs,
    this.initial,
    this.tag,
    this.tagTone = AuraTone.neutral,
    this.points,
    this.onTap,
    this.onLongPress,
  });

  final String ticker;
  final String name;
  final Decimal price;
  final Decimal pct;
  final Decimal abs;

  /// Defaults to the ticker's first letter.
  final String? initial;
  final String? tag;
  final AuraTone tagTone;

  /// Today's prices for the sparkline, oldest first.
  final List<double>? points;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final symbol = formatTicker(ticker);
    final trend = Trend.of(pct.round(scale: 2));
    return Semantics(
      button: onTap != null,
      label: [
        symbol,
        name,
        ?tag,
        formatMoney(price),
        changeLabel(abs: abs, pct: pct),
      ].join(', '),
      onTap: onTap,
      onLongPress: onLongPress,
      excludeSemantics: true,
      child: AuraPressable(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          constraints: const BoxConstraints(minHeight: AuraSize.row),
          foregroundDecoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AuraSheetScope.line(context)),
            ),
          ),
          child: Row(
            spacing: 12,
            children: [
              AuraAvatar(
                initial ?? symbol.substring(1, 2),
                size: AuraSize.avatar,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Text(
                      symbol,
                      maxLines: 1,
                      style: AuraType.rowTitle.copyWith(letterSpacing: 0),
                    ),
                    Row(
                      spacing: 6,
                      children: [
                        Flexible(
                          child: auraLiftFootnote(
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AuraType.footnote.copyWith(
                                color: AuraColors.inkTertiary,
                              ),
                            ),
                          ),
                        ),
                        if (tag != null) AuraTag(tag!, tone: tagTone),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 72,
                height: 30,
                child: points == null
                    ? null
                    // Drawn at 84×30 and scaled to fit, like the reference.
                    : FittedBox(
                        child: AuraSparkline(points: points!, trend: trend),
                      ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  AuraMoney(price),
                  AuraPriceChange(abs: abs, pct: pct, size: AuraChangeSize.sm),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
