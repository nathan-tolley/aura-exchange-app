import 'package:aura_exchange/api/errors.dart';
import 'package:aura_exchange/api/generated/export.dart';
import 'package:aura_exchange/data/me.dart';
import 'package:aura_exchange/design/tone.dart';
import 'package:aura_exchange/design/widgets/aura_banner.dart';
import 'package:aura_exchange/features/onboarding/create_exchange_model.dart';
import 'package:aura_exchange/features/onboarding/create_exchange_screen.dart';
import 'package:aura_exchange/format/time.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http.dart';
import '../support/fake_socket.dart';
import '../support/providers.dart';

/// Creating an exchange (SCREENS.md #4).
void main() {
  const exchangeId = '7c1d2e3f-0a1b-4c5d-8e9f-a0b1c2d3e4f5';
  final now = DateTime.utc(2026, 10, 24, 10, 41);
  final exchangeJson = {
    'id': exchangeId,
    'name': 'The Group Chat',
    'timezone': 'Australia/Sydney',
    'hours': {
      'preOpen': '07:00',
      'open': '09:00',
      'close': '22:00',
      'afterClose': '02:00',
    },
    'feeRate': '0.50',
    'extendedFeeRate': '1.50',
    'listedCount': 0,
    'memberCount': 1,
    'minListingsToOpen': 3,
    'season': {
      'id': '33333333-0000-4000-8000-000000000001',
      'number': 1,
      'startsAt': '2026-10-24T10:30:00Z',
      'endsAt': '2026-12-19T10:30:00Z',
    },
    'me': {
      'id': '22222222-0000-4000-8000-000000000001',
      'exchangeId': exchangeId,
      'role': 'ADMIN',
      'listing': null,
      'listingConsentAt': null,
      'joinedAt': '2026-10-24T10:40:00Z',
      'badges': <String>[],
      'superInjunctionsLeft': 3,
    },
  };
  final meJson = {
    'user': tokenPairJson['user'],
    'memberships': [exchangeJson['me']],
  };
  final inviteJson = {
    'code': 'NATE-7F2K',
    'url': 'https://aura.example/i/NATE-7F2K',
    'expiresAt': '2026-10-31T10:41:00Z',
  };

  late FakeAdapter http;
  late ProviderContainer container;

  setUp(() {
    http = FakeAdapter(
      (r) => switch (r.path) {
        '/exchanges' => jsonBody(201, exchangeJson),
        '/me' => jsonBody(200, meJson),
        '/exchanges/$exchangeId/invites' => jsonBody(201, inviteJson),
        '/exchanges/$exchangeId' => jsonBody(200, exchangeJson),
        _ => errorBody(404, 'NOT_FOUND'),
      },
    );
    container = testContainer(http: http, sockets: <FakeSocket>[], now: now);
    container.listen(createExchangeProvider, (_, _) {});
    container.listen(meProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  CreateExchangeController controller() =>
      container.read(createExchangeProvider.notifier);
  CreateExchangeState state() => container.read(createExchangeProvider);
  String? keyOf(RequestOptions r) => r.headers['Idempotency-Key'] as String?;

  test('a name needs 2 to 40 characters', () {
    controller().toHours(' A ');
    expect(state().step, CreateStep.name);
    final m = createNameModel(state(), hasName: true);
    expect(m.fieldNote, exchangeNameLength);
    expect(m.fieldNoteTone, AuraTone.down);

    controller().toHours('  The Group Chat ');
    expect(state().step, CreateStep.hours);
    expect(state().name, 'The Group Chat');
  });

  test('creates it with the name and zone, then reloads /me', () async {
    controller().toHours('The Group Chat');
    controller().pickZone('Australia/Perth');
    final made = await controller().create();
    expect(made?.id, exchangeId);
    expect(http.to('/exchanges').single.data, {
      'name': 'The Group Chat',
      'timezone': 'Australia/Perth',
    });
    expect(container.read(currentExchangeIdProvider), exchangeId);
  });

  test('Retry reuses the key; a changed zone is a new action', () async {
    controller().toHours('The Group Chat');
    final answer = http.handler;
    http.handler = offline;
    await controller().create();
    expect(
      createHoursModel(state(), now: now).banner?.tone,
      AuraBannerTone.offline,
    );
    await controller().create();
    controller().pickZone('Australia/Perth');
    http.handler = answer;
    await controller().create();
    final posts = http.to('/exchanges');
    expect(posts, hasLength(3));
    expect(keyOf(posts[0]), keyOf(posts[1]));
    expect(keyOf(posts[1]), isNot(keyOf(posts[2])));
  });

  test('the server refusing the name goes back to it', () async {
    controller().toHours('The Group Chat');
    http.handler = (_) =>
        errorBody(400, 'VALIDATION', params: {'field': 'name', 'rule': 'x'});
    await controller().create();
    expect(state().step, CreateStep.name);
    expect(
      createNameModel(state(), hasName: true).fieldNoteTone,
      AuraTone.down,
    );
  });

  test('the invite link keeps its key across Retry', () async {
    final answer = http.handler;
    http.handler = offline;
    container.listen(inviteLinkProvider(exchangeId), (_, _) {});
    await expectLater(
      container.read(inviteLinkProvider(exchangeId).future),
      throwsA(isA<ApiError>()),
    );
    http.handler = answer;
    container.invalidate(inviteLinkProvider(exchangeId));
    final invite = await container.read(inviteLinkProvider(exchangeId).future);
    expect(invite.code, 'NATE-7F2K');
    final posts = http.to('/exchanges/$exchangeId/invites');
    expect(keyOf(posts[0]), keyOf(posts[1]));
  });

  test('invite and waiting copy come from the exchange', () {
    final exchange = Exchange.fromJson(exchangeJson);
    final loading = inviteModel(
      exchange: exchange,
      invite: null,
      problem: null,
      now: now,
    );
    expect(loading.loading, isTrue);
    expect(loading.copyNote, makingTheLink);
    expect(loading.body, inviteBody(3));
    final ready = inviteModel(
      exchange: exchange,
      invite: Invite.fromJson(inviteJson),
      problem: null,
      now: now,
    );
    expect(ready.link, 'https://aura.example/i/NATE-7F2K');
    expect(ready.expires, '31 Oct, 9:41 pm');
    expect(ready.copyNote, isNull);

    final waiting = waitingModel(exchange);
    expect(
      waiting.body,
      'The Group Chat opens when 3 people are listed. 0 of 3 so far.',
    );
    expect(waiting.opens, '9:00 am');
    expect(waiting.closes, '10:00 pm');
    expect(waiting.zone, 'Sydney');
  });

  test('wall-clock hours and zone names', () {
    expect(formatWallClock('07:00'), '7:00 am');
    expect(formatWallClock('00:30'), '12:30 am');
    expect(formatWallClock('12:00'), '12:00 pm');
    expect(formatWallClock('22:00'), '10:00 pm');
    expect(formatWallClock('soon'), 'soon');
    expect(zoneCity('America/Los_Angeles'), 'Los Angeles');
    // Every offered zone is in the database ('UTC' is stored as Etc/UTC).
    for (final z in exchangeZones.where((z) => z != 'UTC')) {
      expect(exchangeZone(z).name, z);
    }
  });
}
