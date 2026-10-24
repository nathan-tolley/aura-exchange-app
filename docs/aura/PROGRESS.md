# Progress

The live log for this repo. A fresh session reads "Now" first (see `CLAUDE.md` → Progress and resuming).

## Now

- Step: A1 → fonts (branch `a1-design-foundation`). A0 is done locally; its GitHub items wait on Nathan.
- State: done (Nathan OK'd the download on 2026-10-24)
- Next action: golden harness (`test/support/golden.dart`: 420 pt preview at 2×, content 358 pt wide from x 16), `dart_test.yaml` with a `golden` tag, release workflow runs `flutter test --exclude-tags golden`; then component batch 1. The A1 order (each its own commit):
  1. `tool/gen_tokens.dart`: `design/tokens.json` → `lib/design/tokens.dart` (must reproduce the committed file exactly) and `design/icons.json` → `lib/design/icon_paths.dart`.
  2. `lib/format/` basics pulled forward from A2 (money split into `A$`/whole/cents, U+2212 minus, change string), unit-tested with the `DESIGN.md` → Numbers examples. `AuraMoney` and `AuraPriceChange` need them.
  3. `AuraIcon` (CustomPainter, 24-unit viewBox, 1.7 stroke, round caps).
  4. Fonts, once Nathan OKs the download: google/fonts variable TTFs (Newsreader + Italic, JetBrains Mono, Inter), weights through the `wght` axis. On web and in goldens a `DefaultTextStyle` supplies Inter; iOS keeps SF.
  5. Components, exact values from `design/reference/web/components.css`, in batches: text primitives (Money, PriceChange, Tag, StatusChip, Countdown, ImpactDisc, Avatar, IconButton) → controls (Button, SlideToConfirm, Stepper, SegmentedControl, Tabs, SearchField) → structure (SectionHeader, StatCard, RangeBar, Receipt, NavCard/NavRow, QuoteCard, Banner, EmptyState, Toast) → composites (Sparkline, ChartTooltip, StockRow, HeroCard, Tape, TabBar, Sheet). Inside-sheet variants included.
  6. State Gallery at a debug-only `/gallery` route.
  7. Goldens at @2x with real fonts loaded in `test/flutter_test_config.dart`, each compared with `design/reference/components/<Name>.png`. Tag them `golden`, and have the release workflow run `flutter test --exclude-tags golden`, because Windows-rendered goldens won't match the macOS runner pixel for pixel.
- Uncommitted work: none
- Waiting on Nathan:
  - **Create the GitHub repo.** Creating the public repo `nathan-tolley/aura-exchange-app` was blocked by Claude Code's auto-mode permission check, so this repo exists only locally (made from the template's commit `1268d28`, no remote). When you're happy to publish, run these from this folder. They create the repo empty, then push `main` first so it becomes the default branch:
    `gh repo create nathan-tolley/aura-exchange-app --public --source . --remote origin`
    `git push -u origin main`
    Don't use "Use this template" on GitHub now: it would start with its own first commit, unrelated to this history.
  - **First push and first iOS release run.** Both need your OK (the A0 check includes one manual run of iOS release).
  - **Contract request #1** (`docs/aura/CONTRACT-REQUESTS.md`): named error examples in the spec, so Prism can return `QUOTE_STALE`, `UPDATE_REQUIRED` and the rest. For the API session; not blocking the app.
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
- 2026-10-24 · A1 · Fonts: Newsreader (+ Italic), JetBrains Mono and Inter variable TTFs from google/fonts with OFL licenses (registered in `main.dart`); tests load them; `auraBaseTextStyle()` as the app's default text style · (this commit)
