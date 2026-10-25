import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';

import '../text.dart';
import '../../format/money.dart';
import '../icons.dart';
import '../tokens.dart';
import 'aura_icon_button.dart';
import 'aura_pressable.dart';

/// The share count at the top of every trade sheet: minus, a big light
/// number, plus. Holding minus or plus repeats; tapping the number opens the
/// keypad. Minus disables at 1. Plus never disables: the sheet explains why a
/// quantity can't be afforded instead.
class AuraStepper extends StatelessWidget {
  const AuraStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.note,
    this.onTapValue,
  });

  /// Whole or fractional shares (up to 4 decimals).
  final Decimal value;

  /// Called with the value one share lower or higher.
  final ValueChanged<Decimal> onChanged;

  /// "shares at about A$124.10".
  final String? note;

  /// Opens the keypad.
  final VoidCallback? onTapValue;

  @override
  Widget build(BuildContext context) {
    final one = Decimal.one;
    final canDecrease = value > one;
    return Semantics(
      container: true,
      label: 'Quantity',
      child: Row(
        children: [
          // Glyphs sit 10 pt past the gutter, as in the reference
          // (CSS `margin: 0 -10px`), so they align optically.
          _Repeating(
            onStep: canDecrease ? () => onChanged(value - one) : null,
            offset: -10,
            child: AuraIconButton(
              icon: AuraIcons.minus,
              label: 'One fewer',
              onPressed: canDecrease ? () => onChanged(value - one) : null,
            ),
          ),
          Expanded(
            child: AuraPressable(
              onTap: onTapValue,
              child: Semantics(
                liveRegion: true,
                label: '${formatQuantity(value)} shares',
                excludeSemantics: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Text(
                      formatQuantity(value),
                      style: AuraType.display,
                      maxLines: 1,
                    ),
                    if (note != null)
                      auraLiftFootnote(
                        Text(
                          note!,
                          style: AuraType.footnote.copyWith(
                            color: AuraColors.inkTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          _Repeating(
            onStep: () => onChanged(value + one),
            offset: 10,
            child: AuraIconButton(
              icon: AuraIcons.plus,
              label: 'One more',
              onPressed: () => onChanged(value + one),
            ),
          ),
        ],
      ),
    );
  }
}

/// Repeats [onStep] while a finger stays down on [child]: after 400 ms, then
/// every 80 ms. The child's own tap still handles a single press. [offset]
/// shifts it sideways without changing layout.
class _Repeating extends StatefulWidget {
  const _Repeating({
    required this.child,
    required this.onStep,
    required this.offset,
  });

  final Widget child;
  final VoidCallback? onStep;
  final double offset;

  @override
  State<_Repeating> createState() => _RepeatingState();
}

class _RepeatingState extends State<_Repeating> {
  Timer? _delay;
  Timer? _repeat;

  void _start(PointerDownEvent _) {
    if (widget.onStep == null) return;
    _delay = Timer(const Duration(milliseconds: 400), () {
      _repeat = Timer.periodic(
        const Duration(milliseconds: 80),
        (_) => widget.onStep?.call(),
      );
    });
  }

  void _stop([PointerEvent? _]) {
    _delay?.cancel();
    _repeat?.cancel();
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset(widget.offset, 0),
    child: Listener(
      onPointerDown: _start,
      onPointerUp: _stop,
      onPointerCancel: _stop,
      child: widget.child,
    ),
  );
}
