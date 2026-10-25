import 'package:flutter/foundation.dart';

import '../../api/errors.dart';
import '../../api/generated/export.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';
import 'create_exchange_model.dart';

/// Joining from an invite (SCREENS.md #2), worded.
@immutable
class JoinModel {
  const JoinModel({
    required this.title,
    required this.action,
    required this.kind,
    this.body,
    this.listed = const [],
    this.banner,
    this.canAct = true,
    this.note,
  });

  final String title;
  final String? body;

  /// Who's listed: (ticker, name).
  final List<(String, String)> listed;
  final BannerModel? banner;

  /// "Join the exchange", or the way out when the invite can't be used.
  final String action;
  final JoinKind kind;
  final bool canAct;

  /// "Invite NATE-7F2K", or why the button is off.
  final String? note;
}

/// What the bottom button does.
enum JoinKind {
  /// The preview is loading.
  loading,

  /// Join.
  join,

  /// The invite can't be used: start your own exchange.
  startOwn,

  /// The invite can't be used, but you're already in an exchange: go to it.
  openExchange,
}

JoinModel joinModel({
  required String code,
  required InvitePreview? preview,
  required ApiError? previewError,
  required ApiError? joinError,
  required bool joining,
  required bool inAnExchange,
}) {
  final way = inAnExchange ? JoinKind.openExchange : JoinKind.startOwn;
  final wayLabel = inAnExchange ? openTheExchange : startAnExchange;

  // The invite can't be used: say why, and offer the way out.
  JoinModel dead(String title, String? body) => JoinModel(
    title: title,
    body: body,
    action: wayLabel,
    kind: way,
    note: inviteCode(code),
  );

  final failure = joinError ?? previewError;
  final failureCode = failure?.errorCode;
  if (preview?.status == InvitePreviewStatus.expired ||
      failureCode == ErrorCode.inviteExpired) {
    final copy = errorCopy(
      failure ??
          const ApiError(
            code: 'INVITE_EXPIRED',
            retryable: false,
            action: ApiAction.none,
          ),
    );
    return dead(copy.title, copy.body);
  }
  if (preview?.status == InvitePreviewStatus.full ||
      failureCode == ErrorCode.exchangeFull) {
    final copy = errorCopy(
      failure ??
          const ApiError(
            code: 'EXCHANGE_FULL',
            retryable: false,
            action: ApiAction.none,
          ),
    );
    return dead(
      preview == null ? copy.title : exchangeIsFull(preview.exchangeName),
      copy.body,
    );
  }
  if (previewError?.errorCode == ErrorCode.notFound) {
    return dead(inviteDoesntWork, inviteDoesntWorkBody);
  }
  if (preview == null) {
    return JoinModel(
      title: yourInvite,
      action: joinTheExchange,
      kind: JoinKind.loading,
      canAct: false,
      banner: problemBanner(previewError, offline: joinOffline),
      note: inviteCode(code),
    );
  }
  return JoinModel(
    title: joinTitle(preview.exchangeName),
    body: joinBody(preview.memberCount, preview.listed.length),
    listed: [for (final l in preview.listed) (l.ticker, l.displayName)],
    banner: problemBanner(joinError, offline: joinOffline),
    action: joining ? joiningLabel : joinTheExchange,
    kind: JoinKind.join,
    canAct: !joining,
    note: inviteCode(preview.code),
  );
}
