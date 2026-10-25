# Progress

The live log for this repo. A fresh session reads "Now" first (see `CLAUDE.md` → Progress and resuming).

## Now

- Step: A4 → sign-in checks, then create an exchange (branch `a4-flows` off `main`)
- State: in progress; the shell and sign-in are built
- Plan for A4, one commit each, in this order (Gate 0's path first): (1) shell: router with the sign-in redirect, `/me` and the current exchange, onboarding redirects, the tab shell, the sheet route with the `scrim` barrier, lifecycle (stream stops in the background, screens refetch on resume); (2) sign-in (email, code sent, wrong, expired, offline) with `AuraTextField` + `AuraCodeField`; (3) create an exchange (name, timezone and hours, invite, waiting for friends); (4) join from invite; (5) your IPO; then Home live, market, stock, trade, file, events, tape and notifications, portfolio, you and settings, app-wide states, as ROADMAP.md lists them. Check sign-in against the live API after (2).
- Next action: check sign-in against Prism in the browser (release web build, see NOTES.md), then create an exchange (name, timezone and hours, invite, waiting for friends).
- Uncommitted work: none
- How to compare: `python tool/golden_diff.py diff GOLDEN REFERENCE` gives the share of differing pixels and a side-by-side image (look at it); `bands` lists where content sits, in points, for measuring the drawn screens. Component goldens are 840 px wide and now 0.03–2.81% from their references; screens are 780×1688 (`expectScreen`), Home at about 2%.
- Lessons: 12.5 pt text goes through `auraLiftFootnote()`. Build screens as a view over a view-model plus a presenter from API payloads; fixtures are API-shaped JSON. `AuraSheetScope` (`lib/design/surface.dart`) lifts fills and hairlines inside sheets; use it for every raised fill and hairline. Put a style on `Text(style:)` or `Text.rich(style:)`, never only on an inner `TextSpan`, or the sans family is lost. `Semantics(excludeSemantics: true)` on a control must restate `onTap`. Control labels use `auraControlText()`. Hairlines are `foregroundDecoration`. Colors with meaning use `AuraTone`. Never `dart format lib` or `dart format .`: name your own files. Never write a doc through PowerShell's `Set-Content` (it adds a BOM and mangles non-ASCII); edit with the Edit tool or Python. It reformats the generated token files (the drift test fails) and `lib/api/generated` (123 files); if it happens, rerun `dart run tool/gen_tokens.dart` and `git checkout -- lib/api/generated`.
- Waiting on Nathan:
  - **First iOS release run.** The GitHub repo exists (public, created by Nathan on 2026-10-24); `main` was pushed through `b21f58f` on 2026-10-25. Later pushes and the A0 check's one manual run of iOS release still need your OK.
  - **Contract request #2** (`docs/aura/CONTRACT-REQUESTS.md`): `nextStimulusAt` on `INSUFFICIENT_CASH`, so W05 can say "tomorrow's stimulus check" without the app copying the schedule. Not blocking; the copy falls back to "the next stimulus check".
  - **Contract request #9**: the "about you" screens' game numbers (denial penalty, rating change, super-injunctions per season) and an SEC case schema (W01–W03). Not blocking; presenters take them as inputs.
  - **Contract request #8**: Chapter 7's terms on `Portfolio` (W04). Not blocking; a local `BankruptcyOffer` stands in.
  - **Contract request #7**: a liquidation's settlement on `Position` (W08). Not blocking; a local `Liquidation` record stands in.
  - **Contract request #6**: a refused quote that still carries its numbers (W05 needs the receipt and `maxQuantity` together). Not blocking; the presenter takes a `Quote` plus the rejection.
  - **Contract request #5**: ASCII example tokens, so a refresh against Prism can be replayed. Not blocking.
  - **Contract requests #3 and #4** (`docs/aura/CONTRACT-REQUESTS.md`): `changeAbs` on ticks (the app derives it meanwhile), and whether the server sends a tick at least every 60 s in PRE, AFTER and HALTED (otherwise quiet periods read Delayed). Not blocking.
  - **W13's footnote** says "You'll get a notification when it's back", which the app can't do without push. Keep it, or change the lead-in (for example "This screen checks again by itself", with the screen polling `/health`)?
  - Not blocking yet: the open questions and the three design-pass rules in `docs/aura/DECISIONS.md`.

## Log

One line per finished step: date · step · what · commit.

- 2026-10-24 · A0 · Local repo cloned from `flutter-ios-template` (`1268d28`). GitHub repo not created yet (see Waiting on Nathan). Local Flutter 3.47.7 matches `FLUTTER_VERSION`.
- 2026-10-24 · A0 · Identity: `aura_exchange`, "Aura Exchange", `io.github.nathantolley.auraexchange`, dark only, `aura://` scheme, portrait · `5e7e6f6`
- 2026-10-24 · A0 · Handoff copied in: `CLAUDE.md`, `docs/aura/`, `design/`, `api/openapi.yaml` + `SYNCED.md`, this file · `334a327`
- 2026-10-24 · A0 · Web platform for the Chrome preview only (the iOS workflow still builds just iOS); web shell named and on `bg` · `49247a7`
- 2026-10-24 · A0 · Packages (Riverpod 3, go_router 18, dio 5, web_socket_channel, flutter_secure_storage, decimal, intl, timezone, path_drawing, uuid, json_serializable, swagger_parser), `lib/` + `test/` layout, stricter lints, dark `CupertinoApp.router` on `bg`; `cupertino_icons` and Material icons removed. Analyze and test clean · `6254b93`
- 2026-10-24 · A0 · iOS release passes `--dart-define=API_BASE_URL` from the repo variable `API_BASE_URL` (via `env`); started `docs/aura/NOTES.md` · `d859277`
- 2026-10-24 · A0 · Checks: analyze and test clean; the web build shows blank `bg` at 390×844; Prism serves `api/openapi.yaml` on :4010. Logged contract request #1 (error examples) · `c149ea9`
- 2026-10-24 · A1 · `tool/gen_tokens.dart`: tokens.json → `lib/design/tokens.dart` (identical to the handoff's), icons.json → `lib/design/icon_paths.dart` (`AuraIcons` enum); drift test · `dd0817a`
- 2026-10-24 · A1 · `lib/format/`: money (parts, U+2212), change, percent, impact, tape change, quantity, ticker, countdown; 14 unit tests from `DESIGN.md` → Numbers · `965cfbe`
- 2026-10-24 · A1 · `AuraIcon` (CustomPainter from the generated paths, stroke weight in viewBox units, filled variant, decorative unless labelled); all 34 checked by eye against `Icon.png` · `5be5258`
- 2026-10-24 · A1 · Fonts: Newsreader (+ Italic), JetBrains Mono and Inter variable TTFs from google/fonts with OFL licenses (registered in `main.dart`); tests load them; `auraBaseTextStyle()` as the app's default text style · `71ec383`
- 2026-10-24 · A1 · Golden harness (2× capture, `golden` tag, release workflow skips goldens), base text tracking and even leading to match the references, and components batch 1: Money, PriceChange, Tag, StatusChip (+ `glass`), Countdown, ImpactDisc, Avatar, IconButton, with goldens and behavior tests · `be7b1c8`
- 2026-10-24 · A1 · Components batch 2: Button, SlideToConfirm, Stepper, SegmentedControl, Tabs, SearchField (+ `AuraSheetScope`), goldens within 0.4–2.3% of the references, behavior tests (slider confirms once, stepper floor, segments, disabled semantics) · `0c3d509`
- 2026-10-24 · A1 · Components batch 3: SectionHeader, StatCard (+ AuraStatGrid), RangeBar, Receipt, NavCard/NavRow, QuoteCard, Banner, EmptyState, Toast; shared `AuraTone`; control-label text, zero-space hairlines and Newsreader opsz 16 to match the references; goldens 0.2–4.5%; behavior tests · `91ac6d2`
- 2026-10-24 · A1 · Components batch 4: Sparkline, ChartTooltip, StockRow, HeroCard (+ AuraActionButton), Tape (loops, stops with Reduce Motion), TabBar, Sheet; inside-sheet golden; goldens 0.3–2.8%; behavior tests (69 tests in all) · `e2bd02b`
- 2026-10-24 · A1 · State Gallery at `/gallery` (debug only): 31 components, 59 states, every state tested on its own (131 tests in all) · `c3c24a3`
- 2026-10-24 · A1 · A1 check: 30 reference goldens within 0.03–4.52%, plus 31 State Gallery goldens covering every state; A1 boxes ticked · (this commit)
- 2026-10-25 · Sync · Contract `1.0.0-draft.1` → `1.0.0-draft.5` (API `aura-v1` at `7212276`): `api/openapi.yaml` and `docs/aura/API-CONTRACT.md`, 31 error codes; Prism serves it. The GitHub repo exists (Nathan), so A0's first box is ticked · (this commit)
- 2026-10-25 · A2 · Generated client (swagger_parser + Retrofit + json_serializable) from draft.5: 10 clients, 53 requests, 119 models; fixed two generator name collisions (`Side`, `Error`); decode test from the spec's examples · (this commit)
- 2026-10-25 · A2 · `client.dart`: config (`''` → mock), app version/build headers, bearer from the Keychain, single-flight refresh and replay on `AUTH_EXPIRED`, `IdempotencyKey`; `errors.dart` parses the error shape (`ApiError`, `guardApi`); Riverpod providers; 14 client tests · (this commit)
- 2026-10-25 · A2 · `format/time.dart`: exchange zone, clock, moment, relative (`formatWhen`, `formatAgo`) and day words, 8 tests · (this commit)
- 2026-10-25 · A2 · `l10n/strings.dart`: copy for all 31 error codes (exhaustive over `ErrorCode`), local and unknown codes, freshness labels; doc/spec parity test; contract request #2 (`nextStimulusAt`) · (this commit)
- 2026-10-25 · Sync · Contract → `1.0.0-draft.6` (named error examples; contract request #1 done). Client regenerated (version only) · (this commit)
- 2026-10-25 · A2 · `stream.dart`: subscribe per exchange, 25 s ping with dead-socket detection, backoff reconnect, 4401 refresh, 15 s polling fallback, `connected`, message parsing; 13 fake-time tests · (this commit)
- 2026-10-25 · A2 · Data layer: `Freshness` + `liveness()`, the live market (REST + ticks, refetch on reconnect and `PollDue`), system/auth/market/trading repositories, the stream following sign-in, Riverpod retry off; contract requests #3 and #4 · (this commit)
- 2026-10-25 · A2 · A2 check: `test/prism/` (opt-in tag) passes against Prism, 36 tests including all 31 forced codes; only connection errors read as offline (`APP_UNEXPECTED` otherwise); errors unit tests; contract request #5. 270 tests, analyze clean · (this commit)
- 2026-10-25 · A2 · Merged `a2-api-layer` into `main` (`e8690b7`); A3 plan written into Now · (this commit)
- 2026-10-25 · A3 · Screen scaffold (`expectScreen`, `tool/golden_diff.py`, Screens in the State Gallery) and Home: W09 2.17%, W11 2.01%, W12 2.00%; 12.5 pt text lifted 2 pt and the banner fixed in the components (all touched component goldens closer); 277 tests · (this commit)
- 2026-10-25 · A3 · Trade sheet: W05 1.08%, W06 1.21% (ticket and requote from `Quote` + `ApiError`); `scrim` token (generator reads `#rrggbbaa`); receipt text 1 pt up with a line under the total, sheet title 11/13 pt; contract request #6 · (this commit)
- 2026-10-25 · A3 · W10 halted: 1.90% (stock page from `ListingDetail` + `Halt` + `EventSummary`); `StockHeader` chip 3 pt lower and price 2 pt lower, as W05 and W10 draw them · (this commit)
- 2026-10-25 · A3 · W07 short near liquidation 2.42%, W08 liquidated 2.32%; `large-title` token and `auraLargeTitle()`; `AuraStatGrid.rowGap`; `ActionBar` and `BannerModel` shared; tape quotes added by screens; contract request #7 · (this commit)
- 2026-10-25 · A3 · W04 Chapter 7 offer 1.95% (`Portfolio` + local `BankruptcyOffer`); `TopBar` shared; contract request #8 · (this commit)
- 2026-10-25 · A3 · W01 rumor about you 2.15%, W02 ruling on you 2.26%, W03 SEC charge 2.27% (from `Event`, `Ruling`, `Votes`, `Appeal`; a local `SecCharge`); contract request #9 · (this commit)
- 2026-10-25 · A3 · W13 exchange down 2.57%; `AuraIconTile` (component 32), `alert-title` token, `auraDisplayTitle()`; A3 check passes: all 13 screens 1.15–2.57% from their references · (this commit)
- 2026-10-25 · A3 · Merged `a3-worst-moments` into `main` · (this commit)
- 2026-10-25 · A4 · Contract request #10: CORS for the web preview (the live API's preflight answers 404, and responses carry `Cross-Origin-Resource-Policy: same-origin`) · `4a54aa8`
- 2026-10-25 · A4 · App shell: `lib/router.dart` (sign-in and onboarding redirect, five-tab `StatefulShellRoute`, routes for the screens to come), `AuraSheetRoute` with the scrim, `/me` and the current exchange (`lib/data/me.dart`), lifecycle (stream stops in the background; resume and reconnect fire `refetchSignalProvider`); 15 tests · (this commit)
- 2026-10-25 · A4 · Components 33 and 34: `AuraTextField` and `AuraCodeField` (COMPONENTS.md, gallery goldens, 7 behavior tests); fields no longer paint Cupertino's disabled fill (W12 1.99%) · (this commit)
- 2026-10-25 · A4 · Sign-in (S01a–e: email, code sent, wrong code, expired, offline): `OnboardingScaffold`, controller with per-action keys, presenters, gallery states and goldens for every gallery screen; 15 tests including a full flow through the router · (this commit)
