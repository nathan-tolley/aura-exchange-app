@Tags(['golden'])
library;

import 'package:aura_exchange/design/gallery/component_states.dart';
import 'package:aura_exchange/design/tokens.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

/// One golden per State Gallery section: every state of every component,
/// labelled, at 2×. The reference previews are in components_*_test.dart.
void main() {
  for (final section in componentStates) {
    testWidgets(section.name, (tester) async {
      await expectPreview(tester, 'gallery/${section.name}', height: null, [
        for (final state in section.states)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                state.label,
                style: AuraType.footnote.copyWith(
                  color: AuraColors.inkTertiary,
                ),
              ),
              Builder(builder: state.build),
            ],
          ),
      ]);
    });
  }
}
