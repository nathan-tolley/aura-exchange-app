# Aura Exchange design system: Graphite (for Flutter)

Aura Exchange is a play-money stock market for one friend group: every member is a listed stock, and prices move on the dumb things that happen to them. The joke only works if the app looks like a serious trading app. So the interface is quiet, exact and expensive-looking, and the comedy lives in the words.

**Graphite** is the only theme. It is dark only, and the app forces dark mode.

What's in this folder:

| File | What it is |
| --- | --- |
| `DESIGN.md` | This file: the rules. Read it before building any UI. |
| `COMPONENTS.md` | The 37 documented components (plus `AuraNavRow` and `AuraActionButton`, covered under NavCard and HeroCard), one Flutter widget each (`Aura<Name>`) |
| `aura_tokens.dart` | Colors, spacing, radii, sizes and type styles, generated from `tokens.json`. Copy it to `lib/design/tokens.dart`. |
| `tokens.json` | The source of truth for tokens |
| `icons.json` | The 34 line icons as 24-unit SVG paths, which are the exact icons in the references |
| `reference/screens/` | The 13 drawn worst-moment screens (390×844 @2x) plus a contact sheet. **Match these.** |
| `reference/components/` | A rendered preview of each component |
| `reference/web/` | The web implementation the references were drawn with. Use it for exact values. |

Live versions (Nathan can open them): design system https://claude.ai/artifact/HTvUeLfUk5wZrkDwLrCTNt · screens https://claude.ai/artifact/LfP7JBH1MaZMu2g3vJbttL

## The seven rules

Every screen follows these. They exist because the first version broke all of them and looked machine-made.

1. **One background.** Everything sits flat on `bg`. No gradients, glows, vignettes or spotlights anywhere, including charts.
   - The one exception is functional: the ticker tape fades out at its right edge.
2. **Structure comes from type, space and hairlines, not boxes.**
   - The big number sits on the background.
   - Stats are a spec sheet with a `line` above each value. Lists are rows with `line` dividers.
   - A screen has at most one or two filled shapes (a banner, a sheet), never a grid of cards.
3. **Color is information.**
   - `up`, `down` and `warn` appear only on numbers, chart lines and glyphs, always paired with an arrow, sign or word.
   - Buttons, avatars, tags and backgrounds are never colored.
4. **Depth without shadows.**
   - Elevation is a lighter surface (`raised`, `raised2`).
   - The only floating thing, the tab bar, uses a blur (`BackdropFilter`).
   - No `BoxShadow`, no `elevation`, no bevels, no glossy circles.
5. **Two voices, two typefaces.** The system sans (SF Pro on iOS) is the app. The **serif is the Analyst only**: headlines, notes, Fed statements and company profiles.
6. **Big numbers are light.** Money uses the display style at regular weight (w400). Size, not boldness, makes it important. The `A$` and the cents step back to `inkTertiary`.
7. **One signature.** The monospaced ticker tape (`AuraTape`) at the top of Home and Market is the brand's visual signature. Keep it, and don't add others.

## Flutter specifics

- **App shell.**
  - Use `CupertinoApp` (or `WidgetsApp`) with `brightness: Brightness.dark`.
  - Don't use Material widgets for visible UI (no `Card`, `ElevatedButton`, `AppBar`, `FloatingActionButton`, ripples).
  - Everything visible is an `Aura*` widget or plain layout.
- **Theme.** Expose the tokens through `AuraColors`, `AuraType`, `AuraSpace`, `AuraRadius` and `AuraSize` (static consts in `tokens.dart`). Don't use `ThemeData` color schemes.
- **Fonts.** `pubspec.yaml` must declare:
  - `Newsreader`: Regular 400, plus Italic. Bundled from Google Fonts, OFL.
  - `JetBrainsMono`: Regular 400 and Medium 500. OFL.
  - The sans is left as the platform default (null `fontFamily`), which is San Francisco on iOS. In the web or desktop preview it falls back to Inter (bundle Inter too, or accept Roboto).
- **Tabular figures** on every number: `fontFeatures: [FontFeature.tabularFigures()]`. They are already in every `AuraType` style.
- **Minus sign.** Negative numbers use U+2212 `−`, never a hyphen.
- **Dynamic Type.** Use `MediaQuery.textScalerOf(context)`. Layouts reflow rather than truncate numbers. Test at 1.0, 1.3 and 2.0.
- **Hairlines** are 1 logical pixel: a `Container` with a `Border(top: BorderSide(color: AuraColors.line))`, or a `DecoratedBox`. Inside sheets, use `lineStrong`.
- **Corners** use `BorderRadius.circular`. A continuous-corner shape (`ContinuousRectangleBorder`, about 1.6× the radius) matches iOS better on filled shapes.
- **Icons.**
  - Paint the paths in `icons.json` with a `CustomPainter`: parse them with `path_drawing`'s `parseSvgPathData`. Use a 24-unit viewBox, round caps and joins, and stroke width 1.7 (2.0 in buttons). They exactly match the references.
  - Don't mix in Material Icons. The SF Symbol equivalents (below) are for a later native pass.
