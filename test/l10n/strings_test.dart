import 'dart:io';

import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/api/generated/export.dart';
import 'package:aura_exchange/format/time.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:flutter_test/flutter_test.dart';

/// Error copy (lib/l10n/strings.dart): one line for every code, in the
/// app's voice, and word for word where a screen is drawn.
void main() {
  final sydney = exchangeZone('Australia/Sydney');
  // Saturday 24 October 2026, 9:41 pm in Sydney: the drawn screens' "now".
  final now = DateTime.utc(2026, 10, 24, 10, 41);
  final context = ErrorContext(side: Side.buy, zone: sydney, now: now);

  ApiError error(
    String code, {
    Map<String, String> params = const {},
    int? status,
    bool retryable = false,
    ApiAction action = ApiAction.none,
  }) => ApiError(
    code: code,
    params: params,
    retryable: retryable,
    action: action,
    status: status,
  );

  /// Realistic params for every code, from API-CONTRACT.md's table.
  final examples = <String, Map<String, String>>{
    'VALIDATION': {'field': 'email', 'rule': 'format'},
    'LOGIN_CODE_INVALID': {'attemptsLeft': '3'},
    'NOT_A_MEMBER': {'exchangeId': '3f2b8c1e-5d4a-4e7b-9a10-2c6d8e9f0a1b'},
    'SELF_TRADE': {'ticker': r'$NATE'},
    'NOT_FOUND': {'resource': 'listing'},
    'QUOTE_STALE': {
      'oldPrice': '124.10',
      'newPrice': '125.36',
      'changePct': '1.02',
    },
    'EXCHANGE_FULL': {'maxMembers': '12'},
    'TICKER_TAKEN': {'ticker': r'$ANNA'},
    'TRADING_NOT_OPEN': {'listedCount': '1', 'minListingsToOpen': '3'},
    'LISTING_HALTED': {
      'haltId': '3f2b8c1e-5d4a-4e7b-9a10-2c6d8e9f0a1b',
      'resumesAt': '2026-10-24T11:05:00Z',
    },
    'MARKET_CLOSED': {'opensAt': '2026-10-24T20:00:00Z', 'queuedEvents': '1'},
    'ORDER_TYPE_NOT_ALLOWED': {'marketState': 'PRE'},
    'INSUFFICIENT_CASH': {
      'needed': '2494.41',
      'available': '2264.50',
      'shortBy': '229.91',
      'maxQuantity': '18',
      'nextStimulusAt': '2026-10-25T22:00:00Z',
    },
    'INSUFFICIENT_SHARES': {'available': '12'},
    'ORDER_TOO_LARGE': {'maxQuantity': '320'},
    'SHORT_CAP': {'maxQuantity': '40', 'capPct': '20.00'},
    'OPPOSITE_POSITION': {'positionId': '3f2b8c1e-5d4a-4e7b-9a10-2c6d8e9f0a1b'},
    'EQUITY_TOO_LOW': {'equity': '64.12', 'minimum': '100.00'},
    'DAILY_FILING_LIMIT': {'limit': '3', 'resetsAt': '2026-10-24T13:00:00Z'},
    'UPDATE_REQUIRED': {'minBuild': '42'},
    'RATE_LIMITED': {'retryAfterSeconds': '12'},
    'SERVER': {'reference': '7F2K'},
    'MAINTENANCE': {'until': '2026-10-24T11:30:00Z', 'reference': '7F2K'},
  };

  List<String> fields(ErrorCopy c) => [
    c.title,
    ?c.body,
    ?c.action,
    ?c.reference,
  ];

  group('every code', () {
    test("API-CONTRACT.md's error table is the spec's ErrorCode", () {
      final doc = File('docs/aura/API-CONTRACT.md').readAsStringSync();
      final inDoc = RegExp(
        r'^\| \d{3} \| `([A-Z_]+)` \|',
        multiLine: true,
      ).allMatches(doc).map((m) => m.group(1)!).toSet();
      final inSpec = ErrorCode.$valuesDefined.map((c) => c.json!).toSet();
      expect(inDoc, inSpec);
      expect(inSpec, hasLength(31));
    });

    for (final code in ErrorCode.$valuesDefined) {
      test('${code.json} has copy in the app\'s voice', () {
        for (final params in [examples[code.json] ?? {}, <String, String>{}]) {
          final copy = errorCopy(error(code.json!, params: params), context);
          expect(copy.title, isNotEmpty);
          for (final text in fields(copy)) {
            expect(text, isNot(contains('!')), reason: text);
            expect(text, isNot(contains('null')), reason: text);
            expect(text, isNot(contains('message')), reason: text);
            expect(text, isNot(matches(RegExp(r'-\d'))), reason: text);
            expect(
              text.runes.every((r) => r < 0x2190 || r == 0x2212),
              true,
              reason: 'no emoji or symbols: $text',
            );
          }
          if (copy.action case final String action) {
            expect(action, isNot(anyOf('OK', 'Submit', 'Cancel')));
            expect(action[0], action[0].toUpperCase());
          }
        }
      });
    }
  });

  group('drawn screens, word for word', () {
    test('W05 trade rejected', () {
      final copy = errorCopy(
        error('INSUFFICIENT_CASH', params: examples['INSUFFICIENT_CASH']!),
        context.copyWithNow(DateTime.utc(2026, 10, 25, 2)),
      );
      expect(copy.title, "You're A\$229.91 short");
      expect(
        copy.body,
        'You have A\$2,264.50. Buy 18 instead, sell something, or wait for '
        "tomorrow's stimulus check.",
      );
      expect(copy.action, 'Buy 18');
    });

    test('W06 requote', () {
      final copy = errorCopy(
        error('QUOTE_STALE', params: examples['QUOTE_STALE']!),
        context,
      );
      expect(copy.title, 'The price moved while you were deciding');
      expect(
        copy.body,
        'Someone bought first. A\$124.10 is now A\$125.36, up 1.02%.',
      );
      expect(copy.action, isNull);
    });

    test('W04 under the minimum', () {
      final copy = errorCopy(
        error('EQUITY_TOO_LOW', params: examples['EQUITY_TOO_LOW']!),
        context,
      );
      expect(copy.title, "You're under A\$100.00");
      expect(
        copy.body,
        "That's not enough to open a position. Keep what you have, or start "
        'over with Chapter 7.',
      );
    });

    test('W09 closed', () {
      final copy = errorCopy(
        error('MARKET_CLOSED', params: examples['MARKET_CLOSED']!),
        context,
      );
      expect(copy.title, 'Closed until 7:00 am');
      expect(
        copy.body,
        'A ruling lands at the open, so prices will gap. Orders you set now '
        'fill at the opening price.',
      );
    });

    test('W10 halted', () {
      final copy = errorCopy(error('LISTING_HALTED'), context);
      expect(copy.body, 'Trading resumes when the vote closes.');
    });

    test('W11 offline', () {
      final copy = offlineBanner(
        now.subtract(const Duration(minutes: 20)),
        sydney,
        now: now,
      );
      expect(copy.title, "You're offline");
      expect(
        copy.body,
        "Prices are from 9:21 pm. Trading and filing wait until you're back.",
      );
      expect(copy.action, 'Retry');
      expect(errorCopy(const ApiError.offline()).title, "You're offline");
    });

    test('W12 IPO day', () {
      final copy = errorCopy(
        error('TRADING_NOT_OPEN', params: examples['TRADING_NOT_OPEN']!),
        context,
      );
      expect(copy.body, '1 of 3 listed. The market opens at 3 listings.');
    });

    test('W13 exchange down', () {
      final copy = errorCopy(
        error('SERVER', params: {'reference': '7F2K'}, status: 503),
        context,
      );
      expect(copy.title, 'The exchange is down');
      expect(
        copy.body,
        'Something broke on our side. Your cash and positions are safe, and '
        'nothing traded while it was down.',
      );
      expect(copy.action, 'Try again');
      expect(copy.reference, '503 · 7F2K');
    });
  });

  group('params change the copy', () {
    test('verbs follow the trade', () {
      final copy = errorCopy(
        error('INSUFFICIENT_CASH', params: examples['INSUFFICIENT_CASH']!),
        ErrorContext(side: Side.cover, zone: sydney, now: now),
      );
      expect(copy.action, 'Cover 18');
      expect(
        errorCopy(
          error('INSUFFICIENT_SHARES', params: {'available': '1'}),
          const ErrorContext(side: Side.sell),
        ).title,
        'You only have 1 share',
      );
    });

    test('nothing to reduce to drops the button', () {
      final copy = errorCopy(
        error(
          'INSUFFICIENT_CASH',
          params: {'shortBy': '10.00', 'available': '5.00', 'maxQuantity': '0'},
        ),
        context,
      );
      expect(
        copy.body,
        'You have A\$5.00. Sell something, or wait for the '
        'next stimulus check.',
      );
      expect(copy.action, isNull);
    });

    test('a falling price was a seller', () {
      final copy = errorCopy(
        error(
          'QUOTE_STALE',
          params: {
            'oldPrice': '124.10',
            'newPrice': '122.86',
            'changePct': '-1.00',
          },
        ),
        context,
      );
      expect(
        copy.body,
        'Someone sold first. A\$124.10 is now A\$122.86, down 1.00%.',
      );
    });

    test('attempts left on a wrong code', () {
      String? body(String left) =>
          errorCopy(error('LOGIN_CODE_INVALID', params: {'attemptsLeft': left}))
              .body;
      expect(body('3'), 'You have 3 more tries.');
      expect(body('1'), 'You have 1 more try.');
      expect(body('0'), 'That was the last try. Send yourself a new code.');
    });

    test('times are on the exchange clock', () {
      final copy = errorCopy(
        error('DAILY_FILING_LIMIT', params: examples['DAILY_FILING_LIMIT']!),
        context,
      );
      expect(copy.title, "You've filed 3 events today");
      expect(
        copy.body,
        "That's the daily limit. You can file again at 12:00 am.",
      );
    });
  });

  group('codes this build has never seen', () {
    test('an unknown code gets the generic screen with its reference', () {
      final copy = errorCopy(
        error(
          'MARGIN_CALL_V2',
          params: {'reference': 'Q9X1'},
          status: 422,
          retryable: true,
          action: ApiAction.retry,
        ),
      );
      expect(copy.title, 'Something went wrong');
      expect(copy.body, 'Try again in a moment.');
      expect(copy.action, 'Try again');
      expect(copy.reference, 'MARGIN_CALL_V2 · 422 · Q9X1');
    });

    test("a proxy's 502 page is the exchange being down", () {
      final copy = errorCopy(const ApiError.unexpected(502));
      expect(copy.title, 'The exchange is down');
      expect(copy.reference, '502');
    });
  });
}

extension on ErrorContext {
  ErrorContext copyWithNow(DateTime now) =>
      ErrorContext(side: side, zone: zone, now: now);
}
