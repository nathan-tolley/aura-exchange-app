# Components

Every screen is built from these, and only these. Each one becomes **one Flutter widget named `Aura<Name>`** (e.g. `AuraMoney`, `AuraReceipt`) in `lib/design/widgets/`, with the same props as named here (Dart camelCase). If a screen needs something that isn't here, add it to this list and to the state gallery first, then use it. Never build one-off UI inside a screen.

Exact pixel values for each component (padding, sizes, colors per state) are in `reference/web/components.css` (class `.ax-<name>`); the web implementation in `reference/web/components.js` shows the structure. Rendered previews are in `reference/components/<Name>.png`.

## AuraMoney

Every amount of Aura Bucks: `A$` + whole part in the current text color, cents in `ink-tertiary`.

- Provide `value` (a number). Optional `size`: `display` (net worth, one per screen), `price` (stock header), `sm`; default is row size (15pt medium).
- `approx` adds "≈" for indicated prices that haven't traded yet (the opening gap).
- Never round to whole Aura Bucks and never drop the `A$`; tabular figures keep columns steady while prices tick.
- Don't color money. Direction belongs to `PriceChange` next to it.

Preview: [Money.png](reference/components/Money.png)

## AuraPriceChange

The only way to show direction: arrow, sign and color, always together, so it reads without color.

- Provide `abs` and/or `pct` (numbers; sign decides direction). Optional `period` ("today", "this season"), `size` (`sm` in rows, `lg` in headers). No pills or tinted backgrounds.
- Format is fixed: `↑ +7.79 (+6.70%)`, `↓ −10.50 (−9.34%)`. Real minus sign, two decimals, percent in parentheses after the amount.
- Zero shows no arrow, in `ink-secondary`.
- Screen readers hear "Up 7.79 (6.70%) today": the arrow is never read aloud.

Preview: [PriceChange.png](reference/components/PriceChange.png)

## AuraCountdown

One countdown for everything with a clock: quotes (15 s), rumors (10 min), unsend (30 s), halts and votes (30 min), the open.

- Provide `time` ("6:42") and optional `label` ("Ruling in"); `tone: 'warn'` turns the digits `warn` when time or money is at risk.
- Digits are SF Mono so the label doesn't jitter. At zero it's replaced by the result, never left at 0:00.

Preview: [Countdown.png](reference/components/Countdown.png)

## AuraImpactDisc

A ruling's final impact score (−30 to +30) as a number, not a badge: `impact` style in `up` or `down`, with a small label under it.

- Provide `delta` and `label` (Loss, Gain, Lore).
- Sits at the right of the ruling header or beside the headline. Never inside a circle or a fill.

Preview: [ImpactDisc.png](reference/components/ImpactDisc.png)

## AuraAvatar

A listing's face. The member's photo when they've uploaded one; otherwise their initial on `raised-2` in `ink-secondary`.

