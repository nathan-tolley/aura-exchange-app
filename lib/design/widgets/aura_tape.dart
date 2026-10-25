import 'package:decimal/decimal.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../format/change.dart';
import '../../format/money.dart';
import '../../format/ticker.dart';
import '../tokens.dart';
import 'aura_price_change.dart';

/// One listing on the tape.
class AuraTapeItem {
  const AuraTapeItem({
    required this.ticker,
    required this.price,
    required this.pct,
  });

  final String ticker;
  final Decimal price;

  /// Percent units: `6.70` is 6.70%.
  final Decimal pct;
}

/// The ticker tape: a monospaced strip of every listing's price and move,
/// pinned under the status bar on Home and Market. The app's one signature.
/// It scrolls slowly; with Reduce Motion it stays still and swipes. It fades
/// out at its right edge, the one functional gradient in the app. Items come
/// in market-cap order.
class AuraTape extends StatefulWidget {
  const AuraTape({super.key, required this.items});

  final List<AuraTapeItem> items;

  @override
  State<AuraTape> createState() => _AuraTapeState();
}

class _AuraTapeState extends State<AuraTape>
    with SingleTickerProviderStateMixin {
  /// Points per second.
  static const _speed = 24.0;

  final _scroll = ScrollController();
  late final Ticker _ticker = createTicker(_tick);
  Duration _last = Duration.zero;

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (_scroll.hasClients) _scroll.jumpTo(_scroll.offset + _speed * dt);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still && _ticker.isActive) {
      _ticker.stop();
    } else if (!still && !_ticker.isActive && widget.items.length > 1) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final style = AuraType.tape.copyWith(color: AuraColors.inkSecondary);
    return Semantics(
      label: 'Ticker tape',
      child: Container(
        height: 24,
        padding: const EdgeInsets.only(bottom: 10),
        foregroundDecoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AuraColors.line)),
        ),
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) => const LinearGradient(
            colors: [Color(0xFF000000), Color(0x00000000)],
            stops: [0.88, 1],
          ).createShader(rect),
          child: ListView.builder(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            // Loops forever when there's more than one listing.
            itemCount: items.length > 1 ? null : items.length,
            itemBuilder: (context, i) {
              final item = items[i % items.length];
              return Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Text.rich(
                  style: style,
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${formatTicker(item.ticker)} '
                            '${formatAmount(item.price.abs())} ',
                      ),
                      TextSpan(
                        text: formatTapeChange(item.pct),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AuraPriceChange.colorFor(
                            Trend.of(item.pct.round(scale: 2)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
