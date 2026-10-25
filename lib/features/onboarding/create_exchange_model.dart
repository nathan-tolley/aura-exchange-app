import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../api/errors.dart';
import '../../api/generated/export.dart';
import '../../design/tone.dart';
import '../../design/widgets/aura_banner.dart';
import '../../format/time.dart';
import '../../l10n/strings.dart';
import '../shared/banner_model.dart';

/// The timezones offered when creating an exchange, Australia's first (the
/// group's own, since it trades in A$). Each is an IANA name the server
/// accepts as `timezone`.
const exchangeZones = [
  'Australia/Sydney',
  'Australia/Melbourne',
  'Australia/Brisbane',
  'Australia/Adelaide',
  'Australia/Hobart',
  'Australia/Darwin',
  'Australia/Perth',
  'Pacific/Auckland',
  'Asia/Singapore',
  'Asia/Tokyo',
  'Europe/London',
  'Europe/Paris',
  'America/New_York',
  'America/Chicago',
  'America/Denver',
  'America/Los_Angeles',
  'Pacific/Honolulu',
  'UTC',
];

/// The offered zone that's on the phone's clock right now, by offset (the
/// phone doesn't say its IANA name without a plugin). UTC if none is.
String guessZone(DateTime now) {
  final offset = now.timeZoneOffset;
  for (final iana in exchangeZones) {
    final there = tz.TZDateTime.from(now, exchangeZone(iana));
    if (there.timeZoneOffset == offset) return iana;
  }
  return 'UTC';
}

/// Where creating an exchange is: the name step or the timezone step, and
/// what's in flight.
@immutable
class CreateExchangeState {
  const CreateExchangeState({
    required this.zone,
    this.step = CreateStep.name,
    this.name = '',
    this.creating = false,
    this.nameInvalid = false,
    this.problem,
  });

  final CreateStep step;
  final String name;

  /// IANA.
  final String zone;
  final bool creating;
  final bool nameInvalid;
  final ApiError? problem;

  CreateExchangeState copyWith({
    CreateStep? step,
    String? name,
    String? zone,
    bool? creating,
    bool? nameInvalid,
    ApiError? Function()? problem,
  }) => CreateExchangeState(
    step: step ?? this.step,
    name: name ?? this.name,
    zone: zone ?? this.zone,
    creating: creating ?? this.creating,
    nameInvalid: nameInvalid ?? this.nameInvalid,
    problem: problem == null ? this.problem : problem(),
  );
}

enum CreateStep { name, hours }

/// The name step, worded.
@immutable
class CreateNameModel {
  const CreateNameModel({
    required this.canContinue,
    required this.fieldNote,
    this.fieldNoteTone = AuraTone.neutral,
    this.note,
  });

  final bool canContinue;
  final String fieldNote;
  final AuraTone fieldNoteTone;

  /// Why Continue is off, or how to join instead.
  final String? note;
}

CreateNameModel createNameModel(
  CreateExchangeState s, {
  required bool hasName,
}) {
  final serverSaysName =
      s.problem?.errorCode == ErrorCode.validation &&
      s.problem?.params['field'] == 'name';
  final invalid = s.nameInvalid || serverSaysName;
  return CreateNameModel(
    canContinue: hasName,
    fieldNote: invalid ? exchangeNameLength : exchangeNameHelp,
    fieldNoteTone: invalid ? AuraTone.down : AuraTone.neutral,
    note: hasName ? gotAnInvite : nameItFirst,
  );
}

/// The timezone step, worded.
@immutable
class CreateHoursModel {
  const CreateHoursModel({
    required this.zoneTitle,
    required this.zoneSubtitle,
    required this.button,
    required this.canCreate,
    this.banner,
  });

  /// "Sydney".
  final String zoneTitle;

  /// "Australia/Sydney · 9:41 pm there".
  final String zoneSubtitle;
  final BannerModel? banner;

  /// "Create exchange", or "Creating…".
  final String button;
  final bool canCreate;
}

CreateHoursModel createHoursModel(
  CreateExchangeState s, {
  required DateTime now,
}) => CreateHoursModel(
  zoneTitle: zoneCity(s.zone),
  zoneSubtitle: zoneSubtitle(s.zone, formatClock(now, exchangeZone(s.zone))),
  banner: problemBanner(s.problem, offline: createOffline),
  button: s.creating ? creatingExchange : createExchange,
  canCreate: !s.creating,
);

/// One row of the timezone sheet.
@immutable
class ZoneOption {
  const ZoneOption({
    required this.iana,
    required this.title,
    required this.subtitle,
    this.selected = false,
  });

  final String iana;
  final String title;
  final String subtitle;
  final bool selected;
}

List<ZoneOption> zoneOptions(String selected, {required DateTime now}) => [
  for (final iana in exchangeZones)
    ZoneOption(
      iana: iana,
      title: zoneCity(iana),
      subtitle: zoneSubtitle(iana, formatClock(now, exchangeZone(iana))),
      selected: iana == selected,
    ),
];

/// The invite step, worded. [invite] is null while the link is being made.
@immutable
class InviteModel {
  const InviteModel({
    required this.body,
    this.link,
    this.code,
    this.expires,
    this.banner,
    this.copyNote,
  });

  final String body;
  final String? link;
  final String? code;

  /// "Sat 9:41 pm".
  final String? expires;
  final BannerModel? banner;

  /// Why Copy link is off.
  final String? copyNote;

  bool get loading => link == null && banner == null;
}

InviteModel inviteModel({
  required Exchange? exchange,
  required Invite? invite,
  required ApiError? problem,
  required DateTime now,
}) {
  final zone = exchangeZone(exchange?.timezone ?? 'UTC');
  final banner = invite == null
      ? problemBanner(problem, offline: inviteOffline)
      : null;
  return InviteModel(
    body: inviteBody(exchange?.minListingsToOpen ?? 3),
    link: invite?.url,
    code: invite?.code,
    expires: invite == null
        ? null
        : formatMoment(invite.expiresAt, zone, now: now),
    banner: banner,
    copyNote: invite != null
        ? null
        : banner == null
        ? makingTheLink
        : noLinkYet,
  );
}

/// The waiting step, worded, from the exchange.
@immutable
class WaitingModel {
  const WaitingModel({
    required this.body,
    required this.members,
    required this.listed,
    required this.zone,
    required this.opens,
    required this.closes,
  });

  final String body;
  final String members;

  /// "0 of 3".
  final String listed;

  /// "Sydney".
  final String zone;

  /// "9:00 am", from the exchange's own hours.
  final String opens;
  final String closes;
}

WaitingModel waitingModel(Exchange e) => WaitingModel(
  body: waitingBody(e.name, e.listedCount, e.minListingsToOpen),
  members: '${e.memberCount}',
  listed: '${e.listedCount} of ${e.minListingsToOpen}',
  zone: zoneCity(e.timezone),
  opens: formatWallClock(e.hours.open),
  closes: formatWallClock(e.hours.close),
);

/// A failure as onboarding shows it: W11's banner with Retry when offline
/// ([offline] words it for the step), otherwise a down banner with the
/// error's copy and reference.
BannerModel? problemBanner(ApiError? problem, {required ErrorCopy offline}) {
  if (problem == null) return null;
  if (problem.code == ApiError.appOffline) {
    return BannerModel(
      tone: AuraBannerTone.offline,
      title: offline.title,
      body: offline.body,
      action: offline.action,
    );
  }
  final copy = errorCopy(problem);
  return BannerModel(
    tone: AuraBannerTone.down,
    title: copy.title,
    body: [?copy.body, ?copy.reference].join(' '),
    action: copy.action,
  );
}