- Provide `initial`; `trend` is accepted but never colors the avatar (rule 3: color is information, and an avatar isn't).
- 36pt in rows, 40pt in headers.
- Decorative: the ticker next to it carries the name for VoiceOver.

Preview: [Avatar.png](reference/components/Avatar.png)

## AuraTag

One or two words of context after the name in a row, as quiet text after a middle dot: "Anna · Holding".

- Provide the text; optional `tone`: `down` (SEC) and `warn` (Halted, Indicated) are the only ones that color. Everything else is `ink-tertiary`.
- Never a pill, never a number. One tag per row; the stronger one wins: SEC > Halted > Rumor > Short > Holding.

Preview: [Tag.png](reference/components/Tag.png)

## AuraStatusChip

The shared status vocabulary: a small dot and a word, no pill. The API's status enum uses the same words.

- Provide `status`: `open`, `pre`, `after`, `closed`, `halted`, `delayed`, `rumor`, `ruled`, `voided`, `sending`, `filled`, `resting`, `canceled`, `liquidated`, `sec`, `beat`, `miss`. Optional `label` adds detail ("Closed · opens 7:00 am").
- Market states carry the dot; object states are just the word.
- Only `open`, `filled`, `beat` (up), `halted`, `delayed`, `pre`, `after` (warn) and `liquidated`, `sec`, `miss` (down) take color. Never invent a new word for an existing state.

Preview: [StatusChip.png](reference/components/StatusChip.png)

## AuraTape

The ticker tape: a monospaced strip of every listing's price and move, pinned under the status bar on Home and Market. It's the app's signature; nothing else in the interface is monospaced except countdowns.

- Provide `items`: [{ticker, price, pct}], in market-cap order. On iPhone it scrolls slowly; with Reduce Motion it stays still and swipes.
- Arrows are filled triangles here (▲ ▼) because the tape is terminal-style; everywhere else uses `PriceChange`.

Preview: [Tape.png](reference/components/Tape.png)

## AuraIcon

Stand-in line icons for the web previews. On iPhone every one of them is an SF Symbol (names in the README's Iconography section).

- Provide `name`; optional `size` (default 20) and `weight`. Icons take the current text color.
- 1.7pt strokes, rounded caps and joins. Use the `.fill` symbol variant only for the active tab and a starred stock.

Preview: [Icon.png](reference/components/Icon.png)

## AuraIconButton

Bare glyph buttons for headers: back, close, alerts, watchlist, notifications. No circle, no fill: just the SF Symbol in `ink`, with a 44pt hit area.

- Provide `icon` and `label` (required: it's the VoiceOver name). Optional `badge` (shows as a small `down` dot; the count is in the label), `filled` (starred), `size: 'sm'` for an inline `ink-tertiary` glyph.
- At most three per header: one left, two right.

Preview: [IconButton.png](reference/components/IconButton.png)

## AuraButton

Capsule buttons. Large (54pt) for the one decision a screen is for, medium (44pt) elsewhere. Buttons never carry up/down color.

- `variant`: `primary` and `buy` (both `ink` fill, `on-ink` label: Buy, Cover, File an event), `secondary` (`raised-2`: Sell, Short, Trade), `ghost` (outlined), `danger` (`down` outline, for Declare bankruptcy only). `size`: `lg` | `md`. Optional `icon`, `block`, `disabled`.
- One `primary`/`buy` per screen. Labels are a verb in sentence case.
- A disabled button always has a line of text saying why, right next to it.
- Anything that moves money finishes with `SlideToConfirm`, not a second button.

Preview: [Button.png](reference/components/Button.png)

## AuraSlideToConfirm

The last step before anything that moves money: buy, sell, short, cover, declare bankruptcy.

- Provide `label` ("Slide to buy 12 $ANNA"); `tone: 'down'` gives the knob the `down` fill for shorts and bankruptcy, the one place a fill carries color.
- Sits under the order summary in a sheet. Success haptic when it lands; VoiceOver users double-tap.

Preview: [SlideToConfirm.png](reference/components/SlideToConfirm.png)

## AuraStepper

The share-count stepper at the top of every trade sheet: minus, a big light number, plus.

- Provide `value` and an optional `note` ("shares at about A$124.10"). Tapping the number opens the keypad; holding minus or plus repeats.
- The number uses the display weight (400, not bold), like every big number in the app. Minus disables at 1; plus never disables, the sheet explains why a quantity can't be afforded instead.

Preview: [Stepper.png](reference/components/Stepper.png)

## AuraSegmentedControl

Chart ranges and other mutually exclusive views in one pill track.

- Provide `options` and `value`; `label` names the group for VoiceOver.
- Ranges are always 1D, 1W, 1M, SZN, ALL, in that order.
- Two to five options; more than five becomes `Tabs` or a menu.

Preview: [SegmentedControl.png](reference/components/SegmentedControl.png)

## AuraTabs

Sections inside one screen: the stock page's Overview, Tape, Holders, Analyst.

- Provide `items` and `value`. Up to four, equal width.
- Tabs switch content in place; they never navigate away or open sheets.

Preview: [Tabs.png](reference/components/Tabs.png)

## AuraSearchField

The pill search field at the top of Home and Market.

- Optional `placeholder` (default "Search friends or tickers…") and `value`.
- Searches people, tickers and headlines; results group in that order.

Preview: [SearchField.png](reference/components/SearchField.png)

## AuraSectionHeader

A section title with an optional status chip and a "View all" link.

- Provide `title`; optional `status`/`statusLabel` (a `StatusChip`) and `action` (link text).
- Titles are one or two words, sentence case: Stats, About, Watchlist, Your moves.

Preview: [SectionHeader.png](reference/components/SectionHeader.png)

## AuraTabBar

The floating tab bar: Home, Market, Tape, Portfolio, You, as glyphs on system material, with a small dot under the active one.

- Provide `active`; optional `tapeBadge` (unread rulings, shown as a dot).
- Floats 30pt above the bottom over a fade to `bg`; hides on sheets and while filing. No drop shadow; on iPhone it's `.ultraThinMaterial` with a 0.5pt `line-strong` edge.

Preview: [TabBar.png](reference/components/TabBar.png)

## AuraStatCard

One line of a spec sheet: a label over a value, with a hairline above. No box.

- Provide `label` and `value`; optional `trailing` + `trailingTone`, `tone` to color the value (only for direction or risk), `wide` to span the row.
- Lay them out in a 2- or 3-column grid with 10pt column gaps; the hairlines line up into a table.
- Use `RangeBar` for anything with a low and a high, `Receipt` for anything that moved money.

Preview: [StatCard.png](reference/components/StatCard.png)

## AuraRangeBar

Where today's price sits between the season low and high.

- Provide `low`, `high`, `current`; optional `label` (default "Season range") and `note` + `noteTone` ("Near high", "Near low" in `down`).
- The fill is always `up`; position, not color, says where the price is.

Preview: [RangeBar.png](reference/components/RangeBar.png)

## AuraSparkline

Today's path in a row, with a dotted midline.

- Provide `points` (numbers, oldest first); `trend` defaults to last vs first. Optional `width`, `height`, `baseline: false`.
- No axes, no labels, no dots. Detail lives on the stock page chart.

Preview: [Sparkline.png](reference/components/Sparkline.png)

## AuraChart

The stock page's chart (DESIGN.md → Charts), drawn with a `CustomPainter`.

- Provide `points` ([{at, price}], oldest first); optional `previousClose` (the dotted `ink-faint` line on 1D), `markers` ([{at, label, tone}]: rulings as small `ink` dots ringed in `bg`), `trend` (defaults to last vs previous close), `height` (180), `onScrub`.
- One 1.5pt line in `up` or `down` by the range's direction. No fill, no glow, no axes.
- A finger on it shows a 1pt `ink-tertiary` crosshair, an `ink` dot ringed in `bg` and an `AuraChartTooltip` above the point ("−18 ruling" on a marker), snapping to points with a light haptic at each ruling.
- With nothing to draw, it says so ("No trades yet"). VoiceOver hears the range's move.

Added in A4 (2026-10-25) for the stock page; no separate preview.

## AuraChartTooltip

The floating price label on a chart point, with an optional badge for the event behind it.

- Provide `price`; optional `badge` ("+22 ruling", "−18 ruling", "Rumor") and `tone`.
- Appears while a finger is on the chart and on event markers; snaps to points with a light haptic.

Preview: [ChartTooltip.png](reference/components/ChartTooltip.png)

## AuraStockRow

The row for one listing in watchlists, the market list and search results: avatar, ticker, name and tag, sparkline, price and change, on a hairline.

- Provide `ticker`, `name`, `price`, `pct`, `abs`; optional `initial`, `tag`, `tagTone`, `points`.
- Before a listing has traded (an invite's preview of who's listed), leave out `price`, `pct` and `abs`: the row shows who, not what they trade at. (A4, 2026-10-25.)
- 64pt tall with a `line` divider. Tap opens the stock page; long-press opens quick trade.
- Rows sort by what the list is for: the market by % change, a watchlist by the member's order.

Preview: [StockRow.png](reference/components/StockRow.png)

## AuraHeroCard

The one big number at the top of a screen, sitting directly on the background: label, number, change. No card around it.

- Provide `label` and `value`; optional `abs`/`pct`/`period`, `note`, `hideable` (eye button), `approx`, `actions` ([{icon, label}]), `tone: 'down'` for loss screens.
- Home has no action row: one primary "File an event" button and a secondary "Trade" sit under the hero instead. `actions` remains for screens that truly need round shortcuts.
- One hero per screen.

Preview: [HeroCard.png](reference/components/HeroCard.png)

## AuraNavCard

A list of tappable rows (`NavRow`): a bare glyph, title, subtitle, optional trailing note, a small chevron. Hairlines between rows, no container.

- Wrap `NavRow`s (`icon`, `title`, `subtitle`, `trailing`, `trailingTone`) in a `NavCard`. A single row works too (Closing bell recap).
- Subtitles say the consequence: "Hides the story · price hit stays".
- Rows are actions or destinations, never settings toggles.

Preview: [NavCard.png](reference/components/NavCard.png)

## AuraNewsRow

One thing on the tape, in a list: the Tape tab, a stock's tape, the notifications inbox.

- Provide `source` ("$JAKE · Ruling · 2 h ago") and `headline` (the Analyst's, as the server wrote it); optional `movePct` (the move it caused, as a `PriceChange` on the source line), `unread` (a small `ink` dot), `onTap`.
- The headline is the serif at 17/24 in `ink`: it's the Analyst speaking. Hairline under each row, no box.

Added in A4 (2026-10-25) for the tape; no separate preview.

## AuraQuoteCard

The Analyst speaking: notes, Fed statements and company profiles, in the New York serif at `quote` size, `ink-secondary`, with its source line under it.

- Provide `quote` (curly quotes included) and `source`.
- No box, no quote bar, no italics. Under 280 characters. The serif is reserved for the Analyst; nothing else uses it.

Preview: [QuoteCard.png](reference/components/QuoteCard.png)

## AuraReceipt

A receipt for anything that moved money: fills, liquidations, fines, bankruptcy. Label and value rows on hairlines, then a total.

- Provide `rows` ([{label, value, tone?}]) and an optional `total` ({label, value, tone?}). Values are pre-formatted strings.
- Every money-moving outcome screen has one. Fees are their own row, never hidden in a total.

Preview: [Receipt.png](reference/components/Receipt.png)

## AuraBanner

The one filled shape a screen usually gets: what's true right now and what to do about it, on `raised`, with only the glyph in color.

- `tone`: `neutral` (closed, queued), `offline`, `warn` (margin, halts, extended hours), `down` (rejected, liquidated, SEC). Provide `title`; optional `body`, `action`, `icon`.
- Title = what's true. Body = when it changes or the exact numbers. Action = the one fix.
- One banner per screen; the most severe wins (down > warn > offline > neutral).

Preview: [Banner.png](reference/components/Banner.png)

## AuraEmptyState

What a list says when there's nothing in it, always with the next step.

- Provide `title`, `body`, optional `icon` and `action`.
- Say why it's empty and what fills it. In voice, but clear: "No positions yet" / "Your portfolio is all cash. Very conservative."

Preview: [EmptyState.png](reference/components/EmptyState.png)

## AuraIconTile

A glyph on a `raised` rounded square (`md` radius). It heads an empty state (44pt) or a screen that is itself the message, such as the exchange being down (52pt, W13).

- Provide `icon`, optional `size` (44 or 52) and `tone` (`warn` when the tile carries risk; otherwise the glyph is `inkSecondary`).
- Decorative: the title beside it says what it means.

Added in A3 (2026-10-25), extracted from `AuraEmptyState`; no separate preview.

## AuraTextField

A labelled single-line field for the few things the app asks you to type: an email, an exchange's name, a ticker.

- Provide `label` (above the field, and its VoiceOver name); optional `placeholder`, `prefix` (`$` for a ticker, in `ink-tertiary`), `note` and `noteTone`, `readOnly` (an invite link: full ink and selectable).
- The search field's shape at form height (48pt): `raised` (`raised-2` inside sheets), `md` corners, body text with no tracking.
- The note under it is help in `ink-tertiary`, or a problem: `noteTone: 'down'` or `'warn'` colors only its glyph, and the words stay `ink-secondary` (color is information). A field never gets a colored outline.

Added in A4 (2026-10-25) for sign-in and onboarding; no separate preview.

## AuraCodeField

The 6-digit sign-in code: one `raised` cell per digit, the digit in the `price` style (big numbers are light), a short `ink` bar in the next empty cell.

- Provide `controller`; optional `onCompleted` (fires when the last digit lands, so there's no Submit), `note` and `noteTone` (as in `TextField`), `enabled`.
- Typing, pasting and iOS's one-time-code autofill go into one hidden field, so a pasted code fills every cell.
- VoiceOver hears "Sign-in code, 6 digits" and the note.

Added in A4 (2026-10-25) for sign-in; no separate preview.

## AuraSkeleton

Where content is loading, at the content's real size: `raised` blocks (`raised-2` inside sheets) that breathe slowly, and hold still with Reduce Motion. Never a full-screen spinner.

- Provide `height`, optional `width` (fills by default) and `radius` (6; `md` for a field or banner, `full` for an avatar).
- `AuraSkeletonText` stands in for lines of text: a block at the style's cap height on its line height, the last line shorter.
- Decorative for VoiceOver; the screen says it's loading.

Added in A4 (2026-10-25) for loading states; no separate preview.

## AuraToast

Brief confirmation after an action, with one undo or follow-up.

- Provide `message`; optional `icon` and `action` ("Undo", "View").
- Bottom of the screen above the tab bar; disappears after 4 s, or when its countdown ends.
- The unsend window after filing an event is a toast with "Undo" and the 30-second countdown.

Preview: [Toast.png](reference/components/Toast.png)

## AuraSheet

Bottom sheets for focused tasks: the trade ticket, filing an event, voting, statements.

- Provide `title` and children. Medium detent by default, large for filing.
- One primary action at the bottom: a `SlideToConfirm` for money, a `Button` otherwise.
- Swipe down cancels; if something is half-filled, ask "Discard this filing?" first.

Preview: [Sheet.png](reference/components/Sheet.png)
