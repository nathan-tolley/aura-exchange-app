import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/generated/export.dart';
import '../api/stream.dart';
import 'lifecycle.dart';
import 'live_market.dart';
import 'repositories.dart';

/// The exchange's tape for the Tape tab: the first page from REST with the
/// stream's `tape` messages on top, newest first. [types] filters it
/// (comma-separated `TapeItemType` values); null is everything.
final tapeProvider = AsyncNotifierProvider.autoDispose
    .family<TapeFeed, List<TapeItem>, (String, String?)>(TapeFeed.new);

class TapeFeed extends AsyncNotifier<List<TapeItem>> {
  TapeFeed(this.key);

  final (String, String?) key;
  String? _cursor;

  /// Whether there's an older page.
  bool get hasMore => _cursor != null;

  @override
  Future<List<TapeItem>> build() async {
    ref.watch(refetchSignalProvider);
    final (exchangeId, types) = key;
    final live = ref.watch(auraStreamProvider).messages.listen((m) {
      final shown = state.value;
      if (m is! TapeMessage || m.exchangeId != exchangeId || shown == null) {
        return;
      }
      if (types != null && !types.split(',').contains(m.item.type.json)) {
        return;
      }
      if (shown.any((t) => t.id == m.item.id)) return;
      state = AsyncData([m.item, ...shown]);
    });
    ref.onDispose(() => unawaited(live.cancel()));
    final page = await ref
        .read(tapeRepositoryProvider)
        .tape(exchangeId, types: types);
    _cursor = page.nextCursor;
    return page.items;
  }

  /// The next older page, appended.
  Future<void> loadMore() async {
    final cursor = _cursor;
    final shown = state.value;
    if (cursor == null || shown == null) return;
    final (exchangeId, types) = key;
    final page = await ref
        .read(tapeRepositoryProvider)
        .tape(exchangeId, types: types, cursor: cursor);
    _cursor = page.nextCursor;
    if (ref.mounted) state = AsyncData([...shown, ...page.items]);
  }
}

/// When you last looked at the tape this session: newer items are unread,
/// and the tab bar's tape dot shows while there are any.
final tapeSeenProvider = NotifierProvider<TapeSeen, DateTime?>(TapeSeen.new);

class TapeSeen extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void seen(DateTime at) => state = at;
}

/// The notification inbox for an exchange, with live `notification`
/// messages on top.
final notificationsProvider = AsyncNotifierProvider.autoDispose
    .family<Inbox, List<Notification>, String>(Inbox.new);

class Inbox extends AsyncNotifier<List<Notification>> {
  Inbox(this.exchangeId);

  final String exchangeId;

  @override
  Future<List<Notification>> build() async {
    ref.watch(refetchSignalProvider);
    final live = ref.watch(auraStreamProvider).messages.listen((m) {
      final shown = state.value;
      if (m is NotificationMessage &&
          shown != null &&
          !shown.any((n) => n.id == m.item.id)) {
        state = AsyncData([m.item, ...shown]);
      }
    });
    ref.onDispose(() => unawaited(live.cancel()));
    final page = await ref
        .read(meRepositoryProvider)
        .notifications(exchangeId: exchangeId);
    return page.items;
  }
}

/// How many notifications are unread: the bell's badge.
final unreadNotificationsProvider = Provider.autoDispose.family<int, String>(
  (ref, exchangeId) =>
      ref
          .watch(notificationsProvider(exchangeId))
          .value
          ?.where((n) => n.readAt == null)
          .length ??
      0,
);

/// Your notification settings (quiet hours, what you hear about).
final notificationPrefsProvider = FutureProvider.autoDispose<NotificationPrefs>(
  (ref) {
    ref.watch(refetchSignalProvider);
    return ref.read(meRepositoryProvider).prefs();
  },
);
