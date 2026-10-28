import 'dart:convert';
import 'dart:io';

import 'fake_http.dart';

// API-shaped JSON for tests that drive the app against a fake server. One
// exchange, The Group Chat, in Sydney; "you" are Nathan.

const testExchangeId = '7c1d2e3f-0a1b-4c5d-8e9f-a0b1c2d3e4f5';

/// Your membership, listed as $NATE unless [listed] is false.
Map<String, Object?> membershipJson({
  bool listed = true,
  String exchangeId = testExchangeId,
}) => {
  'id': '22222222-0000-4000-8000-000000000001',
  'exchangeId': exchangeId,
  'role': 'ADMIN',
  'listing': listed
      ? {
          'id': '11111111-0000-4000-8000-000000000003',
          'ticker': r'$NATE',
          'displayName': 'Nathan',
          'avatarUrl': null,
        }
      : null,
  'listingConsentAt': listed ? '2026-10-24T10:40:00Z' : null,
  'joinedAt': '2026-10-24T10:40:00Z',
  'badges': <String>[],
  'superInjunctionsLeft': 3,
  'superInjunctionsPerSeason': 3,
};

/// `GET /me` with [memberships].
Map<String, Object?> meJson(List<Map<String, Object?>> memberships) => {
  'user': tokenPairJson['user'],
  'memberships': memberships,
};

/// The exchange, [listed] of 3 listed.
Map<String, Object?> exchangeJson({
  int listed = 0,
  int members = 1,
  String name = 'The Group Chat',
  bool meListed = false,
}) => {
  'id': testExchangeId,
  'name': name,
  'timezone': 'Australia/Sydney',
  'hours': {
    'preOpen': '07:00',
    'open': '09:00',
    'close': '22:00',
    'afterClose': '02:00',
  },
  'feeRate': '0.50',
  'extendedFeeRate': '1.50',
  'listedCount': listed,
  'memberCount': members,
  'minListingsToOpen': 3,
  'season': {
    'id': '33333333-0000-4000-8000-000000000001',
    'number': 1,
    'startsAt': '2026-10-24T10:30:00Z',
    'endsAt': '2026-12-19T10:30:00Z',
  },
  'me': membershipJson(listed: meListed),
};

/// A spec example from test/fixtures/api, moved to [testExchangeId].
Map<String, Object?> exampleJson(String name) {
  final json = jsonDecode(
    File('test/fixtures/api/$name.json').readAsStringSync(),
  ) as Map<String, Object?>;
  return {...json, 'exchangeId': testExchangeId};
}

/// One listing in a market.
Map<String, Object?> listingJson(
  String ticker,
  String name, {
  String price = '100.00',
  String abs = '0.00',
  String pct = '0.00',
  bool mine = false,
  String? position,
  String state = 'ACTIVE',
  List<String> badges = const [],
}) => {
  'id':
      '11111111-0000-4000-8000-${ticker.hashCode.abs().toString().padLeft(12, '0').substring(0, 12)}',
  'ticker': ticker,
  'displayName': name,
  'avatarUrl': null,
  'price': price,
  'changeAbs': abs,
  'changePct': pct,
  'state': state,
  'badges': badges,
  'sparkline': <String>['99.00', price],
  'isMine': mine,
  'myPosition': position == null ? null : {'side': position, 'quantity': '12'},
};

/// `GET /exchanges/{id}/market` at 9:41 pm Sydney.
Map<String, Object?> marketJson({
  String marketState = 'OPEN',
  String asOf = '2026-10-24T10:41:00Z',
  List<Map<String, Object?>>? listings,
}) => {
  'asOf': asOf,
  'marketState': marketState,
  'nextChangeAt': null,
  'exchangeId': testExchangeId,
  'index': {'name': 'Aura Composite', 'value': '103.42', 'changePct': '1.12'},
  'listings':
      listings ??
      [
        listingJson(
          r'$ANNA',
          'Anna',
          price: '124.10',
          abs: '7.79',
          pct: '6.70',
          position: 'LONG',
        ),
        listingJson(
          r'$JAKE',
          'Jake',
          price: '101.90',
          abs: '-10.50',
          pct: '-9.34',
        ),
        listingJson(r'$NATE', 'Nathan', mine: true),
      ],
  'queuedEventsCount': 0,
  'tradingEnabled': true,
};
