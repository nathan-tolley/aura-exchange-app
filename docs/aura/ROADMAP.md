# App roadmap

Work top to bottom. Tick a box only when its check passes, and `flutter analyze` and `flutter test` are clean. The live state (current step, next action, open questions) is in `PROGRESS.md`.

## A0: Set up the repo

- [x] Create the repo from the template.
  - Preferred: `gh repo create nathan-tolley/aura-exchange-app --public --template nathan-tolley/flutter-ios-template --clone`, run in `C:\Users\natha\OneDrive\Desktop\Personal\Programming Projects\The Aura Exchange\`. It must be public, because macOS minutes are free for public repos.
  - If `gh` isn't installed or signed in, ask Nathan to click **Use this template** on GitHub, then clone it there.
  - *2026-10-24: the local repo is made (cloned from the template's `1268d28`). Nathan created the public GitHub repo from it and pushed `main` (`39234c4`).*
- [x] Give the app its identity (template README, "Start a new app"):
  - `pubspec.yaml`: `name: aura_exchange`.
  - `Info.plist`: `CFBundleDisplayName` = `Aura Exchange`; add `UIUserInterfaceStyle` = `Dark`; register the URL scheme `aura`.
  - `project.pbxproj`: replace every `io.github.nathantolley.myApp` with `io.github.nathantolley.auraexchange`, including the RunnerTests IDs. This ID must never change afterwards.
- [x] Copy the handoff in:
  - `CLAUDE.md` to the root.
  - `DECISIONS.md`, `PLAN.md`, `API-CONTRACT.md`, `SCREENS.md` and `ROADMAP.md` to `docs/aura/`.
  - Handoff `app/design/` to `design/`.
  - `openapi.yaml` to `api/openapi.yaml`, plus a new `api/SYNCED.md`.
  - Start `docs/aura/PROGRESS.md` (see `CLAUDE.md` → Progress and resuming).
  - Commit this on its own.
- [x] `flutter create --platforms web .` for the dev preview only. Make sure the iOS workflow still builds just iOS.
- [x] Add the packages from `CLAUDE.md`, the folder layout, and `analysis_options` with stricter lints (`prefer_const_constructors`, `always_declare_return_types`, `avoid_print`).
- [x] Workflow: pass `--dart-define=API_BASE_URL=${{ vars.API_BASE_URL }}` to `flutter build ios`.
- **Check:**
  - `flutter analyze` and `flutter test` are clean.
  - `flutter run -d chrome` shows a blank `bg` screen.
  - Prism is serving `api/openapi.yaml` on :4010.
  - One manual run of **iOS release** produces an `.ipa`.
  - *2026-10-24: the first three pass. `flutter analyze` and `flutter test` are clean; the web build shows a blank `#0b0c0e` screen at 390×844 with no console errors; Prism serves the spec on :4010 (`/health` 200, forced codes work, but see `CONTRACT-REQUESTS.md` #1). The iOS release run waits on the GitHub repo and Nathan's OK.*

## A1: Design foundation

- [x] `lib/design/tokens.dart` from `design/aura_tokens.dart`, plus `tool/gen_tokens.dart` that regenerates it from `design/tokens.json`.
  - *2026-10-24: the generator reproduces the handoff's file exactly, also writes `lib/design/icon_paths.dart` from `design/icons.json`, and `test/tool/gen_tokens_test.dart` fails if either output drifts.*
- [x] Fonts in `assets/fonts/`, declared in `pubspec.yaml`:
  - Newsreader (Regular, Italic)
  - JetBrains Mono (Regular, Medium)
  - Inter (Regular, Medium, SemiBold), for web preview and goldens only
  - *2026-10-24: as variable fonts from google/fonts, which cover every weight listed. Their OFL licenses are registered with `LicenseRegistry`, and `test/flutter_test_config.dart` loads the fonts so goldens render real type.*
- [x] `AuraIcon`, painting `design/icons.json`.
  - *2026-10-24: all 34 icons and the filled star were rendered and checked by eye against `design/reference/components/Icon.png`. Its golden comes with the other goldens, once fonts are in.*
