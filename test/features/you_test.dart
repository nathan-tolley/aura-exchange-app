import 'dart:convert';

import 'package:aura_exchange/api/client.dart';
import 'package:aura_exchange/api/generated/export.dart' hide Freshness;
import 'package:aura_exchange/data/repositories.dart';
import 'package:aura_exchange/features/you/you_view.dart';
import 'package:aura_exchange/l10n/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/api_json.dart';
import '../support/fake_http.dart';
import '../support/fake_socket.dart';
import '../support/providers.dart';

/// You and Settings (SCREENS.md #30, #31).
void main() {
  late FakeAdapter http;
  late ProviderContainer container;
  const prefsJson = {
    'holdingMovedPct': '5.00',
    'quietHours': null,
    'bells': true,
    'disabledTypes': <String>[],
  };

  setUp(() {
    http = FakeAdapter((_) => jsonBody(200, prefsJson));
    container = testContainer(
      http: http,
      sockets: <FakeSocket>[],
      now: DateTime.utc(2026, 10, 24, 10, 41),
    );
  });

  tearDown(() => container.dispose());

  test('turning quiet hours off sends an explicit null', () async {
    await container
        .read(meRepositoryProvider)
        .setPrefs(
          const NotificationPrefs(
            holdingMovedPct: '5.00',
            bells: true,
            disabledTypes: [],
          ),
          IdempotencyKey(),
        );
    final sent = http.to('/me/notification-prefs').single;
    expect(sent.method, 'PATCH');
    expect(sent.data, containsPair('quietHours', null));
    expect(sent.headers['Idempotency-Key'], isNotNull);
  });

  test('turning them on sends the hours', () async {
    await container
        .read(meRepositoryProvider)
        .setPrefs(
          const NotificationPrefs(
            quietHours: QuietHours(start: '22:00', end: '07:00'),
          ),
          IdempotencyKey(),
        );
    final data = http.to('/me/notification-prefs').single.data;
    // As it goes on the wire.
    final sent = jsonDecode(jsonEncode(data)) as Map<String, Object?>;
    expect(sent['quietHours'], {'start': '22:00', 'end': '07:00'});
  });

  test('opting out deletes your listing with a key', () async {
    http.handler = (_) => ResponseBody.fromString('', 204);
    await container
        .read(exchangesRepositoryProvider)
        .delist(testExchangeId, IdempotencyKey());
    final sent = http.to('/exchanges/$testExchangeId/listing').single;
    expect(sent.method, 'DELETE');
  });

  test('You: listed shows your stock; not listed offers the IPO', () {
    final user = User.fromJson(tokenPairJson['user']! as Map<String, Object?>);
    final unlisted = youModel(
      user: user,
      membership: Membership.fromJson(membershipJson(listed: false)),
      listing: null,
      live: null,
    );
    expect(unlisted.listed, isFalse);
    expect(unlisted.price, isNull);
    final listed = youModel(
      user: user,
      membership: Membership.fromJson(membershipJson()),
      listing: null,
      live: null,
    );
    expect(listed.ticker, r'$NATE');
    expect(leftOf(2, null), '2 left');
  });
}