- **Haptics.** `HapticFeedback.lightImpact` (chart snaps, segment changes), `mediumImpact` (slide-to-confirm lands, trade filled), `heavyImpact` (margin warning, liquidation, rejection).
- **Reduce Motion.** Check `MediaQuery.disableAnimationsOf(context)`. When it's on, numbers swap without rolling, the tape stops, and the ruling reveal is instant.

## Voice

The app has two registers, and every string belongs to exactly one.

**The Analyst** speaks on the tape, in headlines and notes, in notifications about stocks, in the opening and closing bell, in Fed statements and in company profiles. It writes deadpan wire-service prose about absurd events, set in the serif. The server writes this text; the app only displays it.

- Finance words for life events: guidance, headwinds, priced in, divestiture, management shakeup.
- Roast the event, never the person's identity, body or anything they can't change.
- Headlines ≤ 90 characters and notes ≤ 280. Sentence case in the app; the tape strip uppercases.

**The app** speaks wherever money, rules or errors are involved: buttons, confirmations, banners, settings and errors. It is plain, exact and in the second person. All of it lives in one strings file, built from API error `code` + `params`.

- Say what happened, then the fix: "You're A$229.91 short. You have A$2,264.50. Buy 18 instead, sell something, or wait for tomorrow's stimulus check."
- Buttons are a verb in sentence case: Buy, Short more, File an event, Cover all. Never OK or Submit.
- A disabled control always says why, right next to it.
- No exclamation marks, no emoji.

The rule over both: **funny where the market is, clear where your money is.**

## Numbers

- Money is `A$` plus two decimals (`AuraMoney`). On big numbers the `A$` and the cents are `inkTertiary`. Never round, and never drop the `A$`. Parse with `Decimal`, never `double`.
- Change is arrow + sign + color together (`AuraPriceChange`): `↑ +7.79 (+6.70%)`, `↓ −10.50 (−9.34%)`. Zero has no arrow.
- The tape uses filled triangles (▲ ▼) in mono. Nothing else does.
- Tickers are `$` plus an uppercase name of 3–5 letters. Times are in the exchange's timezone with lowercase am/pm. Countdowns are `m:ss`.
- Impact scores are signed integers from −30 to +30.
- Prices shown while offline or after the close carry their age: "Delayed · as of 9:41 pm". This is driven by the API's `asOf` and `marketState`.

## Color

| Token | Use |
| --- | --- |
| `bg` | The only background |
| `raised` | One step up: search, banners, sheets, the slider track, the disabled button on `bg` |
| `raised2` | Two steps up: secondary buttons, the selected segment, avatars, tooltips, toasts, the tab bar; banners, the slider and disabled buttons **inside sheets** |
| `line` / `lineStrong` | Hairlines on `bg` / inside sheets, the tab bar edge, ghost button outlines |
| `ink` / `inkSecondary` / `inkTertiary` | Primary text / body and Analyst notes / labels, timestamps, cents and `A$` |
| `inkFaint` | Dotted lines, chevrons and disabled labels only, never text people need to read |
| `up` / `down` | Price direction and nothing else. The one fill exception is the slide knob on shorts and bankruptcy (`down`). |
| `warn` | Time or risk: halts, margin, expiring quotes, extended hours |
| `onInk` / `onUp` | Labels on ink fills (primary and Buy buttons) / glyphs on the down knob |

- Primary and Buy buttons are `ink` with `onInk` labels. Secondary buttons are `raised2`. Ghost buttons are transparent with a `lineStrong` outline.
- Rumors and "unconfirmed" states have no color of their own: they are neutral text with a countdown.

## Type

All styles are in `AuraType`.

- **Numbers** (display): `display` once per screen; `price` in stock headers; `impact` for ruling scores.
- **Analyst** (serif): `headline` for a headline that is the point of the screen; `quote` for notes in `inkSecondary`, never boxed and never with a quote bar.
- **Interface** (sans):
  - `title` (17 w600)
  - `heading` (15 w600; section headings stay small, never 20pt or larger)
  - `rowTitle`
  - `body`
  - `value` (spec-sheet values)
  - `button`
  - `footnote` (12.5; labels and metadata)
  - `caption` (chart axes only)
- **Tape** (mono): `tape`, `countdown`.

## Layout

- 16pt side gutter. The status bar area is 52pt in the references. Groups are separated by 16–24pt of space, not by containers.
- Headers have back or close on the left and at most one status chip or two bare glyph buttons on the right, each with a 44pt hit area.
  - The header row has −10pt horizontal margins so glyphs optically align with the gutter.
