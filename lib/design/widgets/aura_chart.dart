import 'package:decimal/decimal.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../format/change.dart';
import '../../format/money.dart';
import '../tokens.dart';
import '../tone.dart';
import 'aura_chart_tooltip.dart';
import 'aura_price_change.dart';

/// One point on a chart: a close at a time.
@immutable
class AuraChartPoint {
  const AuraChartPoint(this.at, this.price);

  final DateTime at;
  final Decimal price;
}

/// A ruling on the line: an `ink` dot whose tooltip says its impact.
@immutable
class AuraChartMarker {
  const AuraChartMarker({required this.at, required this.label, this.tone});

  final DateTime at;

  /// "−18 ruling".
  final String label;

  /// The label's color: `down` for a loss, `up` for a gain.
  final AuraTone? tone;
}

/// The stock page's chart (DESIGN.md → Charts). One 1.5 pt line in `up` or
/// `down` by the range's direction, no fill and no glow; the previous close
/// as a dotted `inkFaint` line; rulings as small `ink` dots. A finger on it
/// shows a 1 pt `inkTertiary` crosshair, an `ink` dot ringed in `bg` and an
/// `AuraChartTooltip`, snapping to points with a light haptic at each
/// ruling. Drawn with a `CustomPainter`, no chart library.
class AuraChart extends StatefulWidget {
  const AuraChart({
    super.key,
    required this.points,
    this.previousClose,
    this.markers = const [],
    this.trend,
    this.height = 180,
    this.onScrub,
    this.emptyLabel = 'No trades yet',
    this.scrubbing,
  });

  /// Oldest first.
  final List<AuraChartPoint> points;

  /// The dotted line, on the 1D range.
  final Decimal? previousClose;
  final List<AuraChartMarker> markers;

  /// Defaults to the last point against the previous close (or the first).
  final Trend? trend;
  final double height;

  /// The point under the finger, or null when it lifts; the screen can show
  /// its time.
  final ValueChanged<AuraChartPoint?>? onScrub;

  /// Shown when there's nothing to draw.
  final String emptyLabel;

  /// Starts with a finger on this point (the State Gallery and goldens).
  final int? scrubbing;

  @override
  State<AuraChart> createState() => _AuraChartState();
}

class _AuraChartState extends State<AuraChart> {
  late int? _index = widget.scrubbing;

  Trend get _trend {
    final t = widget.trend;
    if (t != null) return t;
    final p = widget.points;
    if (p.isEmpty) return Trend.flat;
    final from = widget.previousClose ?? p.first.price;
    return Trend.of(p.last.price - from);
  }

  /// The marker on the point at [i], if any: the one nearest in time among
  /// those closer to this point than to its neighbours.
  AuraChartMarker? _markerAt(int i) {
    for (final m in widget.markers) {
      if (_nearest(m.at) == i) return m;
    }
    return null;
  }

  int _nearest(DateTime at) {
    final p = widget.points;
    var best = 0;
    var bestGap = (p.first.at.difference(at)).abs();
    for (var i = 1; i < p.length; i++) {
      final gap = p[i].at.difference(at).abs();
      if (gap < bestGap) {
        best = i;
        bestGap = gap;
      }
    }
    return best;
  }

  void _scrub(double x, double width) {
    final n = widget.points.length;
    if (n == 0) return;
    final i = n == 1 ? 0 : (x / width * (n - 1)).round().clamp(0, n - 1);
    if (i == _index) return;
    if (_markerAt(i) != null) HapticFeedback.lightImpact();
    setState(() => _index = i);
    widget.onScrub?.call(widget.points[i]);
  }

  void _lift() {
    if (_index == null) return;
    setState(() => _index = null);
    widget.onScrub?.call(null);
  }

