import 'package:aura_exchange/api/generated/export.dart' hide Freshness;
import 'package:aura_exchange/data/freshness.dart';
import 'package:aura_exchange/features/events/about_you_models.dart';
import 'package:aura_exchange/format/time.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rumor, ruling and the halt's result for everyone (SCREENS.md #13, #15,
/// #17).
void main() {
  final zone = exchangeZone('Australia/Sydney');
  final now = DateTime.utc(2026, 10, 24, 10, 41);
  final market = Freshness(asOf: now, marketState: MarketState.open);

  Event event(
    String status, {
    String? reaction,
    bool insider = false,
    Map<String, Object?>? votes,
    bool ruled = false,
    String? haltStatus,
  }) => Event.fromJson({
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
    'isMine': false,
    'isAboutMe': false,
    'isSelfFiled': false,
    'teaser': 'Unconfirmed: something.',
    'text': null,
    'receipts': <Object?>[],
    'happenedAt': null,
    'createdAt': '2026-10-24T10:37:00Z',
    'unsendUntil': null,
    'denialPenaltyPct': '20.00',
    'rumorEndsAt': '2026-10-24T10:47:00Z',
    'reactions': {'cosigns': 2, 'caps': 1, 'mine': reaction},
    'subjectStatement': null,
    'insiderUntil': insider ? '2026-10-24T11:17:00Z' : null,
    'ruling': ruled
        ? {
            'verdict': 'LOSS',
            'impactAnalyst': -14,
            'impactFinal': -18,
            'multipliers': {
              'cosign': '1.20',
              'self': '1.00',
              'pileOn': '1.00',
              'denial': '1.00',
              'votes': '1.00',
            },
            'confidence': '0.86',
            'category': 'SCANDAL',
            'headline': 'Jake indicated lower',
            'analystNote': 'Underweight.',
            'ruledAt': '2026-10-24T10:47:00Z',
            'priceMovePct': '-12.19',
            'landsAt': null,
            'indicatedPrice': null,
            'correction': null,
          }
        : null,
    'halt': haltStatus == null
        ? null
        : {
            'id': 'h',
            'scope': 'LISTING',
            'listingId': 'j',
            'reason': 'NEWS_PENDING',
            'status': haltStatus,
            'startedAt': '2026-10-24T10:47:00Z',
            'endsAt': '2026-10-24T11:17:00Z',
            'eventId': 'e',
            'vote': null,
            'ifConfirmedMovePct': '-16.20',
          },
    'votes': votes,
    'appeal': null,
  });

  group('rumor', () {
    test('two calls before you make one, three after', () {
      final fresh = rumorModel(
        event: event('RUMOR'),
        market: market,
        zone: zone,
        now: now,
      );
      expect(fresh.reactions, [Kind.cosign, Kind.cap]);
      expect(fresh.banner, isNull);
      expect(fresh.stats.first, (rulingIn, '6:00'));
      final backed = rumorModel(
        event: event('RUMOR', reaction: 'COSIGN', insider: true),
        market: market,
        zone: zone,
        now: now,
      );
      expect(backed.reactions.last, Kind.withdraw);
      expect(backed.responses.first.trailing, yourCall);
      expect(backed.banner?.title, insiderTitle('10:17 pm'));
    });
  });

  group('ruling', () {
    Map<String, Object?> votes({DateTime? closes, bool conflicted = false}) => {
      'up': 4,
      'down': 1,
      'mine': 'UP',
      'closesAt': (closes ?? now.add(const Duration(hours: 1)))
          .toIso8601String(),
      'conflicted': conflicted,
    };

    test('the vote while open, with the conflicted note', () {
      final m = rulingModel(
        event: event('RULED', ruled: true, votes: votes(conflicted: true)),
        market: market,
        holdsStock: false,
        zone: zone,
        now: now,
      );
      expect(m.votes, hasLength(2));
      expect(m.votes.first.trailing, yourVoteLabel);
      expect(m.voteNote, conflictedNote(r'$JAKE'));
      expect(m.subject.impact, -18);
    });

    test('no vote rows once it has closed', () {
      final m = rulingModel(
        event: event(
          'RULED',
          ruled: true,
          votes: votes(closes: now.subtract(const Duration(minutes: 1))),
        ),
        market: market,
        holdsStock: true,
        zone: zone,
        now: now,
      );
      expect(m.votes, isEmpty);
      expect(m.voteStatus, votingClosed);
      expect(m.voteNote, isNull);
    });

    test('a hidden story keeps the price move but not the words', () {
      final m = rulingModel(
        event: event('HIDDEN', ruled: true),
        market: market,
        holdsStock: false,
        zone: zone,
        now: now,
      );
      expect(m.headline, isNull);
      expect(m.note, isNull);
      expect(m.banner?.title, storyHiddenTitle);
      expect(m.movePct.toString(), '-12.19');
    });

    test("the group's verdict on a halt", () {
      String? title(String status) => rulingModel(
        event: event('RULED', ruled: true, haltStatus: status),
        market: market,
        holdsStock: false,
        zone: zone,
        now: now,
      ).banner?.title;
      expect(title('CONFIRMED'), confirmedTitle);
      expect(title('DECLINED'), declinedTitle);
      expect(title('RECONSIDERED'), reconsideredTitle);
    });
  });
}
