import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// Marks content that sits on a sheet (`raised`) instead of on `bg`. Inside
/// one, filled shapes lift a step so nothing vanishes into the sheet: banners,
/// search, the slider track and disabled buttons use `raised2`, and hairlines
/// use `lineStrong` (design/DESIGN.md → Color). `AuraSheet` provides it.
class AuraSheetScope extends InheritedWidget {
  const AuraSheetScope({super.key, required super.child});

  static bool contains(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuraSheetScope>() != null;

  /// The fill for a shape one step above the ground it sits on.
  static Color raised(BuildContext context) =>
      contains(context) ? AuraColors.raised2 : AuraColors.raised;

  /// The hairline color for the ground it sits on.
  static Color line(BuildContext context) =>
      contains(context) ? AuraColors.lineStrong : AuraColors.line;

  @override
  bool updateShouldNotify(AuraSheetScope oldWidget) => false;
}
