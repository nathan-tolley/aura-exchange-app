import 'package:aura_exchange/design/gallery/component_states.dart';
import 'package:aura_exchange/design/gallery/gallery_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// Every state in the State Gallery builds, on its own, without errors or
/// overflow. A state that breaks fails here, not halfway down the gallery.
void main() {
  test('the gallery covers all 31 components', () {
    final names = componentStates.map((s) => s.name).toSet();
    expect(names, hasLength(31));
    expect(componentStates.every((s) => s.states.isNotEmpty), isTrue);
  });

  for (final section in componentStates) {
    for (final state in section.states) {
      testWidgets('${section.name}: ${state.label}', (tester) async {
        await tester.pumpWidget(
          AuraTestApp(
            reduceMotion: true,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: 358, child: Builder(builder: state.build)),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the gallery screen opens on its first sections', (tester) async {
    await tester.pumpWidget(
      const AuraTestApp(reduceMotion: true, child: AuraGalleryScreen()),
    );
    expect(find.text('State Gallery'), findsOneWidget);
    expect(find.text('Money'), findsOneWidget);
  });
}
