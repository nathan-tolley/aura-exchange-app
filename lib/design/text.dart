import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// Whether the interface sans is the platform's own (SF Pro on iOS). On web,
/// desktop and in tests the bundled Inter stands in, so previews and goldens
/// match the references (design/DESIGN.md → Fonts).
bool get auraUsesSystemSans =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// Text inside a control (button and link labels, tabs, segments, nav rows)
/// has no tracking and proportional figures, as the references' `<button>`
/// elements do. Inter's tabular setting would also widen hyphens there.
TextStyle auraControlText(TextStyle style) =>
    style.copyWith(letterSpacing: 0, fontFeatures: const []);

/// The text style every Aura widget starts from: the app's `body` style with
/// the right sans for the platform. The app installs it as the default text
/// style, so `AuraType` styles (whose sans family is null) inherit it, and no
/// Cupertino default (such as its letter-spacing) leaks in.
TextStyle auraBaseTextStyle({bool? systemSans}) {
  final system = systemSans ?? auraUsesSystemSans;
  return AuraType.body.copyWith(
    fontFamily: system ? null : 'Inter',
    // The references set -0.005em on all text (about -0.075 at 15 pt); styles
    // with their own tracking (display, price, impact, headline) override it.
    letterSpacing: -0.075,
    // Extra line height splits evenly above and below, as in CSS.
    leadingDistribution: TextLeadingDistribution.even,
    decoration: TextDecoration.none,
  );
}
