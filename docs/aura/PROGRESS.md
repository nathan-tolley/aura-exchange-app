# Progress

The live log for this repo. A fresh session reads "Now" first (see `CLAUDE.md` → Progress and resuming).

## Now

- Step: A1 → State Gallery done (branch `a1-design-foundation`). A0 is done locally; its GitHub items wait on Nathan.
- State: in progress
- Next action: the A1 check: review every golden side by side with its reference, record the result in `docs/aura/ROADMAP.md`, tick the goldens box, and look at the gallery in a web build. Then A2 (API layer) on a new branch.
- How to compare: goldens are 840 px wide at 2× like the references. Diff each golden against `design/reference/components/<Name>.png` and look at both. All 30 reference goldens are within 0.03–4.5% differing pixels (antialiasing). See `docs/aura/NOTES.md` for what was matched and the 12.5 pt quirk to recheck in A3.
- Lessons: `AuraSheetScope` (`lib/design/surface.dart`) lifts fills and hairlines inside sheets; use it for every raised fill and hairline. Put a style on `Text(style:)` or `Text.rich(style:)`, never only on an inner `TextSpan`, or the sans family is lost. `Semantics(excludeSemantics: true)` on a control must restate `onTap`. Control labels use `auraControlText()`. Hairlines are `foregroundDecoration`. Colors with meaning use `AuraTone`. Never `dart format` the generated token files.
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
- 2026-10-24 · A1 · Fonts: Newsreader (+ Italic), JetBrains Mono and Inter variable TTFs from google/fonts with OFL licenses (registered in `main.dart`); tests load them; `auraBaseTextStyle()` as the app's default text style · `71ec383`
- 2026-10-24 · A1 · Golden harness (2× capture, `golden` tag, release workflow skips goldens), base text tracking and even leading to match the references, and components batch 1: Money, PriceChange, Tag, StatusChip (+ `glass`), Countdown, ImpactDisc, Avatar, IconButton, with goldens and behavior tests · `be7b1c8`
- 2026-10-24 · A1 · Components batch 2: Button, SlideToConfirm, Stepper, SegmentedControl, Tabs, SearchField (+ `AuraSheetScope`), goldens within 0.4–2.3% of the references, behavior tests (slider confirms once, stepper floor, segments, disabled semantics) · `0c3d509`
- 2026-10-24 · A1 · Components batch 3: SectionHeader, StatCard (+ AuraStatGrid), RangeBar, Receipt, NavCard/NavRow, QuoteCard, Banner, EmptyState, Toast; shared `AuraTone`; control-label text, zero-space hairlines and Newsreader opsz 16 to match the references; goldens 0.2–4.5%; behavior tests · `91ac6d2`
- 2026-10-24 · A1 · Components batch 4: Sparkline, ChartTooltip, StockRow, HeroCard (+ AuraActionButton), Tape (loops, stops with Reduce Motion), TabBar, Sheet; inside-sheet golden; goldens 0.3–2.8%; behavior tests (69 tests in all) · `e2bd02b`
- 2026-10-24 · A1 · State Gallery at `/gallery` (debug only): 31 components, 59 states, every state tested on its own (131 tests in all) · (this commit)
