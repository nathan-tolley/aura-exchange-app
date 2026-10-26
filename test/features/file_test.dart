import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/api/generated/export.dart' hide Freshness;
import 'package:aura_exchange/design/widgets/aura_banner.dart';
import 'package:aura_exchange/design/widgets/aura_status_chip.dart';
import 'package:aura_exchange/features/events/file_sheet.dart';
import 'package:aura_exchange/features/events/filing_status.dart';
import 'package:aura_exchange/format/time.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:flutter_test/flutter_test.dart';

/// File an event and its status (SCREENS.md #11, #12).
void main() {
  const jake = FileSubject(id: 'j', ticker: r'$JAKE', name: 'Jake');
  const me = FileSubject(id: 'n', ticker: r'$NATE', name: 'Nathan', isMe: true);
  final zone = exchangeZone('Australia/Sydney');
  final now = DateTime.utc(2026, 10, 24, 10, 41);

  FileModel model({
    FileSubject? subject = jake,
    bool hasText = true,
    ApiError? problem,
  }) => fileModel(
    subjects: const [jake, me],
    subject: subject,
    hasText: hasText,
    filing: false,
    problem: problem,
    context: ErrorContext(zone: zone, now: now),
  );

  group('filing', () {
    test('File waits for text, and says who will know', () {
      expect(model(hasText: false).canFile, isFalse);
      expect(model(hasText: false).note, writeWhatHappened);
      expect(model().canFile, isTrue);
      expect(model().note, onlyTheyKnow('Jake'));
    });

    test('filing about yourself gets its note', () {
      final m = model(subject: me);
      expect(m.banner?.title, selfFilingTitle);
      expect(m.note, onlyModeratorsKnow);
    });

    test("the daily limit stops filing and says when it's back", () {
      final m = model(
        problem: const ApiError(
          code: 'DAILY_FILING_LIMIT',
          params: {'limit': '10', 'resetsAt': '2026-10-24T13:00:00Z'},
          retryable: false,
          action: ApiAction.wait,
          status: 422,
        ),
      );
      expect(m.canFile, isFalse);
      expect(m.banner?.tone, AuraBannerTone.warn);
      expect(m.banner?.body, contains('12:00 am'));
    });

    test('offline is the offline banner with Retry', () {
      final m = model(problem: const ApiError.offline());
      expect(m.banner?.tone, AuraBannerTone.offline);
      expect(m.banner?.action, 'Retry');
    });
  });

  group('status', () {
    Event event(String status, {DateTime? unsendUntil}) => Event.fromJson({
      'id': 'e',
      'exchangeId': 'x',
      'subject': {
        'id': 'j',
        'ticker': r'$JAKE',
        'displayName': 'Jake',
        'avatarUrl': null,
      },
      'status': status,
      'author': null,
      'isMine': true,
      'isAboutMe': false,
      'isSelfFiled': false,
      'teaser': 'Unconfirmed: something.',
      'text': 'What I wrote.',
      'receipts': <Object?>[],
      'happenedAt': null,
      'createdAt': now.subtract(const Duration(seconds: 6)).toIso8601String(),
      'unsendUntil': unsendUntil?.toIso8601String(),
      'rumorEndsAt': status == 'RUMOR'
          ? now.add(const Duration(minutes: 6)).toIso8601String()
          : null,
      'reactions': {'cosigns': 0, 'caps': 0, 'mine': null},
      'subjectStatement': null,
      'insiderUntil': null,
      'ruling': null,
      'halt': null,
      'votes': null,
      'appeal': null,
    });

    test('sending shows the unsend window, rumor the countdown', () {
      final sending = filingStatusModel(
        event('SENDING', unsendUntil: now.add(const Duration(seconds: 24))),
        zone: zone,
        now: now,
      );
      expect(sending.status, AuraStatus.sending);
      expect(sending.unsendLeft, const Duration(seconds: 24));
      expect(sending.text, 'What I wrote.');
      final rumor = filingStatusModel(event('RUMOR'), zone: zone, now: now);
      expect(rumor.unsendLeft, isNull);
      expect(rumor.rulingIn, const Duration(minutes: 6));
    });

    test('unsent says nobody saw it', () {
      final m = filingStatusModel(event('CANCELED'), zone: zone, now: now);
      expect(m.banner?.title, unsentTitle);
      expect(m.statusLabel, unsentTitle);
    });
  });
}
