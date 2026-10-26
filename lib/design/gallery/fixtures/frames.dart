import 'package:flutter/widgets.dart';

import '../../tokens.dart';

/// A sheet presented over a screen, as the app's modal route draws it: the
/// screen on `bg` under the scrim, the sheet at the bottom.
Widget sheetOver(Widget page, Widget sheet) => Builder(
  builder: (context) => ColoredBox(
    color: AuraColors.bg,
    child: Stack(
      children: [
        page,
        const Positioned.fill(child: ColoredBox(color: AuraColors.scrim)),
        Align(alignment: Alignment.bottomCenter, child: sheet),
      ],
    ),
  ),
);

/// Text controllers for a fixture, made and disposed with it.
class Controlled extends StatefulWidget {
  const Controlled({super.key, required this.texts, required this.builder});

  final List<String> texts;
  final Widget Function(BuildContext, List<TextEditingController>) builder;

  @override
  State<Controlled> createState() => _ControlledState();
}

class _ControlledState extends State<Controlled> {
  late final _controllers = [
    for (final t in widget.texts) TextEditingController(text: t),
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controllers);
}
