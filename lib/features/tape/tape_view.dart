import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart' hide Notification;
import 'package:timezone/timezone.dart' as tz;

import '../../api/generated/export.dart' hide Freshness;
import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../design/widgets/aura_banner.dart';
import '../../design/widgets/aura_button.dart';
import '../../design/widgets/aura_empty_state.dart';
import '../../design/widgets/aura_news_row.dart';
import '../../design/widgets/aura_section_header.dart';
import '../../design/widgets/aura_segmented_control.dart';
import '../../design/widgets/aura_skeleton.dart';
import '../../design/widgets/aura_tab_bar.dart';
import '../../format/ticker.dart';
import '../../format/time.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';
import '../shared/top_bar.dart';

/// One row of the tape or the inbox, worded.
@immutable
class NewsRowModel {
  const NewsRowModel({
    required this.source,
    required this.headline,
    this.movePct,
    this.unread = false,
    this.link,
  });

  final String source;
  final String headline;
  final Decimal? movePct;
  final bool unread;

  /// Where a tap goes: an event, or a notification's deep link.
  final String? link;
}

/// The tape's rows: newer than [seen] are unread.
List<NewsRowModel> tapeRows(
  List<TapeItem> items, {
  required DateTime? seen,
  required tz.Location zone,
  required DateTime now,
}) => [
  for (final t in items)
    NewsRowModel(
      source: [
        ?t.listing == null ? null : formatTicker(t.listing!.ticker),
        tapeTypeWord(t.type),
        formatWhen(t.at, zone, now: now),
      ].join(' · '),
      headline: t.headline,
      movePct: t.priceMovePct == null ? null : Decimal.parse(t.priceMovePct!),
      unread: seen != null && t.at.isAfter(seen),
      link: t.eventId == null ? null : '/events/${t.eventId}',
    ),
];

/// The Tape tab (SCREENS.md #18): every ruling, rumor, halt and big trade,
/// newest first, filtered by kind, with what's new since you last looked
/// dotted. [rows] null is loading.
class TapeView extends StatelessWidget {
  const TapeView({
    super.key,
    required this.rows,
    required this.filter,
    this.notLive = false,
    this.hasMore = false,
    this.onFilter,
    this.onRow,
    this.onMore,
    this.onFile,
    this.onTab,
  });

  final List<NewsRowModel>? rows;

  /// One of [tapeFilters]' keys.
  final String filter;

  /// The exchange doesn't serve the tape yet: a calm note in place of the
  /// filter and rows, with the tab bar still there.
  final bool notLive;
  final bool hasMore;
  final ValueChanged<String>? onFilter;
  final ValueChanged<NewsRowModel>? onRow;
  final VoidCallback? onMore;
  final VoidCallback? onFile;
  final ValueChanged<AuraTab>? onTab;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final rows = this.rows;
    return ColoredBox(
      color: AuraColors.bg,
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16, top + 12, 16, 128),
            children: [
              if (notLive)
                const Padding(
                  padding: EdgeInsets.only(top: 88),
                  child: AuraEmptyState(
                    icon: AuraIcons.clock,
                    title: tapeNotLiveTitle,
                    body: tapeNotLiveBody,
                  ),
                )
              else ...[
                AuraSegmentedControl(
                  options: tapeFilters.keys.toList(),
                  value: filter,
                  label: tapeFilterLabel,
                  onChanged: onFilter,
                ),
                const SizedBox(height: 8),
                if (rows == null)
                  for (var i = 0; i < 5; i++)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          AuraSkeleton(width: 150, height: 9),
                          AuraSkeleton(height: 14),
                          AuraSkeleton(width: 220, height: 14),
                        ],
                      ),
                    )
                else if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: filter == tapeFilterAll
                        ? AuraEmptyState(
                            icon: AuraIcons.tape,
                            title: nothingOnTapeYet,
                            body: tapeEmptyBody,
                            action: fileAnEvent,
                            onAction: onFile,
                          )
                        : const AuraEmptyState(
                            icon: AuraIcons.filter,
                            title: tapeFilteredEmptyTitle,
                            body: tapeFilteredEmptyBody,
                          ),
                  )
                else ...[
                  for (final r in rows)
                    AuraNewsRow(
                      source: r.source,
                      headline: r.headline,
                      movePct: r.movePct,
                      unread: r.unread,
                      onTap: r.link == null || onRow == null
                          ? null
                          : () => onRow!(r),
                    ),
                  if (hasMore) ...[
                    const SizedBox(height: 16),
                    AuraButton(
                      showOlder,
                      variant: AuraButtonVariant.ghost,
                      size: AuraButtonSize.md,
                      block: true,
                      onPressed: onMore,
                    ),
                  ],
                ],
              ],
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Center(
              child: AuraTabBar(active: AuraTab.tape, onSelect: onTab),
            ),
          ),
        ],
      ),
    );
  }
}

