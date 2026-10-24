// GENERATED from design/tokens.json (Aura Exchange · Graphite). Do not edit by hand;
// change tokens.json and regenerate (see design/DESIGN.md → Tokens).
import 'package:flutter/widgets.dart';

/// Colors. `up`, `down` and `warn` are information, never decoration (DESIGN.md rule 3).
abstract final class AuraColors {
  /// The one background. Every screen sits on it flat: no gradients, glows or vignettes anywhere.
  static const Color bg = Color(0xFF0B0C0E);
  /// One step up: the search field, banners, sheets, the trade slider track, round action buttons.
  static const Color raised = Color(0xFF161719);
  /// Two steps up: secondary buttons, the selected segment, avatar monograms, tooltips, toasts, the tab bar's material.
  static const Color raised2 = Color(0xFF202225);
  /// Hairlines between rows and above spec-sheet stats, on bg only. Structure comes from these, not from boxes.
  static const Color line = Color(0xFF1D1F22);
  /// The tab bar's edge, the sheet grabber, range-bar tracks, ghost button outlines.
  static const Color lineStrong = Color(0xFF2A2D30);
  /// Primary text and icons; the fill of primary and Buy buttons. 17.6:1 on bg, 14.4:1 on raised-2.
  static const Color ink = Color(0xFFF2F3F5);
  /// Body copy, the Analyst's notes, button labels under icons. 9.8:1 on bg, 8:1 on raised-2.
  static const Color inkSecondary = Color(0xFFB4B8BC);
  /// Labels, subtitles, timestamps, cents and the A$ sign on big numbers, inactive tabs. 5.8:1 on bg, 4.8:1 on raised-2.
  static const Color inkTertiary = Color(0xFF888D92);
  /// Non-text marks only: dotted previous-close lines, chevrons, disabled labels (exempt from contrast rules). 2.6:1 on bg.
  static const Color inkFaint = Color(0xFF52565B);
  /// Price up, gains, BEAT, a Buy rating. Only on numbers, chart lines and the slide-to-buy knob, always with an arrow or sign. 10:1 on bg.
  static const Color up = Color(0xFF58CE96);
  /// Price down, losses, LOSS rulings, liquidation, SEC. Only on numbers, chart lines and glyphs, always with an arrow or sign. 6.8:1 on bg, 5.5:1 on raised-2.
  static const Color down = Color(0xFFEF736C);
  /// Time and risk: margin warnings, halts, expiring quotes, extended hours. On numbers, countdown digits and banner glyphs. 10.7:1 on bg.
  static const Color warn = Color(0xFFEDB65C);
  /// Glyphs on an up or down fill (the slide knob). 9.9:1 on up.
  static const Color onUp = Color(0xFF0A0E12);
  /// Text on an ink fill: primary and Buy button labels. 17.6:1.
  static const Color onInk = Color(0xFF0B0C0E);
}

/// 4pt spacing scale. 16 is the screen gutter.
abstract final class AuraSpace {
  static const double s1 = 4.0; // Between a number and its change line.
  static const double s2 = 8.0; // Inside chips and between label and value.
  static const double s3 = 12.0; // Avatar to text; banner padding.
  static const double s4 = 16.0; // Screen gutter; gap between blocks.
  static const double s5 = 20.0; // Before a section heading.
  static const double s6 = 24.0; // Between major groups (hero, then actions, then lists).
  static const double s8 = 32.0; // Clearance under floating controls.
  static const double gutter = 16.0;
}

abstract final class AuraRadius {
  static const double sm = 8.0; // Selected segment, tooltips.
  static const double md = 12.0; // Search field, banners, toasts, empty-state tile.
  static const double sheet = 16.0; // Top corners of bottom sheets.
  static const double full = 9999.0; // Buttons, the tab bar, avatars, the slider.
}

abstract final class AuraSize {
  static const double hit = 44.0; // Minimum tap target, even for bare glyphs.
  static const double avatar = 36.0; // Avatars in rows; 40 in headers.
  static const double action = 52.0; // Round action buttons.
  static const double buttonLg = 54.0; // Large buttons.
  static const double tabbar = 56.0; // The floating tab bar.
  static const double row = 64.0; // List rows.
}

/// Font families. `sans`/`display` are null on purpose: Flutter then uses San Francisco on iOS.
/// The serif (the Analyst's voice) and the mono (tape, countdowns) are bundled assets.
abstract final class AuraFonts {
  static const String? sans = null; // SF Pro Text on iOS
  static const String? display = null; // SF Pro Display on iOS (Flutter picks Display at ≥20pt)
  static const String serif = 'Newsreader'; // assets/fonts/Newsreader-*.ttf (OFL)
  static const String mono = 'JetBrainsMono'; // assets/fonts/JetBrainsMono-*.ttf (OFL)
  static const List<String> fallback = ['Inter', 'Roboto']; // web/desktop preview only
}

