import 'package:flutter/widgets.dart';

import '../../format/change.dart';
import '../tokens.dart';
import 'aura_price_change.dart';

/// Today's path in a row, with a dotted baseline. No axes, labels or dots:
/// detail lives on the stock page chart. Decorative; the row already says
/// the numbers.
class AuraSparkline extends StatelessWidget {
  const AuraSparkline({
    super.key,
    required this.points,
    this.trend,
    this.width = 84,
    this.height = 30,
    this.baseline = true,
    this.previousClose,
  });

  /// Oldest first.
  final List<double> points;

  /// Defaults to last vs first.
  final Trend? trend;
  final double width;
  final double height;

  /// Draw the dotted baseline.
  final bool baseline;

  /// Puts the baseline at the previous close; otherwise it's the midline.
  final double? previousClose;

  @override
  Widget build(BuildContext context) {
    final t =
        trend ??
        (points.length < 2
            ? Trend.flat
            : points.last > points.first
            ? Trend.up
            : points.last < points.first
            ? Trend.down
            : Trend.flat);
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(width, height),
        painter: _SparkPainter(
          points: points,
          color: AuraPriceChange.colorFor(t),
          baseline: baseline,
          previousClose: previousClose,
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter({
    required this.points,
    required this.color,
    required this.baseline,
    required this.previousClose,
  });

  final List<double> points;
  final Color color;
  final bool baseline;
  final double? previousClose;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    var min = points.reduce((a, b) => a < b ? a : b);
    var max = points.reduce((a, b) => a > b ? a : b);
    if (previousClose != null) {
      if (previousClose! < min) min = previousClose!;
      if (previousClose! > max) max = previousClose!;
    }
    final span = max - min == 0 ? 1 : max - min;
    // 2 pt of air above and below, as in the reference.
    double y(double v) =>
        size.height - 2 - (v - min) / span * (size.height - 4);

    if (baseline) {
      final by = previousClose == null ? size.height / 2 : y(previousClose!);
      final dot = Paint()
        ..color = AuraColors.inkFaint
        ..strokeWidth = 1;
      for (var x = 0.0; x < size.width; x += 4) {
        canvas.drawLine(Offset(x, by), Offset(x + 1, by), dot);
      }
    }

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i / (points.length - 1) * size.width;
      i == 0 ? path.moveTo(x, y(points[i])) : path.lineTo(x, y(points[i]));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter old) =>
      old.points != points ||
      old.color != color ||
      old.baseline != baseline ||
      old.previousClose != previousClose;
}
