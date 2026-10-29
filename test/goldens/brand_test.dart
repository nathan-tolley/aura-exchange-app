@Tags(['golden'])
library;

import 'package:aura_exchange/design/widgets/aura_wordmark.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// The launch screen is the wordmark as Flutter draws it, so the boot screen
/// takes over from it without a jump. These goldens are the launch images
/// themselves: `flutter test test/goldens/brand_test.dart --update-goldens`
/// redraws them after the wordmark changes.
void main() {
  const launch = '../../ios/Runner/Assets.xcassets/LaunchImage.imageset';
  for (final (scale, suffix) in [(1.0, ''), (2.0, '@2x'), (3.0, '@3x')]) {
    testWidgets('launch image $suffix', (tester) async {
      tester.view.physicalSize = AuraWordmark.size * scale;
      tester.view.devicePixelRatio = scale;
      addTearDown(tester.view.reset);
      const key = ValueKey('launch');
      await tester.pumpWidget(
        const KeyedSubtree(
          key: key,
          child: AuraTestApp(child: Center(child: AuraWordmark())),
        ),
      );
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('$launch/LaunchImage$suffix.png'),
      );
    });
  }
}
