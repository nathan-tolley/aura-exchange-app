# App roadmap

Work top to bottom. Tick a box only when its check passes, and `flutter analyze` and `flutter test` are clean. The live state (current step, next action, open questions) is in `PROGRESS.md`.

## A0: Set up the repo

- [ ] Create the repo from the template.
  - Preferred: `gh repo create nathan-tolley/aura-exchange-app --public --template nathan-tolley/flutter-ios-template --clone`, run in `C:\Users\natha\OneDrive\Desktop\Personal\Programming Projects\The Aura Exchange\`. It must be public, because macOS minutes are free for public repos.
  - If `gh` isn't installed or signed in, ask Nathan to click **Use this template** on GitHub, then clone it there.
  - *2026-10-24: the local repo is made (cloned from the template's `1268d28`, no remote). Creating the GitHub repo is waiting on Nathan; see `PROGRESS.md`.*
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

## A1: Design foundation

- [ ] `lib/design/tokens.dart` from `design/aura_tokens.dart`, plus `tool/gen_tokens.dart` that regenerates it from `design/tokens.json`.
  - *2026-10-24: `lib/design/tokens.dart` was copied in A0 so the shell could use `AuraColors.bg`. The generator is still to do.*
- [ ] Fonts in `assets/fonts/`, declared in `pubspec.yaml`:
  - Newsreader (Regular, Italic)
  - JetBrains Mono (Regular, Medium)
  - Inter (Regular, Medium, SemiBold), for web preview and goldens only
- [ ] `AuraIcon`, painting `design/icons.json`.
- [ ] Every component in `design/COMPONENTS.md` as `lib/design/widgets/aura_<name>.dart`, with the same props.
  - Get exact values from `design/reference/web/components.css` (`.ax-<name>`).
  - Implement the inside-a-sheet variants (lifted surfaces, `lineStrong` hairlines, disabled button on `raised2`).
- [ ] State Gallery: a debug-only route listing every component in every state it supports.
- [ ] Goldens for every component state.
- **Check:** each component golden, put side by side with `design/reference/components/<Name>.png`, matches in spacing, size, color and type (Inter stands in for SF Pro).

## A2: API layer

- [ ] Generate the client from `api/openapi.yaml` into `lib/api/generated/` (`swagger_parser.yaml` config).
- [ ] `client.dart`:
  - base URL from `API_BASE_URL`
  - bearer token from secure storage
  - on 401 `AUTH_EXPIRED`, refresh once and replay; otherwise go to sign-in
  - `X-App-Version` / `X-App-Build` on every request
  - an idempotency-key helper bound to user actions
- [ ] `errors.dart`: parse the one error shape. `l10n/strings.dart` builds copy for every code in `API-CONTRACT.md`.
- [ ] `format/`: money, change, percent, ticker, exchange-local time, relative time and countdown, with unit tests using the examples in `DESIGN.md` → Numbers.
- [ ] `stream.dart`:
  - subscribe per exchange
  - ping every 25 s
  - exponential-backoff reconnect
  - on close code 4401, refresh and reconnect
  - polling fallback every 15 s
  - exposes `connected` for the Delayed state
- [ ] A Freshness provider: Delayed when `asOf` is more than 60 s old or the socket is down.
- **Check:** the repository tests pass against Prism, including forced `Prefer: code=409/422/426/500` responses mapping to the right `ApiError.action`.

## A3: Rebuild the 13 drawn worst moments in Flutter

Each screen is driven by fixtures identical to the reference data. These prove the design system in Flutter before the flows are built.

- [ ] W01 Rumor about you · W02 Ruling on you · W03 SEC charge · W04 Chapter 7 · W05 Trade rejected · W06 Requote · W07 Margin warning · W08 Liquidated · W09 Home closed · W10 Halted · W11 Home offline · W12 Home IPO day · W13 Exchange down
- **Check:** for each one, open the golden (390×844 @2x) and `design/reference/screens/W##-*.png` side by side. They are near identical apart from the font. Note any deliberate difference in `docs/aura/NOTES.md`.

## A4: Phase 1 flows (every state in `SCREENS.md`)

Build these against Prism first, then switch to the real API as each endpoint lands (`ROADMAP.md` in the API repo).

- [ ] Onboarding: sign in (email code: sent, wrong, expired, offline) · join from invite (`aura://invite/CODE`: valid, expired, full) · your IPO (consent, ticker check, taken, listed) · create an exchange (name, timezone and hours, invite, waiting for friends)
- [ ] Home (default, loading, IPO day, closed, offline) with the tape, the hero, File an event / Trade, the banner and the watchlist
- [ ] Market list (sorted, halted rows, search, no results)
- [ ] Stock page (default, your own stock with no trade bar, halted, closed with indicated price, rumor pending, delisted) with a scrubbable chart and ruling markers; stock overview
- [ ] Trade sheet (buy, sell, short with liquidation price, cover, limit in extended hours, stop-loss) → outcomes (quote expiring, requote with the difference, rejected cash / size / short cap, filled receipt + toast, resting order)
- [ ] File an event (compose, pick subject, receipts upload, self-filing note, daily limit, discard) → filing status (SENDING with a 30 s unsend, RUMOR, RULED, HALTED, VOIDED)
- [ ] Rumor (teaser, co-sign or cap, insider notice, countdown) · ruling (votes, conflicted, correction) · news-halt vote (countdown, result)
- [ ] Tape (all, filtered, empty, unread) · notifications inbox (grouped by stock, quiet hours, empty)
- [ ] Portfolio (positions and cash, open orders, empty) · margin warning sheet · liquidated receipt
- [ ] You (listing, stats, super-injunctions left) · settings (notification prefs, quiet hours, opt out of being listed)
- [ ] App-wide: closed / halted / offline banners, the update-required screen, the exchange-down screen, skeleton loading everywhere
- **Check:** every state is reachable in the State Gallery and has a golden. Each flow works end to end against Prism, and then against the real API.

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
