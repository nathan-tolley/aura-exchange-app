import 'package:flutter/widgets.dart';

import '../../design/tokens.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_section_header.dart';
import '../../design/widgets/aura_skeleton.dart';
import '../../design/widgets/aura_stock_row.dart';
import '../../l10n/strings.dart';
import 'join_model.dart';
import 'onboarding_scaffold.dart';

/// Join an exchange (SCREENS.md #2): who's in it and who's listed, before
/// you join; or why the invite can't be used, and the way out.
class JoinView extends StatelessWidget {
  const JoinView({super.key, required this.model, this.onAction, this.onRetry});

  final JoinModel model;

  /// Join, start your own, or open your exchange ([JoinModel.kind]).
  final VoidCallback? onAction;

  /// The banner's Retry: the preview again, or the join again.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final loading = m.kind == JoinKind.loading && m.banner == null;
    return OnboardingScaffold(
      title: m.title,
      body: m.body,
      banner: m.banner,
      onBannerAction: onRetry,
      actions: [
        AuraButton(
          m.action,
          variant: AuraButtonVariant.primary,
          block: true,
          onPressed: m.canAct ? onAction : null,
        ),
      ],
      note: m.note,
      children: [
        if (loading) ...[
          const AuraSkeletonText(style: AuraType.body, lines: 2),
          const SizedBox(height: 28),
          for (var i = 0; i < 3; i++)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Row(
                spacing: 12,
                children: [
                  AuraSkeleton(
                    width: AuraSize.avatar,
                    height: AuraSize.avatar,
                    radius: AuraRadius.full,
                  ),
                  AuraSkeleton(width: 120, height: 12),
                ],
              ),
            ),
        ] else if (m.kind == JoinKind.join) ...[
          const AuraSectionHeader(listedHeading),
          if (m.listed.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                nobodyListedYet,
                style: AuraType.body.copyWith(color: AuraColors.inkSecondary),
              ),
            )
          else
            for (final (ticker, name) in m.listed)
              AuraStockRow(ticker: ticker, name: name),
        ],
      ],
    );
  }
}
