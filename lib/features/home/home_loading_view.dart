import 'package:flutter/widgets.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_icon_button.dart';
import '../../design/widgets/aura_skeleton.dart';
import '../../design/widgets/aura_tab_bar.dart';

/// Home while its first numbers load (SCREENS.md #5, loading): skeletons
/// where the tape, search, net worth, the two actions and the watchlist will
/// be, at their sizes and positions in `HomeView`. The bell and the tab bar
/// are real: they don't wait for prices.
class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key, this.onBell, this.onTab});

  final VoidCallback? onBell;
  final ValueChanged<AuraTab>? onTab;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Semantics(
      label: 'Loading your exchange',
      child: ColoredBox(
        color: AuraColors.bg,
        child: Stack(
          children: [
            ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, top, 6, 128),
              children: [
                // The tape's line of mono text, then its hairline.
                const Padding(
                  padding: EdgeInsets.only(right: 10, top: 9, bottom: 9),
                  child: AuraSkeleton(height: 8, width: 240, radius: 3),
                ),
                const SizedBox(height: 12),
                Row(
                  spacing: 6,
                  children: [
                    const Expanded(
                      child: AuraSkeleton(height: 40, radius: AuraRadius.md),
                    ),
                    AuraIconButton(
                      icon: AuraIcons.bell,
                      label: 'Notifications',
                      onPressed: onBell,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuraSkeleton(width: 120, height: 10),
                      SizedBox(height: 14),
                      AuraSkeleton(width: 230, height: 34),
                      SizedBox(height: 14),
                      AuraSkeleton(width: 170, height: 10),
                      SizedBox(height: 27),
                      Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: AuraSkeleton(
                              height: AuraSize.hit,
                              radius: AuraRadius.full,
                            ),
                          ),
                          Expanded(
                            child: AuraSkeleton(
                              height: AuraSize.hit,
                              radius: AuraRadius.full,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 28),
                      AuraSkeleton(width: 80, height: 11),
                      SizedBox(height: 8),
                      _RowSkeleton(),
                      _RowSkeleton(),
                      _RowSkeleton(),
                      _RowSkeleton(),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              child: Center(
                child: AuraTabBar(active: AuraTab.home, onSelect: onTab),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One 64 pt watchlist row: avatar, two lines, the price on the right.
class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: AuraSize.row,
      child: Row(
        spacing: 12,
        children: [
          AuraSkeleton(
            width: AuraSize.avatar,
            height: AuraSize.avatar,
            radius: AuraRadius.full,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                AuraSkeleton(width: 64, height: 11),
                AuraSkeleton(width: 96, height: 9),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 8,
            children: [
              AuraSkeleton(width: 72, height: 11),
              AuraSkeleton(width: 96, height: 9),
            ],
          ),
        ],
      ),
    );
  }
}
