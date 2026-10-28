import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../api/client.dart';
import '../../../api/errors.dart';
import '../../../l10n/strings.dart' show ErrorContext;
import '../../../api/generated/export.dart' hide Freshness;
import '../../../features/stock/halted_view.dart';
import '../../../data/freshness.dart';
import '../../../data/uploads.dart';
import '../../../features/events/about_you_models.dart';
import '../../../features/events/about_you_views.dart';
import '../../../features/events/file_sheet.dart';
import '../../../features/events/filing_status.dart';
import '../../../features/events/receipts.dart';
import '../../../format/time.dart';
import '../../tokens.dart';
import '../../widgets/aura_photo_tile.dart';
import '../screen_fixtures.dart' show halted;
import 'frames.dart';
import 'photos.dart';

// Filing an event and its status (SCREENS.md #11, #12), at 9:41 pm in
// Sydney.

final _sydney = exchangeZone('Australia/Sydney');
final _now = DateTime.utc(2026, 10, 24, 10, 41);

const _subjects = [
  FileSubject(
    id: '11111111-0000-4000-8000-000000000002',
    ticker: r'$JAKE',
    name: 'Jake',
  ),
  FileSubject(
    id: '11111111-0000-4000-8000-000000000001',
    ticker: r'$ANNA',
    name: 'Anna',
  ),
  FileSubject(
    id: '11111111-0000-4000-8000-000000000004',
    ticker: r'$ELI',
    name: 'Eli',
  ),
  FileSubject(
    id: '11111111-0000-4000-8000-000000000003',
    ticker: r'$NATE',
    name: 'Nathan',
    isMe: true,
  ),
];

const _text =
    'Jake replied "who is this" to his own mum in the family group chat. '
    'Screenshot in the group.';

Widget _file({
  FileSubject? subject,
  String text = _text,
  ApiError? problem,
  bool discarding = false,
  List<ReceiptDraft> receipts = const [],
  bool choosing = false,
  bool cameraOff = false,
}) => Controlled(
  texts: [text, ''],
  builder: (context, c) => sheetOver(
    const ColoredBox(color: AuraColors.bg, child: SizedBox.expand()),
    FileSheetView(
      model: fileModel(
        subjects: _subjects,
        subject: subject,
        hasText: text.isNotEmpty,
        filing: false,
        problem: problem,
        discarding: discarding,
        receipts: receipts,
        choosing: choosing,
        cameraOff: cameraOff,
        context: ErrorContext(zone: _sydney, now: _now),
      ),
      receiptImage: (t) => fixturePhoto(t.id),
      text: c[0],
      search: c[1],
      onSearch: (_) {},
      onSubject: (_) {},
      onChangeSubject: _noop,
      onText: (_) {},
      onFile: _noop,
      onBannerAction: _noop,
      onClose: _noop,
      onKeepWriting: _noop,
      onDiscard: _noop,
      onAddReceipt: _noop,
      onRetryReceipt: (_) {},
      onRemoveReceipt: (_) {},
      onChooseLibrary: _noop,
      onTakePhoto: _noop,
      onCancelChoosing: _noop,
    ),
  ),
);

/// A receipt on the filing; the gallery draws its photo as a stand-in.
ReceiptDraft _receipt(
  int id, {
  AuraPhotoStatus status = AuraPhotoStatus.ready,
  double progress = 1,
  ApiError? problem,
}) => ReceiptDraft(
  id: id,
  photo: PickedPhoto(bytes: Uint8List(0), contentType: 'image/jpeg'),
  key: IdempotencyKey(),
  status: status,
  progress: progress,
  problem: problem,
);

/// S11a: who it's about.
Widget fileSubject() => _file();

/// S11b: composing, about Jake.
Widget fileCompose() => _file(subject: _subjects.first);

/// S11c: filing about yourself.
Widget fileSelf() => _file(
  subject: _subjects.last,
  text: 'Ran 10 km before work. Strava in the group.',
);

/// S11d: today's limit reached.
Widget fileLimit() => _file(
  subject: _subjects.first,
  problem: const ApiError(
    code: 'DAILY_FILING_LIMIT',
    params: {'limit': '10', 'resetsAt': '2026-10-24T13:00:00Z'},
    retryable: false,
    action: ApiAction.wait,
    status: 422,
  ),
);

