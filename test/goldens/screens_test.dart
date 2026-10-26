@Tags(['golden'])
library;

import 'package:aura_exchange/design/gallery/screen_states.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// One golden per screen state in the State Gallery, at 390×844 @2x. A drawn
/// screen's golden has its reference's name and data, so
/// `test/goldens/screens/W##-*.png` can be compared with
/// `design/reference/screens/W##-*.png`:
///
///   python tool/golden_diff.py diff test/goldens/screens/W09-MarketClosed.png design/reference/screens/W09-MarketClosed.png
void main() {
  for (final screen in screenStates) {
    testWidgets('${screen.id} ${screen.label}', (tester) async {
      await expectScreen(
        tester,
        'screens/${screen.golden}',
        Builder(builder: screen.build),
      );
    });
  }
}
