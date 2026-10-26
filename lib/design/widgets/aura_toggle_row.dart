import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../surface.dart';
import '../text.dart';
import '../tokens.dart';
import 'aura_pressable.dart';

/// A setting that's on or off: a title, what it does, and a switch, on a
/// hairline like every row. The switch is `ink` when on and `raised2` when
/// off; it never takes up/down color (rule 3). Disabled says why in its
/// subtitle.
class AuraToggleRow extends StatelessWidget {
  const AuraToggleRow({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.onChanged,
  });

  final String title;

  /// What it does, or why it can't be changed.
  final String? subtitle;
  final bool value;

  /// Null disables it.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final subtitle = this.subtitle;
    void toggle() {
      HapticFeedback.lightImpact();
      onChanged!(!value);
    }

    return Semantics(
      toggled: value,
      enabled: enabled,
      label: [title, ?subtitle].join(', '),
      onTap: enabled ? toggle : null,
      excludeSemantics: true,
      child: AuraPressable(
        onTap: enabled ? toggle : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: AuraSize.row),
          padding: const EdgeInsets.symmetric(vertical: 10),
          foregroundDecoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AuraSheetScope.line(context)),
            ),
          ),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Text(
                      title,
                      style: AuraType.rowTitle.copyWith(
                        fontWeight: FontWeight.w500,
                        color: enabled
                            ? AuraColors.ink
                            : AuraColors.inkTertiary,
                      ),
                    ),
                    if (subtitle != null)
                      auraLiftFootnote(
                        Text(
                          subtitle,
                          style: AuraType.footnote.copyWith(
                            color: AuraColors.inkTertiary,
                            fontFeatures: const [],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _Switch(on: value, enabled: enabled),
            ],
          ),
        ),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({required this.on, required this.enabled});

  final bool on;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final track = on && enabled
        ? AuraColors.ink
        : AuraSheetScope.raised(context);
    final knob = on && enabled
        ? AuraColors.bg
        : enabled
        ? AuraColors.inkSecondary
        : AuraColors.inkFaint;
    return AnimatedContainer(
      duration: still ? Duration.zero : const Duration(milliseconds: 160),
      width: 48,
      height: 28,
      padding: const EdgeInsets.all(3),
      decoration: ShapeDecoration(
        color: on && enabled ? track : AuraColors.raised2,
        shape: const StadiumBorder(),
      ),
      child: AnimatedAlign(
        duration: still ? Duration.zero : const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: knob, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
