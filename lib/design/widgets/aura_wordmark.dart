import 'package:flutter/widgets.dart';

import '../../l10n/strings.dart';
import '../tokens.dart';

/// The brand lockup: the name, and under it the exchange's own line off the
/// tape, in the tape's style. A logo, so it's set in Inter (bundled) at a
/// fixed size and ignores text scaling, like the launch screen it matches.
///
/// The launch screen is this widget rendered (`test/goldens/brand_test.dart`
/// writes `LaunchImage*.png`), and the boot screen shows it in the same
/// place, so the app takes over from iOS without a jump.
class AuraWordmark extends StatelessWidget {
  const AuraWordmark({super.key});

  /// The launch image's size in points; it's centred on the screen.
  static const size = Size(240, 56);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: appName,
      excludeSemantics: true,
      child: SizedBox.fromSize(
        size: size,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Text(
              appName,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                height: 22 / 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: AuraColors.ink,
              ),
            ),
            Text.rich(
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontFamily: AuraFonts.mono,
                fontSize: 11,
                height: 14 / 11,
                letterSpacing: 0.22,
                color: AuraColors.inkSecondary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              TextSpan(
                children: [
                  TextSpan(text: '$brandTapeLine '),
                  TextSpan(
                    text: brandTapeChange,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AuraColors.up,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