/// S11e: closing with something written.
Widget fileDiscard() => _file(subject: _subjects.first, discarding: true);

/// S11f: nothing typed yet.
Widget fileEmpty() => _file(subject: _subjects.first, text: '');

/// S11g: two screenshots attached and uploaded.
Widget fileReceipts() =>
    _file(subject: _subjects.first, receipts: [_receipt(0), _receipt(2)]);

/// S11h: where a receipt comes from.
Widget fileAddReceipt() =>
    _file(subject: _subjects.first, receipts: [_receipt(0)], choosing: true);

/// S11i: the camera is off for the app.
Widget fileCameraOff() => _file(
  subject: _subjects.first,
  receipts: [_receipt(0)],
  choosing: true,
  cameraOff: true,
);

/// S11j: one still uploading, so File waits.
Widget fileReceiptUploading() => _file(
  subject: _subjects.first,
  receipts: [
    _receipt(0),
    _receipt(1, status: AuraPhotoStatus.uploading, progress: 0.6),
  ],
);

/// S11k: one didn't upload; tap it to try again.
Widget fileReceiptFailed() => _file(
  subject: _subjects.first,
  receipts: [
    _receipt(0),
    _receipt(
      3,
      status: AuraPhotoStatus.failed,
      progress: 0.3,
      problem: const ApiError.unexpected(),
    ),
  ],
);

/// S11l: one didn't upload because you went offline.
Widget fileReceiptOffline() => _file(
  subject: _subjects.first,
  receipts: [
    _receipt(0),
    _receipt(
      1,
      status: AuraPhotoStatus.failed,
      progress: 0.3,
      problem: const ApiError.offline(),
    ),
  ],
);

/// S11m: four, the most a filing can carry.
Widget fileReceiptsFull() => _file(
  subject: _subjects.first,
  receipts: [for (var i = 0; i < 4; i++) _receipt(i)],
);

Event _event(
  String status, {
  bool ruled = false,
  bool halted = false,
  int sendingLeft = 0,
  bool mine = true,
  String? reaction,
  bool insider = false,
  Map<String, Object?>? votes,
  String? correction,
  String? haltStatus,
}) => Event.fromJson({
  'id': '44444444-0000-4000-8000-000000000009',
  'exchangeId': '7c1d2e3f-0a1b-4c5d-8e9f-a0b1c2d3e4f5',
  'subject': {
    'id': '11111111-0000-4000-8000-000000000002',
    'ticker': r'$JAKE',
    'displayName': 'Jake',
    'avatarUrl': null,
  },
  'status': status,
  'author': null,
  'isMine': mine,
  'isAboutMe': false,
  'isSelfFiled': false,
  'teaser': 'Unconfirmed: reports of a late-night messaging incident.',
  'text': mine ? _text : null,
  'receipts': <Object?>[],
  'happenedAt': null,
  'createdAt': _now
      .subtract(Duration(seconds: 30 - sendingLeft))
      .subtract(Duration(minutes: status == 'SENDING' ? 0 : 4))
      .toIso8601String(),
  'unsendUntil': status == 'SENDING'
      ? _now.add(Duration(seconds: sendingLeft)).toIso8601String()
      : null,
  'denialPenaltyPct': '20.00',
  'rumorEndsAt': status == 'SENDING'
      ? null
      : _now.add(const Duration(minutes: 6, seconds: 12)).toIso8601String(),
  'reactions': {'cosigns': 3, 'caps': 1, 'mine': reaction},
  'subjectStatement': null,
  'insiderUntil': insider
      ? _now.add(const Duration(minutes: 36)).toIso8601String()
      : null,
  'ruling': ruled
      ? {
          'verdict': 'LOSS',
          'impactAnalyst': -14,
          'impactFinal': -18,
          'multipliers': {
            'cosign': '1.30',
            'self': '1.00',
            'pileOn': '1.00',
            'denial': '1.00',
            'votes': '1.00',
          },
          'confidence': '0.86',
          'category': 'SCANDAL',
          'headline':
              'Jake indicated sharply lower after overnight “who is this” '
              'incident',
          'analystNote':
              'We are moving to Underweight. Family relations remain a '
              'headwind.',
          'ruledAt': _now.toIso8601String(),
          'priceMovePct': '-12.19',
          'landsAt': null,
          'indicatedPrice': null,
          'correction': correction,
        }
      : null,
  'halt': halted
      ? {
          'id': '77777777-0000-4000-8000-000000000001',
          'scope': 'LISTING',
          'listingId': '11111111-0000-4000-8000-000000000002',
          'reason': 'NEWS_PENDING',
          'status': haltStatus ?? 'VOTING',
          'startedAt': _now.toIso8601String(),
          'endsAt': _now.add(const Duration(minutes: 30)).toIso8601String(),
          'eventId': '44444444-0000-4000-8000-000000000009',
          'vote': null,
          'ifConfirmedMovePct': '-16.20',
        }
      : null,
  'votes': votes,
  'appeal': null,
});