- [x] Every component in `design/COMPONENTS.md` as `lib/design/widgets/aura_<name>.dart`, with the same props.
  - *2026-10-24: all 31, plus `AuraNavRow`, `AuraActionButton` and `AuraStatGrid` (the spec sheet's grid). Props follow COMPONENTS.md in Dart form: `onPressed: null` disables, tones are `AuraTone`. Each has a golden next to its reference (0.03–4.5% of pixels differ) and behavior tests. The inside-a-sheet variants come from `AuraSheetScope`, with a golden of W05's pattern (`SheetInside.png`).*
  - Get exact values from `design/reference/web/components.css` (`.ax-<name>`).
  - Implement the inside-a-sheet variants (lifted surfaces, `lineStrong` hairlines, disabled button on `raised2`).
- [x] State Gallery: a debug-only route listing every component in every state it supports.
  - *2026-10-24: `/gallery` (`aura://gallery` on the phone) in debug builds: all 31 components, 59 states, with fixtures from the drawn screens, and live controls where a component is interactive. `test/design/gallery_test.dart` builds every state on its own.*
- [x] Goldens for every component state.
  - *2026-10-24: 30 goldens drawn like the reference previews (`test/goldens/components/`), one of the inside-a-sheet variants, and one per State Gallery section with every state labelled (`test/goldens/gallery/`, 31 images). They're tagged `golden`; the macOS release run skips them.*
- **Check:** each component golden, put side by side with `design/reference/components/<Name>.png`, matches in spacing, size, color and type (Inter stands in for SF Pro).
  - *2026-10-24: done. Each golden was diffed against its reference and both were looked at. Share of pixels that differ by more than 24 levels: IconButton 0.03%, Avatar 0.04, SegmentedControl 0.20, Tabs 0.21, Sparkline 0.33, ImpactDisc 0.39, SearchField 0.42, Tag 0.48, SectionHeader 0.51, Stepper 0.53, Countdown 0.64, Tape 0.68, PriceChange 0.78, ChartTooltip 0.79, Toast 0.84, RangeBar 0.92, TabBar 0.95, StatCard 1.04, QuoteCard 1.26, Money 1.28, SlideToConfirm 1.50, Button 1.60, Sheet 1.70, StockRow 1.84, Receipt 2.02, EmptyState 2.10, StatusChip 2.73, NavCard 2.75, HeroCard 2.81, Banner 4.52. What's left is antialiasing, the sparkline data (approximated; the references don't give it) and the 12.5 pt offset noted in `NOTES.md`, to recheck against the screens in A3.*

## A2: API layer

