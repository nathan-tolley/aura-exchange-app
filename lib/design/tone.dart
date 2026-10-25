import 'dart:ui';

import 'tokens.dart';

/// What a colored piece of text means. Color is information (design/DESIGN.md
/// rule 3): `up` and `down` are direction, `warn` is time or risk, and
/// everything else is neutral and takes the component's own color.
enum AuraTone {
  neutral,
  up,
  down,
  warn;

  /// The color for this tone, or [neutral] when the tone is neutral.
  Color colorOr(Color neutral) => switch (this) {
    AuraTone.neutral => neutral,
    AuraTone.up => AuraColors.up,
    AuraTone.down => AuraColors.down,
    AuraTone.warn => AuraColors.warn,
  };
}
