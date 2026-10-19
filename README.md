# Flutter iOS template

A plain Flutter app that GitHub builds into an iPhone app (`.ipa`). You
install it on your own iPhone for free with Sideloadly. You don't need a Mac
or a paid Apple Developer account.

## What's different from `flutter create`

| File | What it does |
|---|---|
| `.github/workflows/ios-release.yml` | When you run it by hand, a GitHub macOS runner builds the branch you pick into an unsigned `.ipa` and publishes it as a GitHub Release. Pushing does nothing. |

Everything else is a normal `flutter create --platforms ios` app.

## Start a new app

1. On GitHub, open this repo and click **Use this template** → **Create a new
   repository**. Make it **public**: macOS build minutes are free for public
   repos.
2. Clone it, then give the app its own identity:
   - `pubspec.yaml`: change `name: my_app`.
   - `ios/Runner/Info.plist`: change `CFBundleDisplayName` (the name under the
     icon).
   - `ios/Runner.xcodeproj/project.pbxproj`: replace every
     `io.github.nathantolley.myApp` with a unique bundle ID, such as
     `io.github.nathantolley.coolapp`. Keep it the same forever, or app
     updates won't keep their data.
3. Build your app in `lib/`.

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
