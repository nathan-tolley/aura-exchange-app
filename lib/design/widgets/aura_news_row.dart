import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../surface.dart';
import '../text.dart';
import '../tokens.dart';
import 'aura_pressable.dart';
import 'aura_price_change.dart';

/// One thing on the tape, in a list (the Tape tab, a stock's tape, the
/// notifications inbox): a source line ("$JAKE · Ruling · 2 h ago") with the
/// price move it caused on the right, then the Analyst's headline in the
/// serif, as the server wrote it. Hairline under it, no box.
class AuraNewsRow extends StatelessWidget {
  const AuraNewsRow({
    super.key,
    required this.source,
    required this.headline,
    this.movePct,
    this.unread = false,
    this.onTap,
  });

  /// "$JAKE · Ruling · 2 h ago".
  final String source;

  /// The Analyst's line, shown as-is.
  final String headline;

  /// The move it caused, in percent units.
  final Decimal? movePct;

  /// New since you last looked: a small `ink` dot before the source.
  final bool unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final move = movePct;
    return Semantics(
      button: onTap != null,
      label: [if (unread) 'New', source, headline].join(', '),
      onTap: onTap,
      excludeSemantics: true,
      child: AuraPressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          foregroundDecoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AuraSheetScope.line(context)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              Row(
                spacing: 6,
                children: [
                  if (unread)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AuraColors.ink,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: auraLiftFootnote(
                      Text(
                        source,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AuraType.footnote.copyWith(
                          color: AuraColors.inkTertiary,
                        ),
                      ),
                    ),
                  ),
                  if (move != null)
                    AuraPriceChange(pct: move, size: AuraChangeSize.sm),
                ],
              ),
              Text(
                headline,
                style: AuraType.quote.copyWith(
                  fontSize: 17,
                  height: 24 / 17,
                  color: AuraColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