- **Home**, top to bottom:
  1. Tape
  2. Search + bell
  3. Net worth (`AuraHeroCard`)
  4. One row with "File an event" (primary) and "Trade" (secondary)
  5. Banner (if any)
  6. Watchlist
  - There is no four-icon action row.
- The tab bar floats 30pt above the bottom, centered, with no fade behind it. Content scrolls under its blur. The Sell / Buy bar sits in the same place on stock pages.
- Rows are 64pt with `line` dividers. Avatars are 36pt monograms on `raised2` until a member uploads a photo.
- Radii: `md` (12) for the few filled shapes; `sm` (8) for segments and tooltips; `sheet` (16) for sheet tops; full capsules only for buttons, the tab bar, avatars and the slider.

## Charts

Draw charts with a `CustomPainter`; no chart library, so they look exactly like this.

- One 1.5pt line in `up` or `down`, by the selected range's direction. No area fill and no glow.
- The previous close is a dotted `inkFaint` line.
- Scrubbing shows:
  - a 1pt `inkTertiary` crosshair
  - an `ink` dot ringed in `bg`
  - an `AuraChartTooltip`
  - a light haptic at each ruling marker
- Ruling markers are small `ink` dots on the line; their tooltip says the impact ("−18 ruling").
- Ranges are always 1D, 1W, 1M, SZN.
- Sparklines in rows are 72×30 with a dotted baseline at the previous close.

## States

Every screen is built in every state it can be in before it's done (see `shared/SCREENS.md`). Banner severity is down > warn > offline > neutral; only the most severe shows.

| State | How it looks |
| --- | --- |
| Loading | `raised` skeleton blocks at the real layout's sizes; no shimmer with Reduce Motion. Never a full-screen spinner. |
| Empty | `AuraEmptyState`: why it's empty and the one action that fills it |
| Closed / pre / after hours | `AuraStatusChip` plus a neutral `AuraBanner` saying when it reopens and what's queued. Trading switches to limit orders, with the reason shown. |
| Halted | `AuraStatusChip` (warn) and an `AuraCountdown`; trade buttons disabled with the reason under them (W10) |
| Offline | Offline `AuraBanner` with Retry; every price stamped "as of …"; actions disabled (W11) |
| Rejected | Down `AuraBanner` with the exact amount and the fix as its action (W05) |
| Success | `AuraToast` with Undo or View; an `AuraReceipt` for anything that moved money |
| Worst moments | Roasted, margin call, liquidated, SEC charge, bankrupt (W01–W08). Same flat ground. The number (`display` or `impact`, in `down`) carries the weight, the Analyst's words follow in the serif, then an `AuraReceipt` and an `AuraNavCard` of your moves. |

## Motion and haptics

- Prices roll digit by digit (200 ms). No color flashes.
- Sheets use the iOS spring (`CupertinoSheetRoute`, or a custom `DraggableScrollableSheet` with the grabber).
- The ruling reveal fades in the headline, then counts the impact up.
- Haptics: light on chart snaps and segment changes; medium when `AuraSlideToConfirm` lands or a trade fills; heavy on margin warnings, halts, rejection and liquidation.

## Accessibility

- All text is ≥ 4.5:1 (each color's contrast is in `tokens.json`). `inkFaint` is never text people need to read.
- Direction is never color alone. `AuraPriceChange` has `Semantics(label: 'Up 7.79 (6.70%)')`.
- Every glyph button has a semantics label and a 44pt hit area. Avatars and sparklines are `ExcludeSemantics`; the row already says it.

## Icons

The names map to SF Symbols for a future native pass.

| Icon | SF Symbol |
| --- | --- |
| back / close / arrow | `arrow.left` / `xmark` / `chevron.right` |
| search / bell / star / alarm | `magnifyingglass` / `bell` / `star` / `alarm` |
| trade / file / short / vote | `arrow.up.arrow.down` / `doc.badge.plus` / `chart.line.downtrend.xyaxis` / `checkmark.square` |
| home / market / tape / portfolio / you | `house` / `chart.bar` / `newspaper` / `chart.pie` / `person` |
| eyeOff / wifiOff / clock / alert | `eye.slash` / `wifi.slash` / `clock` / `exclamationmark.triangle` |
| chat / hide / gavel / shield | `text.bubble` / `eye.slash` / `scalemass` / `shield` |
| filter / expand / line / candles | `arrow.left.arrow.right` / `arrow.up.left.and.arrow.down.right` / `chart.xyaxis.line` / `chart.bar.xaxis` |
| bolt / trophy / lock / plus / minus | `bolt` / `trophy` / `lock` / `plus` / `minus` |

## Tokens

`tokens.json` is the source. `aura_tokens.dart` was generated from it. If a token changes:

1. Change `tokens.json`.
2. Regenerate the Dart file. Keep a small `tool/gen_tokens.dart` that does what the handoff's generator did: colors, space, radius, size and type styles.
3. Never hand-edit colors in widgets.
