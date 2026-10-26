import '../../api/generated/export.dart' hide Freshness;
import '../../data/live_market.dart';
import '../../design/tone.dart';
import '../../l10n/strings.dart';

/// The one tag after a name in a row (COMPONENTS.md → Tag), the strongest
/// first: Halted > Ruled (a ruling waiting for the open, W09) > Rumor >
/// You > Short > Holding. SEC comes first once Phase 2 sends it. Only Halted
/// and Ruled color, in `warn`.
(String?, AuraTone) listingTag(LiveListing listing) {
  final s = listing.summary;
  return switch (s) {
    _ when listing.state == ListingState.halted => (tagHalted, AuraTone.warn),
    _ when listing.state == ListingState.delisted => (
      tagDelisted,
      AuraTone.neutral,
    ),
    _ when s.badges.contains(Badge.queuedForOpen) => (tagRuled, AuraTone.warn),
    _ when s.badges.contains(Badge.rumorPending) => (
      tagRumor,
      AuraTone.neutral,
    ),
    _ when s.isMine => (tagYou, AuraTone.neutral),
    ListingSummary(myPosition: MyPosition(side: PositionSide.short)) => (
      tagShort,
      AuraTone.neutral,
    ),
    ListingSummary(myPosition: MyPosition(side: PositionSide.long)) => (
      tagHolding,
      AuraTone.neutral,
    ),
    _ => (null, AuraTone.neutral),
  };
}
