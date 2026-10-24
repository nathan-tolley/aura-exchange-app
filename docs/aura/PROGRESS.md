# Progress

The live log for this repo. A fresh session reads "Now" first (see `CLAUDE.md` → Progress and resuming).

## Now

- Step: A0 → packages, folder layout, stricter lints, dark `CupertinoApp` on a blank `bg` screen
- State: done
- Next action: A0 → workflow passes `--dart-define=API_BASE_URL` from the repo variable; then the checks (Chrome shows blank `bg`, Prism on :4010)
- Uncommitted work: none
- Waiting on Nathan:
  - **Create the GitHub repo.** Creating the public repo `nathan-tolley/aura-exchange-app` was blocked by Claude Code's auto-mode permission check, so this repo exists only locally (made from the template's commit `1268d28`, no remote). When you're happy to publish, run this from this folder; it creates the repo empty and pushes `main`:
    `gh repo create nathan-tolley/aura-exchange-app --public --source . --remote origin --push`
    Don't use "Use this template" on GitHub now: it would start with its own first commit, unrelated to this history.
  - **First push and first iOS release run.** Both need your OK (the A0 check includes one manual run of iOS release).
  - Not blocking yet: the open questions and the three design-pass rules in `docs/aura/DECISIONS.md`.

## Log

One line per finished step: date · step · what · commit.

- 2026-10-24 · A0 · Local repo cloned from `flutter-ios-template` (`1268d28`). GitHub repo not created yet (see Waiting on Nathan). Local Flutter 3.47.7 matches `FLUTTER_VERSION`.
- 2026-10-24 · A0 · Identity: `aura_exchange`, "Aura Exchange", `io.github.nathantolley.auraexchange`, dark only, `aura://` scheme, portrait · `5e7e6f6`
- 2026-10-24 · A0 · Handoff copied in: `CLAUDE.md`, `docs/aura/`, `design/`, `api/openapi.yaml` + `SYNCED.md`, this file · `334a327`
- 2026-10-24 · A0 · Web platform for the Chrome preview only (the iOS workflow still builds just iOS); web shell named and on `bg` · `49247a7`
- 2026-10-24 · A0 · Packages (Riverpod 3, go_router 18, dio 5, web_socket_channel, flutter_secure_storage, decimal, intl, timezone, path_drawing, uuid, json_serializable, swagger_parser), `lib/` + `test/` layout, stricter lints, dark `CupertinoApp.router` on `bg`; `cupertino_icons` and Material icons removed. Analyze and test clean · (this commit)
