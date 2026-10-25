import 'package:aura_exchange/design/gallery/component_states.dart';
import 'package:aura_exchange/design/gallery/gallery_screen.dart';
import 'package:aura_exchange/design/gallery/screen_states.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// Every state in the State Gallery builds, on its own, without errors or
/// overflow. A state that breaks fails here, not halfway down the gallery.
void main() {
  test('the gallery covers all 35 components', () {
    final names = componentStates.map((s) => s.name).toSet();
    expect(names, hasLength(35));
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

  for (final screen in screenStates) {
    testWidgets('screen ${screen.id}: ${screen.label}', (tester) async {
      tester.view.physicalSize = screenSize * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        AuraTestApp(reduceMotion: true, child: Builder(builder: screen.build)),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the gallery lists the screens and opens one', (tester) async {
    String? opened;
    await tester.pumpWidget(
      AuraTestApp(
        reduceMotion: true,
        child: AuraGalleryScreen(onOpenScreen: (id) => opened = id),
      ),
    );
    final first = screenStates.first;
    await tester.tap(find.text('${first.id} · ${first.label}'));
    expect(opened, first.id);
  });

  testWidgets('the gallery screen opens on its first sections', (tester) async {
    await tester.pumpWidget(
      const AuraTestApp(reduceMotion: true, child: AuraGalleryScreen()),
    );
    expect(find.text('State Gallery'), findsOneWidget);
    expect(find.text('Money'), findsOneWidget);
  });
}