- [x] Generate the client from `api/openapi.yaml` into `lib/api/generated/` (`swagger_parser.yaml` config).
  - *2026-10-25: 10 Retrofit clients, 53 requests, 119 models, committed (the iOS workflow doesn't run generators). Two generator name collisions are fixed in the config (see `NOTES.md`); `test/api/generated_test.dart` decodes the spec's examples.*
- [x] `client.dart`:
  - base URL from `API_BASE_URL`
  - bearer token from secure storage
  - on 401 `AUTH_EXPIRED`, refresh once and replay; otherwise go to sign-in
  - `X-App-Version` / `X-App-Build` on every request
  - an idempotency-key helper bound to user actions
  - *2026-10-25: `AuraClient` (`lib/api/client.dart`) with `AuthSession` and the Keychain store (`lib/api/session.dart`). Refreshes are single-flight (rotating refresh tokens), the replay keeps its `Idempotency-Key`, a rejected refresh signs out (`session.signedIn` turns false; the router's redirect to sign-in comes with that screen in A4), and an unreachable refresh keeps the tokens and reports offline. Version and build come from the bundle (`package_info_plus`). `IdempotencyKey` is created at commit and reused for retries. 14 tests against a fake adapter.*
- [x] `errors.dart`: parse the one error shape. `l10n/strings.dart` builds copy for every code in `API-CONTRACT.md`.
  - *2026-10-25: `ApiError` (code, params, retryable, action, status; `APP_` codes for offline, timeout and a body that isn't the shape) and `guardApi`. `errorCopy()` switches exhaustively over the generated `ErrorCode`, so a sync that adds a code won't compile until it has copy; unknown codes get "Something went wrong" with the code as the reference. All 31 codes have copy, word for word where a screen is drawn (W04, W05, W06, W09, W10, W11, W12, W13). A test checks that API-CONTRACT.md's table and the spec's enum agree. 47 tests.*
- [x] `format/`: money, change, percent, ticker, exchange-local time, relative time and countdown, with unit tests using the examples in `DESIGN.md` → Numbers.
  - *2026-10-24: money, change, percent, impact, tape change, quantity, ticker and countdown were pulled forward into A1 (the components need them), with tests in `test/format/`.*
  - *2026-10-25: `lib/format/time.dart`: the exchange's IANA zone (UTC if unknown), `9:41 pm` clock, `formatMoment` (time alone within 12 h, then weekday, then date), `formatWhen` (relative under an hour, the contract's rule), `formatAgo` (`2 h ago`, W12) and `formatDay` (`tomorrow`, from the exchange's calendar). 8 tests, including daylight saving.*
- [x] `stream.dart`:
  - subscribe per exchange
  - ping every 25 s
  - exponential-backoff reconnect
  - on close code 4401, refresh and reconnect
  - polling fallback every 15 s
  - exposes `connected` for the Delayed state
  - *2026-10-25: `AuraStream` (`lib/api/stream.dart`) behind a small `SocketConnection` seam. A socket that answers nothing for a whole ping interval is replaced; backoff is 1 s doubling to 30 s with ±20% jitter, reset by a good connection; 4401 refreshes through `AuthSession` and reconnects at once (or stays down if that signs out); `StreamReconnected` tells screens to refetch. Messages are parsed from API-CONTRACT.md (the spec has no socket schemas). 13 tests in fake time.*
- [x] A Freshness provider: Delayed when `asOf` is more than 60 s old or the socket is down.
  - *2026-10-25: `lib/data/freshness.dart` (`Freshness`, `liveness()`, a one-second clock) and `marketLivenessProvider` in `lib/data/live_market.dart`. A closed market with the socket up reads "at the close" (W09), not Delayed. The live market is the last `GET /market` with ticks on top, refetched on reconnect and on each `PollDue` while the socket is down; a failed refetch keeps the numbers and records why (`problem`, for W11). Repositories for system, auth, market and trading go through `guardApi`; the stream starts on sign-in and stops on sign-out. 12 tests.*
- **Check:** the repository tests pass against Prism, including forced `Prefer: code=409/422/426/500` responses mapping to the right `ApiError.action`.
  - *2026-10-25: passes. `test/prism/prism_test.dart` (tag `prism`, skipped by default; run `flutter test --tags prism --run-skipped` with Prism up) decodes Prism's examples through the system, market, trading and auth repositories, and forces all 31 codes in API-CONTRACT.md's table (`Prefer: code=…, example=…`), each mapping to its code, status, `action` and `retryable`, with copy that isn't the generic fallback: 36 tests. `AUTH_EXPIRED` runs signed out because Prism's example token can't be replayed (contract request #5); the refresh and replay are covered against a fake server in `test/api/client_test.dart`. All 270 tests pass and `flutter analyze` is clean.*

## A3: Rebuild the 13 drawn worst moments in Flutter

Each screen is driven by fixtures identical to the reference data. These prove the design system in Flutter before the flows are built.

- [x] W01 Rumor about you · W02 Ruling on you · W03 SEC charge · W04 Chapter 7 · W05 Trade rejected · W06 Requote · W07 Margin warning · W08 Liquidated · W09 Home closed · W10 Halted · W11 Home offline · W12 Home IPO day · W13 Exchange down
  - *2026-10-25: all 13 done, through presenters from API-shaped fixtures (or local records where the contract has no shape yet: contract requests #6–#9), each in the State Gallery under Screens. Share of pixels that differ by more than 24 levels: W01 2.15%, W02 2.26%, W03 2.27%, W04 1.95%, W05 1.15%, W06 1.36%, W07 2.42%, W08 2.32%, W09 2.17%, W10 1.90%, W11 2.01%, W12 2.00%, W13 2.57%. On the way, the components moved to where the screens draw them (12.5 pt text, banner, receipt, sheet), and every component golden got closer to its reference (now 0.03–2.81%).*
- **Check:** for each one, open the golden (390×844 @2x) and `design/reference/screens/W##-*.png` side by side. They are near identical apart from the font. Note any deliberate difference in `docs/aura/NOTES.md`.
  - *2026-10-25: passes. Each golden was diffed (`python tool/golden_diff.py diff`) and looked at beside its reference. What's left is Inter against SF Pro (including the hero number sitting 1 pt high) and the approximated sparklines. Deliberate differences, all in `NOTES.md`: W07's "Your short" heading 2 pt high, W05's dimmed price 2 pt low (the stock header follows W10), W13's note 2 pt high, and W13's footnote lead-in, which waits on Nathan.*

## A4: Phase 1 flows (every state in `SCREENS.md`)

Build these against Prism first, then switch to the real API as each endpoint lands (`ROADMAP.md` in the API repo).

- [x] Onboarding: sign in (email code: sent, wrong, expired, offline) · join from invite (`aura://invite/CODE`: valid, expired, full) · your IPO (consent, ticker check, taken, listed) · create an exchange (name, timezone and hours, invite, waiting for friends)
  - *2026-10-25: all built over one `OnboardingScaffold` (the W08/W13 pattern), 26 states in the State Gallery with goldens (S01a–e, S02a–f, S03a–f, S04a–i), plus the launch problems (S24a–d). Flows run end to end through the real router against a fake server: sign in from scratch, create an exchange through to your IPO, and an invite link while signed out (sign in, join, IPO). Against Prism, sign-in works through `/auth/email/verify`; `/me` then waits on contract request #5 (a "…" in Prism's example token). Against the live API the browser is blocked by CORS (contract request #10). New: `AuraTextField`, `AuraCodeField`, `AuraSkeleton`; `AuraStockRow` without a price.*
- [x] Home (default, loading, IPO day, closed, offline) with the tape, the hero, File an event / Trade, the banner and the watchlist
  - *2026-10-25: `HomeScreen` over the live market, the portfolio and the exchange. Default and loading are new goldens (S05a, S05b); closed, offline and IPO day are W09, W11, W12. Driven end to end against a fake server (numbers, skeletons first, IPO day, offline at launch with Try again). IPO day's joined and invited rows wait on contract request #11; the watchlist's order has no endpoint, so it's positions first.*
- [x] Market list (sorted, halted rows, search, no results)
  - *2026-10-25: the Market tab, S06a–f in the gallery with goldens (plus loading and offline). Sorted by today's change; search on names and tickers; one banner by severity; shared row tags and market chip.*
- [x] Stock page (default, your own stock with no trade bar, halted, closed with indicated price, rumor pending, delisted) with a scrubbable chart and ruling markers; stock overview
  - *2026-10-25: `StockScreen` (`/stock/:id`): S07a–i and S08b in the gallery with goldens (default, your own, closed with indicated price, rumor pending, delisted, offline, chart loading, tape, analyst; the overview with no events), W10 when halted for a vote. `AuraChart` scrubs with a tooltip and a haptic at rulings; ranges 1D/1W/1M/SZN; the price follows the exchange's ticks.*
- [x] Trade sheet (buy, sell, short with liquidation price, cover, limit in extended hours, stop-loss) → outcomes (quote expiring, requote with the difference, rejected cash / size / short cap, filled receipt + toast, resting order)
  - *2026-10-25: `TradeSheet` over the stock page, driven by `TradeFlow`: S09a–f and S10a–g in the gallery with goldens, W05 (rejected cash) and W06 (requote) reached live. Tested against a fake server: a fill, Retry after offline reusing the trade's key, a stale quote requoting with `previousQuoteId` and a new key, the fix setting the allowed quantity, a resting limit order.*
- [ ] File an event (compose, pick subject, receipts upload, self-filing note, daily limit, discard) → filing status (SENDING with a 30 s unsend, RUMOR, RULED, HALTED, VOIDED)
  - *2026-10-25: built except receipts upload (S11a–f, S12a–f in the gallery with goldens). Photo receipts need the `image_picker` plugin, a question for Nathan; the box stays open until they're in.*
- [x] Rumor (teaser, co-sign or cap, insider notice, countdown) · ruling (votes, conflicted, correction) · news-halt vote (countdown, result)
  - *2026-10-25: S13a–c, S15a–e and S17a–b in the gallery with goldens, plus W01, W02 and W10 driven by live events. `/events/:id` chooses your filing, about you, halted (the stock page) or the public view. W02's statement, super-injunction and appeal rows aren't wired yet (NOTES.md).*
- [x] Tape (all, filtered, empty, unread) · notifications inbox (grouped by stock, quiet hours, empty)
  - *2026-10-25: the Tape tab and `/notifications`, S18a–e and S19a–d in the gallery with goldens; live tape and notifications from the stream; the bell's unread badge and the tape dot on Home.*
- [x] Portfolio (positions and cash, open orders, empty) · margin warning sheet · liquidated receipt
  - *2026-10-26: the Portfolio tab (S20a–e with goldens), W07 live from your short, Cover at a quantity. W08 is built and in the gallery (A3) but can only be fed live once contract request #7 sends a liquidation's settlement; until then a liquidated position opens its stock page.* *2026-10-28: W08 is live from `Position.liquidation` (draft.7), with S22a for the receipt before its tape line is found.*
- [x] You (listing, stats, super-injunctions left) · settings (notification prefs, quiet hours, opt out of being listed)
  - *2026-10-26: the You tab and `/settings`, S30a–c and S31a–e in the gallery with goldens; prefs save as you toggle and revert if they fail; opting out ends in the slide.*
- [x] App-wide: closed / halted / offline banners, the update-required screen, the exchange-down screen, skeleton loading everywhere
  - *2026-10-26: banners by severity on every price screen; the update screen over everything on any `UPDATE_REQUIRED`; W13 or the problem screen when a first load fails, a down banner (S23a) when the exchange goes down after numbers were shown; skeletons on every screen that loads.*
- **Check:** every state is reachable in the State Gallery and has a golden. Each flow works end to end against Prism, and then against the real API.
  - *2026-10-26: partly passes. Every built state is in the State Gallery with a golden: 119 screen states (S01–S31 plus the 13 drawn W screens, which stay within A3's diffs) and all 38 components. Every flow runs end to end through the real router and repositories against a fake server in widget tests (sign in, create an exchange, invite, join from a link, IPO, Home, trade with requote and retry, file and unsend, rumors, rulings and votes, tape, inbox, portfolio, settings, the update takeover): 637 tests, analyze clean. Against Prism in Chrome, sign-in works through `/auth/email/verify`, and everything after it stops at `/me` because Prism's example token can't be sent in a header (contract request #5). Against the live API, Chrome is blocked by CORS (contract request #10). Still open: photo receipts when filing (they need the `image_picker` plugin: Nathan's call), and W02's statement, super-injunction and appeal actions.*

## A5: On the phone

- [ ] Point a release build at the cloud API (repo variable `API_BASE_URL`), run **iOS release**, and sideload it.
- [ ] Run the break-it checklist on the device:
  - airplane mode mid-trade
  - stale quote
  - liquidation
  - empty exchange
  - halted stock
  - closed market
  - a brutal roast
  - text size at maximum
  - VoiceOver on the trade flow

  Every case must land on a designed screen.
- **Check (Gate 1, with the API):** 5–8 friends use sideloaded builds for a full week.
