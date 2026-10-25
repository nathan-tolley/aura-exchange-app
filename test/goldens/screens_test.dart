@Tags(['golden'])
library;

import 'package:aura_exchange/design/gallery/screen_states.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// One golden per drawn screen, at 390×844 @2x with the reference's data, so
/// `test/goldens/screens/W##-*.png` can be compared with
/// `design/reference/screens/W##-*.png`:
///
///   python tool/golden_diff.py diff test/goldens/screens/W09-MarketClosed.png design/reference/screens/W09-MarketClosed.png
void main() {
  for (final screen in screenStates) {
    final reference = screen.reference;
    if (reference == null) continue;
    testWidgets('${screen.id} ${screen.label}', (tester) async {
      await expectScreen(
        tester,
        'screens/$reference',
        Builder(builder: screen.build),
      );
    });
  }
}
