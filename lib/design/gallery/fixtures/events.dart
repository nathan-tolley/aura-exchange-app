import 'package:flutter/widgets.dart';

import '../../../api/errors.dart';
import '../../../l10n/strings.dart' show ErrorContext;
import '../../../api/generated/export.dart' hide Freshness;
import '../../../features/events/file_sheet.dart';
import '../../../features/events/filing_status.dart';
import '../../../format/time.dart';
import '../../tokens.dart';
import 'frames.dart';

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
        context: ErrorContext(zone: _sydney, now: _now),
      ),
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
    ),
  ),
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

Event _event(
  String status, {
  bool ruled = false,
  bool halted = false,
  int sendingLeft = 0,
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
  'isMine': true,
  'isAboutMe': false,
  'isSelfFiled': false,
  'teaser': 'Unconfirmed: reports of a late-night messaging incident.',
  'text': _text,
  'receipts': <Object?>[],
  'happenedAt': null,
  'createdAt': _now
      .subtract(Duration(seconds: 30 - sendingLeft))
      .subtract(Duration(minutes: status == 'SENDING' ? 0 : 4))
      .toIso8601String(),
  'unsendUntil': status == 'SENDING'
      ? _now.add(Duration(seconds: sendingLeft)).toIso8601String()
      : null,
  'rumorEndsAt': status == 'SENDING'
      ? null
      : _now.add(const Duration(minutes: 6, seconds: 12)).toIso8601String(),
  'reactions': {'cosigns': 3, 'caps': 1, 'mine': null},
  'subjectStatement': null,
  'insiderUntil': null,
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
          'correction': null,
        }
      : null,
  'halt': halted
      ? {
          'id': '77777777-0000-4000-8000-000000000001',
          'scope': 'LISTING',
          'listingId': '11111111-0000-4000-8000-000000000002',
          'reason': 'NEWS_PENDING',
          'status': 'VOTING',
          'startedAt': _now.toIso8601String(),
          'endsAt': _now.add(const Duration(minutes: 30)).toIso8601String(),
          'eventId': '44444444-0000-4000-8000-000000000009',
          'vote': null,
          'ifConfirmedMovePct': '-16.20',
        }
      : null,
  'votes': null,
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

void _noop() {}
