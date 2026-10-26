import 'package:flutter/widgets.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_empty_state.dart';
import '../../design/widgets/aura_search_field.dart';
import '../../design/widgets/aura_section_header.dart';
import '../../design/widgets/aura_skeleton.dart';
import '../../design/widgets/aura_stock_row.dart';
import '../../design/widgets/aura_tab_bar.dart';
import '../../design/widgets/aura_tape.dart';
import '../shared/banner_model.dart';
import 'market_model.dart';

/// The Market tab (SCREENS.md #6): the tape, search, the one banner the
/// market needs, and every listing by today's change. Laid out like Home
/// (W09–W12), whose top it shares. [model] is null while the first numbers
/// load.
class MarketView extends StatelessWidget {
  const MarketView({
    super.key,
    required this.model,
    this.search,
    this.onSearch,
    this.onRetry,
    this.onRow,
    this.onTab,
  });

  final MarketListModel? model;
  final TextEditingController? search;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onRetry;
  final ValueChanged<String>? onRow;
  final ValueChanged<AuraTab>? onTab;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final m = model;
    return ColoredBox(
      color: AuraColors.bg,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16, top, 16, 128),
            children: [
              if (m == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 9),
                  child: AuraSkeleton(height: 8, width: 240, radius: 3),
                )
              else
                AuraTape(items: m.tape),
              const SizedBox(height: 12),
              AuraSearchField(
                controller: search,
                onChanged: onSearch,
                enabled: m != null,
              ),
              if (m?.banner case final banner?) ...[
                const SizedBox(height: 16),
                ModelBanner(banner, onAction: onRetry),
              ],
              const SizedBox(height: 20),
              if (m == null) ...[
                const AuraSkeleton(width: 80, height: 11),
                const SizedBox(height: 8),
                for (var i = 0; i < 6; i++) const _RowSkeleton(),
              ] else ...[
                AuraSectionHeader(
                  m.heading,
                  status: m.status,
                  statusLabel: m.statusLabel,
                ),
                if (m.empty case (final title, final body))
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: AuraEmptyState(
                      icon: AuraIcons.search,
                      title: title,
                      body: body,
                    ),
                  ),
                for (final row in m.rows)
                  AuraStockRow(
                    ticker: row.ticker,
                    name: row.name,
                    initial: row.name.characters.first,
                    tag: row.tag,
                    tagTone: row.tagTone,
                    price: row.price,
                    abs: row.abs,
                    pct: row.pct,
                    points: row.points,
                    onTap: onRow == null ? null : () => onRow!(row.id),
                  ),
              ],
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Center(
              child: AuraTabBar(active: AuraTab.market, onSelect: onTab),
            ),
          ),
        ],
      ),
    );
  }
}

/// One 64 pt row while loading.
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
