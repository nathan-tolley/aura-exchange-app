# Notes

Decisions made while building that `DESIGN.md`, the references and `DECISIONS.md` don't spell out. Newest last. If one of these turns out to matter for the game or the contract, it moves to `DECISIONS.md`.

- **2026-10-24 · iPhone is portrait only.** Every drawn screen is 390×844 portrait, and nothing in the plan needs landscape. `Info.plist` keeps the iPad list as the template had it.
- **2026-10-24 · `aura://` deep links.** `Info.plist` registers the `aura` scheme and sets `FlutterDeepLinkingEnabled`, so go_router receives `aura://invite/CODE` as the route `/invite/CODE`.
- **2026-10-24 · No icon fonts.** `cupertino_icons` is removed and `uses-material-design` is false. Every glyph is an `AuraIcon` painted from `design/icons.json`.
- **2026-10-24 · `API_BASE_URL` can be empty.** The release workflow always passes `--dart-define=API_BASE_URL=` from the repo variable, so an unset variable arrives as `''`. In A2, `client.dart` must treat `''` as "not set" and fall back to a default, rather than building URLs on an empty base.
