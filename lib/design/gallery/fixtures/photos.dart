import 'package:flutter/widgets.dart';

import '../../tokens.dart';

/// Stand-ins for receipts in the State Gallery: flat drawings of the kind
/// of thing people attach (a chat screenshot, a photo of a note), so
/// goldens don't wait on decoding real images. The app shows the real
/// photo (`Image.memory`).
Widget fixturePhoto(int index) => switch (index % 4) {
  0 => const _Chat(),
  1 => const _Note(),
  2 => const _Chat(flipped: true),
  _ => const _Scene(),
};

Widget _box(Color color, {double radius = 3}) => DecoratedBox(
  decoration: BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
  ),
);

/// A chat screenshot: bubbles on black.
class _Chat extends StatelessWidget {
  const _Chat({this.flipped = false});

  final bool flipped;

  @override
  Widget build(BuildContext context) {
    Widget bubble(double width, {required bool mine}) => Align(
      alignment: mine == flipped ? Alignment.centerLeft : Alignment.centerRight,
      child: SizedBox(
        width: width,
        height: 9,
        child: _box(mine ? AuraColors.inkSecondary : AuraColors.raised2),
      ),
    );
    return ColoredBox(
      color: const Color(0xFF000000),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 7, 6, 5),
        child: Column(
          spacing: 5,
          children: [
            bubble(30, mine: false),
            bubble(24, mine: true),
            bubble(36, mine: false),
            bubble(18, mine: true),
          ],
        ),
      ),
    );
  }
}

/// A photo of a handwritten note on a table.
class _Note extends StatelessWidget {
  const _Note();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFF3A3128),
    child: Center(
      child: Transform.rotate(
        angle: -0.12,
        child: SizedBox(
          width: 38,
          height: 46,
          child: ColoredBox(
            color: const Color(0xFFE9E4D6),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 7, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  for (final w in const [24.0, 18.0, 22.0, 12.0])
                    SizedBox(
                      width: w,
                      height: 2,
                      child: _box(const Color(0xFF5A5650), radius: 1),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// A night photo: a lit window in a dark street.
class _Scene extends StatelessWidget {
  const _Scene();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFF1C2230),
    child: Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 22,
          child: _box(const Color(0xFF101318), radius: 0),
        ),
        Positioned(
          left: 22,
          top: 14,
          width: 16,
          height: 20,
          child: _box(const Color(0xFFD9B46A), radius: 1),
        ),
      ],
    ),
  );
}
