import 'package:flutter/widgets.dart';

import '../icons.dart';
import '../surface.dart';
import '../tokens.dart';

/// Where a photo tile's upload stands.
enum AuraPhotoStatus { ready, uploading, failed }

/// One photo a filing carries as a receipt, or the slot that adds one: a
/// 64 pt square with `md` corners.
///
/// - A photo fills it. While it uploads it's dimmed, with a 3 pt bar along
///   the bottom showing how much has been sent. If it failed, it's dimmed
///   under an `alert` glyph in `down`; the note under the row says what
///   happened, and tapping the tile tries again.
/// - Remove is a `close` glyph on a `bg` disc in the top right, with a
///   44 pt hit area.
/// - The add slot ([AuraPhotoTile.add]) is the field's `raised` fill with a
///   `plus` glyph, like `AuraTextField` above it.
class AuraPhotoTile extends StatelessWidget {
  const AuraPhotoTile({
    super.key,
    required Widget this.image,
    required this.label,
    this.status = AuraPhotoStatus.ready,
    this.progress = 0,
    this.onTap,
    this.onRemove,
    this.removeLabel,
  });

  /// The slot that adds a photo; [label] is what VoiceOver says
  /// ("Add a receipt"). Null [onTap] hides nothing: the caller leaves the
  /// slot out when no more can be added.
  const AuraPhotoTile.add({super.key, required this.label, this.onTap})
    : image = null,
      status = AuraPhotoStatus.ready,
      progress = 0,
      onRemove = null,
      removeLabel = null;

  static const size = 64.0;

  /// The photo, cropped to fill (`Image.memory(…, fit: BoxFit.cover)`);
  /// null for the add slot.
  final Widget? image;

  /// "Receipt 1": VoiceOver's name for the tile, with its status added.
  final String label;
  final AuraPhotoStatus status;

  /// While uploading, the share sent, 0 to 1.
  final double progress;

  /// Tapping the tile: add for the slot, try again when it failed.
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  /// "Remove receipt 1".
  final String? removeLabel;

  @override
  Widget build(BuildContext context) {
    final image = this.image;
    final radius = BorderRadius.circular(AuraRadius.md);
    if (image == null) {
      return Semantics(
        button: true,
        label: label,
        onTap: onTap,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AuraSheetScope.raised(context),
              borderRadius: radius,
            ),
            alignment: Alignment.center,
            child: AuraIcon(
              AuraIcons.plus,
              size: 22,
              color: onTap == null
                  ? AuraColors.inkFaint
                  : AuraColors.inkSecondary,
            ),
          ),
        ),
      );
    }
    final dimmed = status != AuraPhotoStatus.ready;
    final remove = onRemove;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Semantics(
            label: label,
            button: onTap != null,
            onTap: onTap,
            image: true,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: ClipRRect(
                borderRadius: radius,
                child: ColoredBox(
                  color: AuraSheetScope.raised(context),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(opacity: dimmed ? 0.4 : 1, child: image),
                      if (status == AuraPhotoStatus.failed)
                        const Center(
                          child: AuraIcon(
                            AuraIcons.alert,
                            size: 20,
                            color: AuraColors.down,
                          ),
                        ),
                      if (status == AuraPhotoStatus.uploading)
                        Positioned(
                          left: 8,
                          right: 8,
                          bottom: 8,
                          child: _Progress(progress.clamp(0, 1).toDouble()),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (remove != null)
            Positioned(
              top: 0,
              right: 0,
              child: Semantics(
                button: true,
                label: removeLabel,
                onTap: remove,
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: remove,
                  behavior: HitTestBehavior.opaque,
                  // 44 pt to touch, inside the tile so all of it hits; the
                  // disc sits 4 pt in from the corner.
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, right: 4),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AuraColors.bg,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const AuraIcon(
                            AuraIcons.close,
                            size: 12,
                            color: AuraColors.ink,
                            weight: 2.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The upload's progress: an `ink` bar on a `lineStrong` track.
class _Progress extends StatelessWidget {
  const _Progress(this.value);

  final double value;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(1.5),
    child: SizedBox(
      height: 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: AuraColors.lineStrong),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: const ColoredBox(color: AuraColors.ink),
          ),
        ],
      ),
    ),
  );
}
