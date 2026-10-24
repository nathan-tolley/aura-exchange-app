import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// Whether the interface sans is the platform's own (SF Pro on iOS). On web,
/// desktop and in tests the bundled Inter stands in, so previews and goldens
/// match the references (design/DESIGN.md → Fonts).
bool get auraUsesSystemSans =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// The text style every Aura widget starts from: the app's `body` style with
/// the right sans for the platform. The app installs it as the default text
/// style, so `AuraType` styles (whose sans family is null) inherit it, and no
/// Cupertino default (such as its letter-spacing) leaks in.
TextStyle auraBaseTextStyle({bool? systemSans}) {
  final system = systemSans ?? auraUsesSystemSans;
  return AuraType.body.copyWith(
    fontFamily: system ? null : 'Inter',
    letterSpacing: 0,
    decoration: TextDecoration.none,
  );
}
