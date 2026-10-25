import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../surface.dart';
import '../tokens.dart';

/// The last step before anything that moves money: buy, sell, short, cover,
/// declare bankruptcy. Drag the knob to the end; it lands with a medium
/// haptic and calls [onConfirmed] once. Released early, it slides back.
/// VoiceOver users double-tap.
///
/// After landing it stays at the end, so one slide can't submit twice. Give
/// it a new key to reset it (for a requote, say).
class AuraSlideToConfirm extends StatefulWidget {
  const AuraSlideToConfirm({
    super.key,
    required this.label,
    this.onConfirmed,
    this.down = false,
  });

  /// "Slide to buy 12 $ANNA".
  final String label;

  /// Null disables the slider.
  final VoidCallback? onConfirmed;

  /// The `down` knob, for shorts and bankruptcy: the one fill that carries
  /// color.
  final bool down;

  @override
  State<AuraSlideToConfirm> createState() => _AuraSlideToConfirmState();
}

class _AuraSlideToConfirmState extends State<AuraSlideToConfirm>
    with SingleTickerProviderStateMixin {
  static const _height = 56.0;
  static const _knob = 48.0;
  static const _inset = 4.0;

  /// 0 at the start, 1 at the end.
  late final AnimationController _progress = AnimationController(vsync: this);
  double _travel = 1;
  bool _landed = false;

  bool get _enabled => widget.onConfirmed != null && !_landed;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _land() {
    if (_landed) return;
    setState(() => _landed = true);
    _progress.value = 1;
    HapticFeedback.mediumImpact();
    widget.onConfirmed?.call();
  }

  void _drag(DragUpdateDetails details) {
    if (!_enabled) return;
    _progress.value += details.delta.dx / _travel;
    if (_progress.value >= 1) _land();
  }

  void _release(DragEndDetails details) {
    if (!_enabled) return;
    if (_progress.value > 0.9) {
      _land();
    } else {
      final instant = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      _progress.animateTo(
        0,
        duration: instant ? Duration.zero : const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final knobColor = widget.down ? AuraColors.down : AuraColors.ink;
    final arrowColor = widget.down ? AuraColors.onUp : AuraColors.onInk;
    return Semantics(
      button: true,
      enabled: _enabled,
      label: '${widget.label}, double-tap to confirm',
      onTap: _enabled ? _land : null,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _travel = (constraints.maxWidth - _knob - _inset * 2).clamp(1, 1e9);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: _drag,
            onHorizontalDragEnd: _release,
            child: Container(
              height: _height,
              decoration: ShapeDecoration(
                color: AuraSheetScope.raised(context),
                shape: const StadiumBorder(),
              ),
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) => Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Opacity(
                        opacity: (1 - _progress.value * 1.5).clamp(0, 1),
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 21 / 16,
                            color: AuraColors.inkSecondary,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _inset + _progress.value * _travel,
                      top: _inset,
                      child: Opacity(
                        opacity: widget.onConfirmed == null ? 0.4 : 1,
                        child: Container(
                          width: _knob,
                          height: _knob,
                          decoration: BoxDecoration(
                            color: knobColor,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: AuraIcon(
                            AuraIcons.arrow,
                            size: 20,
                            weight: 2,
                            color: arrowColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