  String _describe() {
    final p = widget.points;
    if (p.isEmpty) return widget.emptyLabel;
    final from = widget.previousClose ?? p.first.price;
    final change = p.last.price - from;
    final pct = from == Decimal.zero
        ? Decimal.zero
        : (change * Decimal.fromInt(100) / from).toDecimal(
            scaleOnInfinitePrecision: 2,
          );
    return 'Chart, from ${formatMoney(from)} to ${formatMoney(p.last.price)}, '
        '${changeLabel(abs: change, pct: pct)}';
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    final color = AuraPriceChange.colorFor(_trend);
    return Semantics(
      label: _describe(),
      excludeSemantics: true,
      child: SizedBox(
        height: widget.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            if (points.isEmpty) {
              return Center(
                child: Text(
                  widget.emptyLabel,
                  style: AuraType.footnote.copyWith(
                    color: AuraColors.inkTertiary,
                  ),
                ),
              );
            }
            final geometry = _Geometry(
              points: points,
              previousClose: widget.previousClose,
              size: Size(width, widget.height),
            );
            final i = _index;
            final marker = i == null ? null : _markerAt(i);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (d) => _scrub(d.localPosition.dx, width),
              onHorizontalDragUpdate: (d) => _scrub(d.localPosition.dx, width),
              onHorizontalDragEnd: (_) => _lift(),
              onHorizontalDragCancel: _lift,
              onLongPressStart: (d) => _scrub(d.localPosition.dx, width),
              onLongPressMoveUpdate: (d) => _scrub(d.localPosition.dx, width),
              onLongPressEnd: (_) => _lift(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: Size(width, widget.height),
                    painter: _ChartPainter(
                      geometry: geometry,
                      color: color,
                      markers: [for (final m in widget.markers) _nearest(m.at)],
                      scrub: i,
                    ),
                  ),
                  if (i != null)
                    _Tooltip(
                      at: geometry.offset(i),
                      width: width,
                      child: AuraChartTooltip(
                        price: points[i].price,
                        badge: marker?.label,
                        tone: marker?.tone ?? AuraTone.neutral,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Where each point sits: the range of prices (with the previous close)
/// fills the height, with air above for the tooltip.
class _Geometry {
  _Geometry({
    required this.points,
    required this.previousClose,
    required this.size,
  }) {
    final values = [
      for (final p in points) p.price.toDouble(),
      ?previousClose?.toDouble(),
    ];
    _min = values.reduce((a, b) => a < b ? a : b);
    _max = values.reduce((a, b) => a > b ? a : b);
  }

  final List<AuraChartPoint> points;
  final Decimal? previousClose;
  final Size size;
  late final double _min;
  late final double _max;

  static const _top = 36.0;
  static const _bottom = 8.0;

  double y(double v) {
    final span = _max - _min == 0 ? 1 : _max - _min;
    final h = size.height - _top - _bottom;
    return _max == _min
        ? _top + h / 2
        : size.height - _bottom - (v - _min) / span * h;
  }

  double x(int i) => points.length == 1
      ? size.width / 2
      : i / (points.length - 1) * size.width;

  Offset offset(int i) => Offset(x(i), y(points[i].price.toDouble()));
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter({
    required this.geometry,
    required this.color,
    required this.markers,
    required this.scrub,
  });

  final _Geometry geometry;
  final Color color;

  /// Indexes of the points rulings sit on.
  final List<int> markers;
  final int? scrub;

  @override
  void paint(Canvas canvas, Size size) {
    final g = geometry;
    final close = g.previousClose;
    if (close != null) {
      final y = g.y(close.toDouble());
      final dot = Paint()
        ..color = AuraColors.inkFaint
        ..strokeWidth = 1;
      for (var x = 0.0; x < size.width; x += 4) {
        canvas.drawLine(Offset(x, y), Offset(x + 1.5, y), dot);
      }
    }

    final path = Path();
    for (var i = 0; i < g.points.length; i++) {
      final o = g.offset(i);
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    for (final i in markers) {
      final o = g.offset(i);
      canvas.drawCircle(o, 4.5, Paint()..color = AuraColors.bg);
      canvas.drawCircle(o, 3, Paint()..color = AuraColors.ink);
    }

    final s = scrub;
    if (s != null) {
      final o = g.offset(s);
      canvas.drawLine(
        Offset(o.dx, 0),
        Offset(o.dx, size.height),
        Paint()
          ..color = AuraColors.inkTertiary
          ..strokeWidth = 1,
      );
      canvas.drawCircle(o, 6, Paint()..color = AuraColors.bg);
      canvas.drawCircle(o, 4, Paint()..color = AuraColors.ink);
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.geometry.points != geometry.points ||
      old.color != color ||
      old.scrub != scrub ||
      old.markers.length != markers.length;
}

/// The tooltip above the point, kept inside the chart's width.
class _Tooltip extends StatelessWidget {
  const _Tooltip({required this.at, required this.width, required this.child});

  final Offset at;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: CustomSingleChildLayout(
        delegate: _TooltipLayout(at.dx),
        child: child,
      ),
    );
  }
}

class _TooltipLayout extends SingleChildLayoutDelegate {
  _TooltipLayout(this.x);

  final double x;

  @override
  Size getSize(BoxConstraints constraints) => Size(constraints.maxWidth, 28);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) => Offset(
    (x - childSize.width / 2).clamp(0, size.width - childSize.width),
    0,
  );

  @override
  bool shouldRelayout(_TooltipLayout old) => old.x != x;
}
