import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/client.dart';
import '../../api/errors.dart';
import '../../api/generated/export.dart' hide Freshness;
import '../../data/inbox_data.dart';
import '../../data/listing_data.dart';
import '../../data/live_market.dart';
import '../../data/me.dart';
import '../../data/repositories.dart';
import '../../design/sheet_route.dart';
import '../../design/widgets/aura_banner.dart';
import '../../design/widgets/aura_tab_bar.dart';
import '../../l10n/strings.dart';
import '../../router.dart';
import '../shared/banner_model.dart';
import '../system/load_failure.dart';
import 'you_view.dart';

/// The You tab, live: you, your membership, and your listing with the
/// exchange's ticks on its price.
class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onTab(AuraTab tab) => goTab(context, tab);
    final me = ref.watch(meProvider).value;
    final membership = ref.watch(currentMembershipProvider);
    if (me == null || membership == null) {
      return YouView(model: null, onTab: onTab);
    }
    final listingId = membership.listing?.id;
    final detail = listingId == null
        ? null
        : ref.watch(listingProvider(listingId));
    if (detail != null && detail.value == null) {
      final failure = firstFailure([detail]);
      if (failure != null) {
        return LoadFailureView(
          error: failure,
          onRetry: () => ref.invalidate(listingProvider(listingId!)),
        );
      }
      return YouView(model: null, onTab: onTab);
    }
    final market = ref.watch(marketProvider(membership.exchangeId)).value;
    return YouView(
      model: youModel(
        user: me.user,
        membership: membership,
        listing: detail?.value,
        live: market?.listings.where((l) => l.id == listingId).firstOrNull,
      ),
      onStock: listingId == null
          ? null
          : () => context.push(Routes.stock(listingId)),
      onInvite: () => context.push(Routes.createInvite),
      onSettings: () => context.push(Routes.settings),
      onList: () => context.push(Routes.ipo),
      onTab: onTab,
    );
  }
}

/// Settings (`/settings`), live. A change shows at once and is saved with
/// its own key; if it doesn't save, it goes back and says so.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// What's on screen while a change is saving.
  NotificationPrefs? _shown;
  bool _failed = false;

  Future<void> _save(NotificationPrefs before, NotificationPrefs after) async {
    setState(() {
      _shown = after;
      _failed = false;
    });
    try {
      final saved = await ref
          .read(meRepositoryProvider)
          .setPrefs(after, IdempotencyKey());
      if (mounted) setState(() => _shown = saved);
    } on ApiError {
      if (mounted) {
        setState(() {
          _shown = before;
          _failed = true;
        });
      }
    }
  }

  NotificationPrefs _with(
    NotificationPrefs p, {
    List<String>? disabledTypes,
    bool? bells,
    QuietHours? Function()? quietHours,
  }) => NotificationPrefs(
    holdingMovedPct: p.holdingMovedPct,
    quietHours: quietHours == null ? p.quietHours : quietHours(),
    bells: bells ?? p.bells,
    disabledTypes: disabledTypes ?? p.disabledTypes,
  );

  Future<void> _optOut(String exchangeId, String exchangeName) async {
    final key = IdempotencyKey();
    await Navigator.of(context).push(
      AuraSheetRoute<void>(
        builder: (sheet) => DelistSheet(
          exchange: exchangeName,
          onStay: () => Navigator.of(sheet).pop(),
          onConfirmed: () async {
            try {
              await ref
                  .read(exchangesRepositoryProvider)
                  .delist(exchangeId, key);
              await ref.read(meProvider.notifier).reload();
            } on ApiError {
              if (mounted) setState(() => _failed = true);
            }
            if (sheet.mounted) Navigator.of(sheet).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _shown ?? ref.watch(notificationPrefsProvider).value;
    final me = ref.watch(meProvider).value;
    final membership = ref.watch(currentMembershipProvider);
    final exchangeId = membership?.exchangeId;
    final exchangeName = exchangeId == null
        ? ''
        : ref.watch(exchangeProvider(exchangeId)).value?.name ?? '';
    void back() => context.canPop() ? context.pop() : context.go(Routes.you);
    final p = prefs;
    return SettingsView(
      prefs: p,
      email: me?.user.email ?? '',
      listed: membership?.listing != null,
      banner: _failed
          ? const BannerModel(tone: AuraBannerTone.down, title: savingFailed)
          : null,
      onBack: back,
      onType: p == null
          ? null
          : (type, on) {
              final off = {...?p.disabledTypes};
              on ? off.remove(type) : off.add(type);
              _save(p, _with(p, disabledTypes: off.toList()));
            },
      onBells: p == null ? null : (on) => _save(p, _with(p, bells: on)),
      onQuiet: p == null
          ? null
          : (on) => _save(
              p,
              _with(
                p,
                // The usual night, until it's adjustable here.
                quietHours: () =>
                    on ? const QuietHours(start: '22:00', end: '07:00') : null,
              ),
            ),
      onOptOut: exchangeId == null
          ? null
          : () => _optOut(exchangeId, exchangeName),
      onSignOut: () =>
          ref.read(authRepositoryProvider).signOut(IdempotencyKey()),
    );
  }
}