/// Type styles. Tabular figures everywhere. Scale with MediaQuery.textScaler (Dynamic Type).
abstract final class AuraType {
  static const _tabular = [FontFeature.tabularFigures()];
  // Numbers: SF Pro Display on iPhone. Big numbers are light, not bold: the size does the work. Tabular figures always.
  /// One per screen: net worth, a ruling's landing price, a fine. A$ and cents in ink-tertiary. Sample: A$12,486.20
  static const TextStyle display = TextStyle(fontFamily: AuraFonts.display, fontFamilyFallback: AuraFonts.fallback, fontSize: 44.0, height: 1.0909, fontWeight: FontWeight.w400, letterSpacing: -1.32, color: AuraColors.ink, fontFeatures: _tabular);
  /// The price in a stock header. Sample: A$124.10
  static const TextStyle price = TextStyle(fontFamily: AuraFonts.display, fontFamilyFallback: AuraFonts.fallback, fontSize: 24.0, height: 1.1667, fontWeight: FontWeight.w400, letterSpacing: -0.36, color: AuraColors.ink, fontFeatures: _tabular);
  /// A ruling's impact score, in up or down. Sample: −18
  static const TextStyle impact = TextStyle(fontFamily: AuraFonts.display, fontFamilyFallback: AuraFonts.fallback, fontSize: 32.0, height: 1.0625, fontWeight: FontWeight.w400, letterSpacing: -0.64, color: AuraColors.ink, fontFeatures: _tabular);
  // Analyst: Apple's New York on iPhone (Newsreader stands in on the web). Only the Analyst speaks in the serif: headlines, notes, Fed statements, company profiles.
  /// A headline that is the point of the screen. Sample: Jake indicated sharply lower after overnight “who is this” incident
  static const TextStyle headline = TextStyle(fontFamily: AuraFonts.serif, fontFamilyFallback: AuraFonts.fallback, fontSize: 25.0, height: 1.24, fontWeight: FontWeight.w400, letterSpacing: -0.25, color: AuraColors.ink, fontFeatures: _tabular);
  /// Analyst notes, in ink-secondary, never boxed. Sample: “We are moving to Underweight.”
  static const TextStyle quote = TextStyle(fontFamily: AuraFonts.serif, fontFamilyFallback: AuraFonts.fallback, fontSize: 17.0, height: 1.4706, fontWeight: FontWeight.w400, color: AuraColors.ink, fontFeatures: _tabular);
  // Interface: SF Pro Text. Hierarchy comes from size and color, rarely from weight.
  /// Stock headers and sheet titles. Sample: $ANNA
  static const TextStyle title = TextStyle(fontFamily: AuraFonts.sans, fontFamilyFallback: AuraFonts.fallback, fontSize: 17.0, height: 1.2941, fontWeight: FontWeight.w600, color: AuraColors.ink, fontFeatures: _tabular);
  /// Section headings. Small and confident, never 20pt+. Sample: Watchlist
  static const TextStyle heading = TextStyle(fontFamily: AuraFonts.sans, fontFamilyFallback: AuraFonts.fallback, fontSize: 15.0, height: 1.3333, fontWeight: FontWeight.w600, color: AuraColors.ink, fontFeatures: _tabular);
  /// Tickers and list titles. Sample: $JAKE
  static const TextStyle rowTitle = TextStyle(fontFamily: AuraFonts.sans, fontFamilyFallback: AuraFonts.fallback, fontSize: 15.0, height: 1.3333, fontWeight: FontWeight.w600, color: AuraColors.ink, fontFeatures: _tabular);
  /// Body text and inputs. Sample: Runs on the tape next to the story
  static const TextStyle body = TextStyle(fontFamily: AuraFonts.sans, fontFamilyFallback: AuraFonts.fallback, fontSize: 15.0, height: 1.3333, fontWeight: FontWeight.w400, color: AuraColors.ink, fontFeatures: _tabular);
  /// Spec-sheet values. Sample: A$124.1M
  static const TextStyle value = TextStyle(fontFamily: AuraFonts.sans, fontFamilyFallback: AuraFonts.fallback, fontSize: 16.0, height: 1.3125, fontWeight: FontWeight.w500, color: AuraColors.ink, fontFeatures: _tabular);
  /// Large buttons. Sample: Buy
  static const TextStyle button = TextStyle(fontFamily: AuraFonts.sans, fontFamilyFallback: AuraFonts.fallback, fontSize: 17.0, height: 1.2941, fontWeight: FontWeight.w600, color: AuraColors.ink, fontFeatures: _tabular);
  /// Labels, subtitles, metadata, change lines in rows. Sample: Anna · Listed Sep 2
  static const TextStyle footnote = TextStyle(fontFamily: AuraFonts.sans, fontFamilyFallback: AuraFonts.fallback, fontSize: 12.5, height: 1.28, fontWeight: FontWeight.w400, color: AuraColors.ink, fontFeatures: _tabular);
  /// Chart axes only. Sample: 07  10  13  16
  static const TextStyle caption = TextStyle(fontFamily: AuraFonts.sans, fontFamilyFallback: AuraFonts.fallback, fontSize: 11.0, height: 1.2727, fontWeight: FontWeight.w500, color: AuraColors.ink, fontFeatures: _tabular);
  // Tape: SF Mono for the ticker tape and countdown digits, so numbers don't jitter as they change.
  /// The ticker tape strip. Sample: $JAKE 101.90 ▼ 9.34%
  static const TextStyle tape = TextStyle(fontFamily: AuraFonts.mono, fontFamilyFallback: AuraFonts.fallback, fontSize: 11.0, height: 1.2727, fontWeight: FontWeight.w400, letterSpacing: 0.22, color: AuraColors.ink, fontFeatures: _tabular);
  /// Countdown digits. Sample: 6:42
  static const TextStyle countdown = TextStyle(fontFamily: AuraFonts.mono, fontFamilyFallback: AuraFonts.fallback, fontSize: 13.0, height: 1.2308, fontWeight: FontWeight.w500, color: AuraColors.ink, fontFeatures: _tabular);
}
