# Aura Exchange

The iPhone app for Aura Exchange, a play-money social stock market where every
friend is a listed stock and prices move on things that happen to them.

It's Flutter, made from `nathan-tolley/flutter-ios-template`. GitHub builds the
unsigned `.ipa`, and you install it for free with Sideloadly. The server is a
separate project; this app talks to it only through the `/v1` contract in
`api/openapi.yaml`.

| Where | What |
|---|---|
| `CLAUDE.md` | Working rules for this repo |
| `docs/aura/` | Decisions, plan, API contract rules, screens, roadmap and progress |
| `design/` | The Graphite design system and the reference screens to match |
| `api/openapi.yaml` | A synced copy of the API's contract (the API repo owns it) |
| `.github/workflows/ios-release.yml` | Run by hand: a GitHub macOS runner builds the branch you pick into an unsigned `.ipa` and publishes it as a GitHub Release. Pushing does nothing. |

Bundle ID: `io.github.nathantolley.auraexchange`. Never change it, or updates
won't keep their data.

## Make a release

1. On GitHub, go to **Actions → iOS release → Run workflow**.
2. Pick the **branch** to build.
3. Optionally type a **version** like `1.2.0`. Leave it blank to use `version:`
   from `pubspec.yaml`. Tick **pre-release** for test builds.
4. Click **Run workflow**. In a few minutes the release appears under
   **Releases** with the `.ipa` attached.

Releases are tagged `v<version>.<run number>`, e.g. **`v1.2.0.37`**. The run
number keeps every release unique, and the app shows the same version (1.2.0)
and build number (37) in Settings.

## Install on your iPhone (Windows)

**One-time setup**
1. Install [iTunes](https://www.apple.com/itunes/download/win64) and iCloud
   using the links on [sideloadly.io](https://sideloadly.io). Use the web
   versions, **not** the Microsoft Store versions.
2. Install [Sideloadly](https://sideloadly.io).
3. Plug in the iPhone, unlock it, and tap **Trust**.
4. On the iPhone, open Settings → Privacy & Security → **Developer Mode**, turn
   it on, and let the phone restart.

**Each install**
1. Download the `.ipa` from the release. Open Sideloadly, drag the file in,
   pick your iPhone, enter your Apple ID, and click **Start**.
2. The first time only: on the iPhone, go to Settings → General → **VPN &
   Device Management**, tap your Apple ID, then tap **Trust**.

## Good to know

- Free signing lasts **7 days**. Re-sign the same `.ipa` to renew it; your data
  stays. Sideloadly's **AutoRefresh** does this for you while the PC is on.
- A free Apple ID allows **3 sideloaded apps** per device and about 10 new
  bundle IDs a week.
- Push notifications, iCloud and in-app purchases need the paid Apple Developer
  Program.
