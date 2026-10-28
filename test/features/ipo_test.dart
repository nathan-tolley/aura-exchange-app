import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/data/me.dart';
import 'package:aura_exchange/design/tone.dart';
import 'package:aura_exchange/design/widgets/aura_banner.dart';
import 'package:aura_exchange/features/onboarding/ipo_model.dart';
import 'package:aura_exchange/features/onboarding/ipo_screen.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http.dart';
import '../support/fake_socket.dart';
import '../support/providers.dart';

/// Your IPO (SCREENS.md #3).
void main() {
  const exchangeId = '7c1d2e3f-0a1b-4c5d-8e9f-a0b1c2d3e4f5';
  final membership = {
    'id': '22222222-0000-4000-8000-000000000001',
    'exchangeId': exchangeId,
    'role': 'ADMIN',
    'listing': null,
    'listingConsentAt': null,
    'joinedAt': '2026-10-24T10:40:00Z',
    'badges': <String>[],
    'superInjunctionsLeft': 3,
    'superInjunctionsPerSeason': 3,
  };
  const listing = {
    'id': '11111111-0000-4000-8000-000000000003',
    'ticker': r'$NATE',
    'displayName': 'Nathan',
    'avatarUrl': null,
  };

  late FakeAdapter http;
  late ProviderContainer container;
  late Map<String, Object?> Function(String) check;

  setUp(() async {
    check = (t) => {'ticker': '\$$t', 'available': true, 'suggestions': []};
    http = FakeAdapter((r) {
      switch (r.path) {
        case '/me':
          return jsonBody(200, {
            'user': tokenPairJson['user'],
            'memberships': [membership],
          });
        case '/exchanges/$exchangeId/tickers/check':
          return jsonBody(200, check(r.queryParameters['ticker'] as String));
        case '/exchanges/$exchangeId/listing':
          return jsonBody(201, listing);
      }
      return errorBody(404, 'NOT_FOUND');
    });
    container = testContainer(
      http: http,
      sockets: <FakeSocket>[],
      now: DateTime.utc(2026, 10, 24, 10, 41),
    );
    container.listen(ipoProvider, (_, _) {});
    container.listen(meProvider, (_, _) {});
    await container.read(meProvider.future);
  });

  tearDown(() => container.dispose());

  IpoController controller() => container.read(ipoProvider.notifier);
  IpoState state() => container.read(ipoProvider);
  String? keyOf(RequestOptions r) => r.headers['Idempotency-Key'] as String?;
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 450));

  test('checks only once typing pauses, and only the latest', () async {
    controller().type('NA');
    expect(state().check, TickerCheckState.none);
    controller().type('NAT');
    controller().type('NATE');
    expect(state().check, TickerCheckState.checking);
    await settle();
    final checks = http.to('/exchanges/$exchangeId/tickers/check');
    expect(checks, hasLength(1));
    expect(checks.single.queryParameters['ticker'], 'NATE');
    expect(state().check, TickerCheckState.free);
    final m = ipoTickerModel(state());
    expect(m.fieldNote, r'$NATE is free.');
    expect(m.button, r'List me as $NATE');
    expect(m.canList, isTrue);
    expect(m.note, yourConsent);
  });

  test('taken shows the suggestions to use instead', () async {
    check = (t) => {
      'ticker': '\$$t',
      'available': false,
      'suggestions': [r'$JAKEY', r'$JKE'],
    };
    controller().type('JAKE');
    await settle();
    final m = ipoTickerModel(state());
    expect(m.fieldNote, r'$JAKE is taken.');
    expect(m.fieldNoteTone, AuraTone.down);
    expect(m.suggestions, [(r'Use $JAKEY', 'JAKEY'), (r'Use $JKE', 'JKE')]);
    expect(m.canList, isFalse);
    expect(m.note, pickFreeTicker);
  });

  test("offline, the check says it can't", () async {
    http.handler = offline;
    controller().type('NATE');
    await settle();
    expect(ipoTickerModel(state()).fieldNote, tickerCantCheck);
    expect(ipoTickerModel(state()).fieldNoteTone, AuraTone.warn);
  });

  test('lists with consent; Retry reuses the key', () async {
    controller().type('NATE');
    await settle();
    final answer = http.handler;
    http.handler = offline;
    await controller().list();
    expect(ipoTickerModel(state()).banner?.tone, AuraBannerTone.offline);
    http.handler = answer;
    await controller().list();
    final posts = http.to('/exchanges/$exchangeId/listing');
    expect(posts, hasLength(2));
    expect(keyOf(posts[0]), keyOf(posts[1]));
    expect(posts.last.data, {'ticker': 'NATE', 'consent': true});
    expect(state().step, IpoStep.listed);
    expect(state().listed?.ticker, r'$NATE');
  });

  test('taken at the last moment goes back to the field', () async {
    controller().type('NATE');
    await settle();
    http.handler = (_) =>
        errorBody(409, 'TICKER_TAKEN', params: {'ticker': r'$NATE'});
    await controller().list();
    final m = ipoTickerModel(state());
    expect(state().check, TickerCheckState.taken);
    expect(m.banner, isNull);
    expect(m.fieldNote, r'$NATE is taken.');
    expect(state().problem?.code, 'TICKER_TAKEN');
  });

  test('listed copy counts toward the open', () {
    expect(listedBody(1, 3), 'The market opens at 3 listings. 1 of 3 so far.');
    expect(listedBody(3, 3), '3 listed, so trading has started.');
    expect(const ApiError.offline().code, ApiError.appOffline);
  });
}
