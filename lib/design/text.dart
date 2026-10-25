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

/// The references draw 12.5 pt text (footnotes, tags, chips, row and nav
/// subtitles, stat labels) 2 pt higher than its line box puts it, and every
/// drawn screen agrees (docs/aura/NOTES.md, 2026-10-25). Wrap 12.5 pt text
/// in this to match: the ink moves up, the layout doesn't.
Widget auraLiftFootnote(Widget text) =>
    Transform.translate(offset: const Offset(0, -2), child: text);

/// A large sans title for this platform: [AuraType.largeTitle] (25 pt, W08)
/// or [AuraType.alertTitle] (30 pt, W13). On iOS it's SF Pro Display, as
/// tokened. Elsewhere Inter stands in, and at these sizes Inter runs 10–15%
/// wider than SF Pro Display (W08's title would wrap), so it uses its display
/// optical size and 0.01em more tracking to take SF Pro Display's width.
TextStyle auraDisplayTitle(TextStyle style, {bool? systemSans}) {
  if (systemSans ?? auraUsesSystemSans) return style;
  return style.copyWith(
    fontVariations: const [FontVariation('opsz', 32)],
    letterSpacing: (style.letterSpacing ?? 0) - (style.fontSize ?? 0) * 0.01,
  );
}

/// [AuraType.largeTitle] for this platform (see [auraDisplayTitle]).
TextStyle auraLargeTitle({bool? systemSans}) =>
    auraDisplayTitle(AuraType.largeTitle, systemSans: systemSans);
