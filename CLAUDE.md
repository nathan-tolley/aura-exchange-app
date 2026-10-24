# Aura Exchange app: instructions for Claude

This repo is the **iPhone app** for Aura Exchange, a play-money social stock market where each friend is a listed stock and prices move on things that happen to them. It's Flutter, created from Nathan's `flutter-ios-template`. Development happens on Windows. A GitHub macOS runner builds an unsigned `.ipa`, and Nathan installs it with Sideloadly.

The joke only works if this looks and behaves like a serious, premium trading app. **Quality is the point**: every state is designed, every screen uses the same patterns, and the worst moments are handled best.

## Read these first

| File | What it's for |
| --- | --- |
| `docs/aura/DECISIONS.md` | What's settled, what changed, open questions. **Wins over everything else.** |
| `design/DESIGN.md` | The seven visual rules, voice, numbers, color, type, layout, states, motion. **Read before writing any UI.** |
| `design/COMPONENTS.md` | The component set: one `Aura<Name>` widget each, the only building blocks for screens |
| `design/reference/screens/` | 13 drawn screens (W01–W13). Your Flutter versions must match them closely. |
| `docs/aura/SCREENS.md` | All 32 screens, every state each needs, and which endpoints it uses |
| `docs/aura/API-CONTRACT.md` | How the server talks: money as strings, freshness, the error shape, status enums, realtime |
| `api/openapi.yaml` | The endpoints and schemas (a synced copy; see the boundary rules) |
| `docs/aura/PLAN.md` | The full game design, for when you need to know *why* something behaves the way it does |
| `docs/aura/ROADMAP.md` | Milestones for this repo, with checks. Work top to bottom. |

## Progress and resuming (read this on every start)

Sessions can stop at any moment: usage limits, a crash, a closed laptop. Work so that a fresh session can pick up exactly where the last one stopped, from the repo alone.

- **`docs/aura/PROGRESS.md` is the live log.** Its top block is always current:

  ```markdown
  ## Now
  - Step: A1 → AuraButton + its goldens
  - State: in progress | done | blocked (on what)
  - Next action: the very next concrete thing to do
  - Uncommitted work: none | what's in the working tree and why
  - Waiting on Nathan: questions asked and not yet answered
  ```

  Below it is an append-only log: one dated line per finished step, with its commit hash.
- **Before** starting a step, write what you're about to do into "Now". **After** finishing it, tick the box in `ROADMAP.md`, update "Now", and commit the work with both files. Don't leave a finished step uncommitted.
- **Small commits**, one roadmap sub-step each (smaller for a big one). Local commits are free; pushing still needs Nathan's OK.
- **Every step is safe to repeat.** Check before you create: does the GitHub repo, local clone, renamed identity, package, widget or golden already exist? If it does, verify it and move on.
- **On start, and whenever you're asked to resume:**
  1. Read `docs/aura/PROGRESS.md`. If it doesn't exist yet, you're still in A0: follow `KICKOFF-APP.md` in the handoff, checking what's already done (`gh repo view nathan-tolley/aura-exchange-app`, the local clone, the identity rename, the handoff commit) before each step.
  2. Run `git status`, `git branch --show-current` and `git log --oneline -10`.
  3. Compare them. Changes in the tree that "Now" doesn't explain are a half-finished step from a session that was cut off. Read the diff, then either finish it or `git stash push -u -m "interrupted: <what>"` and redo it cleanly. Never discard work.
  4. Re-run the last check (`flutter analyze` and `flutter test`) before building on top of it.
  5. Continue from "Next action".
- Ask questions in chat **and** record them under "Waiting on Nathan", so they survive a cut-off.
- Before anything long (a big refactor, a dependency upgrade, a long run), write the plan into "Now" first.

## The boundary (most important rule)

