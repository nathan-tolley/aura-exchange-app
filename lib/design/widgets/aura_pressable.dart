import 'package:flutter/widgets.dart';

/// Tap handling for every Aura control: no ripple and no color change, just
/// a brief dim while a finger is down, like iOS. Not a screen component; the
/// `Aura*` controls use it, and each adds its own semantics.
class AuraPressable extends StatefulWidget {
  const AuraPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  State<AuraPressable> createState() => _AuraPressableState();
}

class _AuraPressableState extends State<AuraPressable> {
  bool _down = false;

  bool get _enabled => widget.onTap != null || widget.onLongPress != null;

  void _set(bool down) {
    if (_down != down && mounted) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _enabled ? (_) => _set(true) : null,
      onTapUp: _enabled ? (_) => _set(false) : null,
      onTapCancel: _enabled ? () => _set(false) : null,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedOpacity(
        opacity: _down ? 0.55 : 1,
        duration: reduceMotion
            ? Duration.zero
            : Duration(milliseconds: _down ? 60 : 160),
        child: widget.child,
      ),
    );
  }
}