Widget _status(Event e) => FilingStatusView(
  model: filingStatusModel(e, zone: _sydney, now: _now),
  onClose: _noop,
  onUndo: _noop,
);

/// S12a: just filed, the unsend window open.
Widget filingSending() => _status(_event('SENDING', sendingLeft: 24));

/// S12b: the rumor is live.
Widget filingRumor() => _status(_event('RUMOR'));

/// S12c: ruled.
Widget filingRuled() => _status(_event('RULED', ruled: true));

/// S12d: halted for the group's vote.
Widget filingHalted() => _status(_event('HALTED', ruled: true, halted: true));

/// S12e: voided.
Widget filingVoided() => _status(_event('VOIDED'));

/// S12f: unsent in time.
Widget filingUnsent() => _status(_event('CANCELED'));

// Rumors and rulings as everyone else sees them (S13, S15), and the
// halt vote (S17).

final _open = Freshness(asOf: _now, marketState: MarketState.open);

Widget _rumor(Event e) => RumorView(
  model: rumorModel(event: e, market: _open, zone: _sydney, now: _now),
  onClose: _noop,
  onReact: (_) {},
);

Widget _ruling(Event e, {bool holds = false}) => RulingView(
  model: rulingModel(
    event: e,
    market: _open,
    holdsStock: holds,
    zone: _sydney,
    now: _now,
  ),
  onClose: _noop,
  onVote: (_) {},
);

Map<String, Object?> _votes({String? mine, bool conflicted = false}) => {
  'up': 4,
  'down': 1,
  'mine': mine,
  'closesAt': _now.add(const Duration(minutes: 70)).toIso8601String(),
  'conflicted': conflicted,
};

/// S13a: the teaser and the countdown, before you've said anything.
Widget rumorTeaser() => _rumor(_event('RUMOR', mine: false));

/// S13b: you co-signed: the insider notice, and a way to take it back.
Widget rumorCosigned() =>
    _rumor(_event('RUMOR', mine: false, reaction: 'COSIGN', insider: true));

/// S13c: you capped it.
Widget rumorCapped() => _rumor(_event('RUMOR', mine: false, reaction: 'CAP'));

/// S15a: ruled, the vote open.
Widget rulingPublic() =>
    _ruling(_event('RULED', ruled: true, mine: false, votes: _votes()));

/// S15b: you voted it down, and you hold the stock: conflicted.
Widget rulingConflicted() => _ruling(
  _event(
    'RULED',
    ruled: true,
    mine: false,
    votes: _votes(mine: 'DOWN', conflicted: true),
  ),
  holds: true,
);

/// S15c: corrected after an appeal.
Widget rulingCorrected() => _ruling(
  _event(
    'RULED',
    ruled: true,
    mine: false,
    correction:
        'An earlier version of this story overstated who Jake was texting.',
  ),
);

/// S15d: the story hidden by a super-injunction.
Widget rulingHidden() => _ruling(_event('HIDDEN', ruled: true, mine: false));

/// S15e: voided.
Widget rulingVoided() => _ruling(_event('VOIDED', mine: false));

/// S17a: the halt vote, with yours on its row (W10's screen).
Widget haltYourVote() => HaltedStockView(
  model: halted(mine: 'CONFIRM'),
  onBack: _noop,
  onVote: (_) {},
);

/// S17b: the result: the group confirmed it.
Widget haltResult() => _ruling(
  _event(
    'RULED',
    ruled: true,
    halted: true,
    mine: false,
    haltStatus: 'CONFIRMED',
  ),
);

void _noop() {}