- The server is a **separate repo** (`aura-api`, a branch of the friend's `Aura-Exchange`). This app knows the server **only** through `/v1` in `api/openapi.yaml`.
  - No shared code.
  - No assumptions about the server's internals.
  - No business rules duplicated here: the server computes prices, liquidation prices, fees, max quantities and statuses. The app displays them.
- **The API repo owns the contract.**
  - `api/openapi.yaml` here is a copy. Never edit it to make the app work.
  - If the app needs something the contract doesn't have, write the request in `docs/aura/CONTRACT-REQUESTS.md` and tell Nathan. Build against a local fixture until it lands.
- To sync after the API changes:
  1. Copy `openapi/v1.yaml` from the API repo to `api/openapi.yaml`.
  2. Regenerate the client.
  3. Fix any compile errors.
  4. Note the sync in `api/SYNCED.md` (date + the API's `CHANGES.md` entry).
- **Develop against the mock** until the real endpoint exists:

```powershell
npx @stoplight/prism-cli mock api/openapi.yaml          # http://localhost:4010
```

  Prism returns the spec's examples. Force a specific response with a header such as `Prefer: code=422` or `Prefer: code=409`; that's how to build the rejection, stale-quote, closed and halted screens without a server.

## Stack and commands

- Flutter (see `FLUTTER_VERSION` in `.github/workflows/ios-release.yml`; keep your local Flutter on the same version), iOS 15+.
- Recommended packages:
  - `flutter_riverpod` (state)
  - `go_router` (routes and `aura://` deep links)
  - `dio` (HTTP)
  - `web_socket_channel`
  - `flutter_secure_storage` (tokens in the Keychain)
  - `decimal` (money)
  - `intl` + `timezone` (exchange-local times)
  - `path_drawing` (icons from `design/icons.json`)
  - `uuid` (idempotency keys)
  - `json_serializable`, and `swagger_parser` to generate the client from the spec (it runs in Dart, so no Java)

```powershell
flutter pub get
flutter analyze                       # must be clean
flutter test                          # unit, widget and golden tests
flutter run -d chrome --web-port 5555 --dart-define=API_BASE_URL=http://localhost:4010
dart run swagger_parser               # regenerate lib/api/generated from api/openapi.yaml
```

- **Previewing on Windows.** The `web` platform is added for development only: run in Chrome with the device toolbar at 390×844. It isn't shipped; the iOS workflow builds only iOS. Fonts differ slightly on web (Inter instead of SF Pro), so judge spacing and layout there, and the final type on the phone.
- **On the phone.**
  1. Push.
  2. In GitHub, run Actions → **iOS release** on the branch.
  3. Download the `.ipa` from the release and sideload it with Sideloadly. See `README.md`.
  - The API URL for device builds comes from `--dart-define=API_BASE_URL`, which the workflow passes from the repo variable `API_BASE_URL`.

## Code layout

```
lib/
  main.dart, app.dart          CupertinoApp, dark only, go_router
  design/
    tokens.dart                generated from design/tokens.json (never hand-edit colors)
    icons.dart                 AuraIcon: paints design/icons.json paths
    widgets/aura_*.dart        one file per component in COMPONENTS.md
    gallery/                   the State Gallery (debug-only route): every component and every screen state, with fixtures
  api/
    generated/                 swagger_parser output; don't edit
    client.dart                dio: base URL, bearer, refresh-on-401, X-App-Version/Build, Idempotency-Key
    errors.dart                ApiError {code, params, retryable, action} parsed from the error shape
    stream.dart                WebSocket: subscribe per exchange, ping 25 s, backoff reconnect, polling fallback
  data/                        repositories + Riverpod providers per resource; Freshness model
  format/                      money (A$, cents split, U+2212 minus), change, tickers, exchange-local time, countdowns
  features/<area>/             screens: onboarding, home, market, stock, trade, events, tape, portfolio, notifications, you, settings, system
  l10n/strings.dart            every user-facing string, including copy built from error code + params
test/
  goldens/                     one golden per component state and per drawn screen
```

## Non-negotiables

- **Only `Aura*` widgets on screen.** No Material `Card`, `AppBar`, `ElevatedButton`, `ListTile`, ripples, `BoxShadow` or gradients. If a screen needs something new, add it to `COMPONENTS.md` and the gallery first.
- **Money is `Decimal`**, parsed from the API's strings. Never `double`.
  - Format through `format/`: `A$12,486.20` with `A$` and cents in `inkTertiary` on big numbers.
  - Change is arrow + sign + color: `↑ +7.79 (+6.70%)`.
  - The minus sign is U+2212.
- **Honest freshness.**
  - Every price screen reads `asOf` and `marketState`.
  - When data is older than 60 s or the socket is down, show "as of 9:41 pm" and the offline or delayed state (W11).
  - Never show stale numbers as live.
- **The server's `message` is never shown.**
  - Map `error.code` + `params` to copy in `l10n/strings.dart` and act on `action` (REQUOTE → show the requote sheet, REDUCE_QUANTITY → offer `maxQuantity`, and so on).
  - Unknown codes get the generic error screen with the reference.
- **Idempotency.** Create the key when the user commits (the slide lands, or File is tapped), and reuse it for retries of that same action.
- **Every state exists.**
  - A screen is done when every state in its `SCREENS.md` row is built, reachable in the State Gallery with fixtures, and covered by a golden.
  - Loading uses skeletons at real sizes, never a full-screen spinner.
  - Disabled controls always say why.
- **Match the references.**
  - For W01–W13, build a golden at 390×844 @2x with the same fixture data as the reference.
  - Open both PNGs and compare spacing, sizes, color and type.
  - Fix differences until they're near identical. Fonts are the only accepted difference: goldens use Inter in place of SF Pro.
- **Voice.** App copy is plain, exact and second person, with a verb on every button and no exclamation marks or emoji. Analyst text (headlines, notes, teasers) comes from the server and is shown as-is in the serif.
- **Accessibility.** Semantics labels on every glyph button and on price changes ("Up 7.79, 6.70 percent"), 44pt hit targets, and layouts that survive text scale 2.0.

## Platform limits right now (free sideloading)

- **No push notifications** (they need the paid Apple program). The Notifications screen is an in-app **inbox** (`GET /me/notifications`), plus live `notification` messages over the socket and a badge on the tab bar.
- **No Sign in with Apple.** Sign-in is by email one-time code.
- **Deep links** use the custom scheme `aura://` (e.g. `aura://invite/JAKE-7F2K`). Universal links need the paid program.
- The app must cope with being force-quit and relaunched often, because there's no background refresh. Refetch on resume.

## Working rules

- Work on short branches off `main`, with small commits that say what and why.
- When a design question isn't answered by `DESIGN.md` or the references, follow the closest drawn screen's pattern and note the decision in `docs/aura/NOTES.md`. Don't invent a new pattern.
- When a game rule is unclear, ask Nathan (write it into `DECISIONS.md` → Open questions). Don't guess.
- Keep `docs/aura/ROADMAP.md` checkboxes current. It's how Nathan sees progress.
