import 'package:flutter/widgets.dart';

import '../../../api/generated/export.dart' hide Freshness;
import '../../../features/shared/banner_model.dart';
import '../../../features/you/you_view.dart';
import '../../../l10n/strings.dart' show savingFailed;
import '../../widgets/aura_banner.dart';
import 'frames.dart';

// You and Settings (SCREENS.md #30, #31).

final _user = User.fromJson({
  'id': '3f2b8c1e-5d4a-4e7b-9a10-2c6d8e9f0a1b',
  'displayName': 'Nathan',
  'email': 'nathan@example.com',
  'createdAt': '2026-10-24T10:30:00Z',
});

Membership _membership({bool listed = true}) => Membership.fromJson({
  'id': '22222222-0000-4000-8000-000000000001',
  'exchangeId': '7c1d2e3f-0a1b-4c5d-8e9f-a0b1c2d3e4f5',
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
  'superInjunctionsLeft': 2,
});

final _listing = ListingDetail.fromJson({
  'asOf': '2026-10-24T10:41:00Z',
  'marketState': 'OPEN',
  'nextChangeAt': null,
  'id': '11111111-0000-4000-8000-000000000003',
  'ticker': r'$NATE',
  'displayName': 'Nathan',
  'avatarUrl': null,
  'price': '103.40',
  'changeAbs': '3.40',
  'changePct': '3.40',
  'state': 'ACTIVE',
  'badges': <String>[],
  'sparkline': <String>[],
  'isMine': true,
  'myPosition': null,
  'prevClose': '100.00',
  'open': '100.20',
  'dayHigh': '104.10',
  'dayLow': '99.80',
  'seasonHigh': '104.10',
  'seasonLow': '96.20',
  'volume': '260',
  'shortInterestPct': '4.00',
  'borrowFeeDailyPct': '0.10',
  'indicatedPrice': null,
  'indicatedChangePct': null,
  'halt': null,
  'lastTradeAt': '2026-10-24T10:40:00Z',
  'events': <Object?>[],
  'analyst': {
    'rating': 'HOLD',
    'priceTarget': '105.00',
    'note':
        'Fundamentals are steady. We await a catalyst, ideally not a '
        'karaoke one.',
  },
});

Widget _you(YouModel? model) => YouView(
  model: model,
  onStock: _noop,
  onInvite: _noop,
  onSettings: _noop,
  onList: _noop,
  onTab: (_) {},
);

/// S30a: listed: your stock, your stats, super-injunctions left.
Widget youListed() => _you(
  youModel(
    user: _user,
    membership: _membership(),
    listing: _listing,
    live: null,
  ),
);

/// S30b: not listed (opted out, or not yet).
Widget youNotListed() => _you(
  youModel(
    user: _user,
    membership: _membership(listed: false),
    listing: null,
    live: null,
  ),
);

/// S30c: loading.
Widget youLoading() => _you(null);

NotificationPrefs _prefs({bool quiet = false}) => NotificationPrefs.fromJson({
  'holdingMovedPct': '5.00',
  'quietHours': quiet ? {'start': '22:00', 'end': '07:00'} : null,
  'bells': true,
  'disabledTypes': ['PRICE_ALERT'],
});

Widget _settings(NotificationPrefs? prefs, {bool failed = false}) =>
    SettingsView(
      prefs: prefs,
      email: 'nathan@example.com',
      banner: failed
          ? const BannerModel(tone: AuraBannerTone.down, title: savingFailed)
          : null,
      onBack: _noop,
      onType: (_, _) {},
      onBells: (_) {},
      onQuiet: (_) {},
      onOptOut: _noop,
      onSignOut: _noop,
    );

/// S31a: what reaches you.
Widget settingsDefault() => _settings(_prefs());

/// S31b: quiet hours on.
Widget settingsQuiet() => _settings(_prefs(quiet: true));

/// S31c: a setting that didn't save.
Widget settingsFailed() => _settings(_prefs(), failed: true);

/// S31d: loading.
Widget settingsLoading() => _settings(null);

/// S31e: opting out of being listed.
Widget settingsDelist() => sheetOver(
  settingsDefault(),
  const DelistSheet(exchange: 'The Group Chat', onStay: _noop),
);

void _noop() {}