/// The notifications inbox, worded: grouped by stock, newest group first.
@immutable
class InboxModel {
  const InboxModel({required this.groups, this.banner});

  /// (heading, rows): "$JAKE", or "The exchange" for bells.
  final List<(String, List<NewsRowModel>)> groups;

  /// Quiet hours on.
  final BannerModel? banner;
}

InboxModel inboxModel(
  List<Notification> items, {
  required Map<String, String> tickers,
  required QuietHours? quiet,
  required tz.Location zone,
  required DateTime now,
}) {
  final groups = <String, List<NewsRowModel>>{};
  for (final n in items) {
    final heading = tickers[n.listingId] ?? theExchange;
    (groups[heading] ??= []).add(
      NewsRowModel(
        source: formatWhen(n.at, zone, now: now),
        headline: n.title,
        unread: n.readAt == null,
        link: n.deepLink,
      ),
    );
  }
  return InboxModel(
    groups: [for (final e in groups.entries) (e.key, e.value)],
    banner: quiet != null && _inQuietHours(quiet, zone, now)
        ? BannerModel(
            tone: AuraBannerTone.neutral,
            title: quietHoursUntil(formatWallClock(quiet.end)),
            body: quietHoursBody,
          )
        : null,
  );
}

/// Whether the exchange's clock is inside [quiet], which can run past
/// midnight ("22:00" to "07:00").
bool _inQuietHours(QuietHours quiet, tz.Location zone, DateTime now) {
  int minutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  final t = exchangeTime(now, zone);
  final m = t.hour * 60 + t.minute;
  final start = minutes(quiet.start);
  final end = minutes(quiet.end);
  return start <= end ? m >= start && m < end : m >= start || m < end;
}

/// The notifications inbox (SCREENS.md #19), behind Home's bell. [model]
/// null is loading.
class InboxView extends StatelessWidget {
  const InboxView({
    super.key,
    required this.model,
    this.notLive = false,
    this.onBack,
    this.onRow,
  });

  final InboxModel? model;

  /// The exchange doesn't serve notifications yet.
  final bool notLive;
  final VoidCallback? onBack;
  final ValueChanged<NewsRowModel>? onRow;

  @override
  Widget build(BuildContext context) {
    final m = model;
    final top = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: AuraColors.bg,
      child: ListView(
        padding: EdgeInsets.only(top: top, bottom: 64),
        children: [
          TopBar(onPressed: onBack),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(notificationsTitle, style: AuraType.title),
                if (m?.banner case final banner?) ...[
                  const SizedBox(height: 16),
                  ModelBanner(banner),
                ],
                if (notLive)
                  const Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: AuraEmptyState(
                      icon: AuraIcons.clock,
                      title: inboxNotLiveTitle,
                      body: inboxNotLiveBody,
                    ),
                  )
                else if (m == null)
                  for (var i = 0; i < 4; i++)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: AuraSkeleton(height: 56),
                    )
                else if (m.groups.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: AuraEmptyState(
                      icon: AuraIcons.bell,
                      title: noNotifications,
                      body: noNotificationsBody,
                    ),
                  )
                else
                  for (final (heading, rows) in m.groups) ...[
                    const SizedBox(height: 24),
                    AuraSectionHeader(heading),
                    for (final r in rows)
                      AuraNewsRow(
                        source: r.source,
                        headline: r.headline,
                        unread: r.unread,
                        onTap: onRow == null ? null : () => onRow!(r),
                      ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
