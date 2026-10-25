import 'package:flutter/cupertino.dart';

import 'tokens.dart';

/// How a bottom sheet (`AuraSheet`) is presented: over the screen it came
/// from, which dims under the `scrim` (W05, W06), sliding up from the bottom.
/// Tapping the scrim or dragging the sheet down closes it through
/// `Navigator.maybePop`, so a sheet with something half-filled can ask
/// "Discard this filing?" first with a `PopScope`. With Reduce Motion it
/// fades instead of sliding.
class AuraSheetRoute<T> extends PopupRoute<T> {
  AuraSheetRoute({required this.builder, super.settings});

  final WidgetBuilder builder;

  @override
  Color get barrierColor => AuraColors.scrim;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => 'Close';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 380);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 260);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: _DragToClose(route: this, child: Builder(builder: builder)),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return FadeTransition(opacity: animation, child: child);
    }
    // Close to the iOS sheet spring: fast out, settling without overshoot.
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return SlideTransition(
      position: Tween(begin: const Offset(0, 1), end: Offset.zero)
          .animate(curved),
      child: child,
    );
  }
}

/// A go_router page for an [AuraSheetRoute].
class AuraSheetPage<T> extends Page<T> {
  const AuraSheetPage({required this.child, super.key, super.name});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) =>
      AuraSheetRoute<T>(builder: (_) => child, settings: this);
}

/// Follows the finger down; past a third of the sheet's height, or on a
/// downward fling, asks the route to close.
class _DragToClose extends StatefulWidget {
  const _DragToClose({required this.route, required this.child});

  final ModalRoute<Object?> route;
  final Widget child;

  @override
  State<_DragToClose> createState() => _DragToCloseState();
}

class _DragToCloseState extends State<_DragToClose> {
  double _offset = 0;

  void _update(DragUpdateDetails details) {
    setState(() => _offset = (_offset + details.delta.dy).clamp(0, 2000));
  }

  void _end(DragEndDetails details) {
    final height = context.size?.height ?? 1;
    final fling = (details.primaryVelocity ?? 0) > 700;
    if (fling || _offset > height / 3) {
      Navigator.of(context).maybePop();
    }
    // Spring back; if the pop goes ahead the route slides the rest away.
    setState(() => _offset = 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _update,
      onVerticalDragEnd: _end,
      child: Transform.translate(
        offset: Offset(0, _offset),
        child: widget.child,
      ),
    );
  }
}
