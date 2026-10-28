# Contract requests

What the app needs from `/v1` that the contract doesn't give yet. The API repo owns the contract (`openapi/v1.yaml`), so each request goes to Nathan and the API session. Until one lands, the app builds against a local fixture. Mark a request done with the sync date from `api/SYNCED.md`.

## 1. Named examples for each error code (2026-10-24 · done, synced 2026-10-25 in draft.6)

**What's wrong.** Every error response (`E400` to `E503`) uses the one `Error` schema and has no `examples`. Prism therefore answers every forced status with the same body:

```
Prefer: code=409 | 422 | 426 | 500  →  {"error":{"code":"INSUFFICIENT_CASH", ..., "action":"RETRY"}}
```

So a forced 409 can never be `QUOTE_STALE`, a 426 can never be `UPDATE_REQUIRED`, and even the 422 carries `action: "RETRY"`, where `API-CONTRACT.md` says `INSUFFICIENT_CASH` → `REDUCE_QUANTITY`.

**Why the app needs it.** W05 (rejected), W06 (requote), W09 (closed), W10 (halted) and W13 (exchange down, update required) are built against Prism. The A2 check forces `Prefer: code=409/422/426/500` and expects each to map to the right `ApiError.action`.

**Ask.** Add named `examples` to the shared error responses: one per row of the error table in `API-CONTRACT.md`, with realistic `params`. For example:

- `E409`: `QUOTE_STALE`, `LISTING_HALTED`, `MARKET_CLOSED`, `ORDER_TYPE_NOT_ALLOWED`, `IDEMPOTENCY_MISMATCH`
- `E422`: `INSUFFICIENT_CASH` (with `REDUCE_QUANTITY`), `ORDER_TOO_LARGE`, `SHORT_CAP`, `OPPOSITE_POSITION`, `EQUITY_TOO_LOW`, `DAILY_FILING_LIMIT`, `UNSEND_EXPIRED`
- `E426`: `UPDATE_REQUIRED` · `E429`: `RATE_LIMITED` · `E500`: `SERVER` · `E503`: `MAINTENANCE`
- `E400`, `E401`, `E403` and `E404` the same way

The app then picks one with `Prefer: code=409, example=QUOTE_STALE`. This is additive and changes no shapes.

**Meanwhile.** The app's error-mapping tests use local fixtures copied from the table in `API-CONTRACT.md`.

## 2. When the next stimulus check lands (2026-10-25 · answered, synced 2026-10-28 in draft.7)

**Answered: accepted, served now.** `nextStimulusAt` is in `INSUFFICIENT_CASH`'s params and on `Portfolio` (the next Monday 09:00 in the exchange's timezone). W05 says "tomorrow's" or "Monday's" from it, live as well as in the gallery: the trade sheet now passes the exchange's timezone into the copy.

**What's missing.** W05's rejection says "wait for **tomorrow's** stimulus check". The allowance is a game rule (PLAN.md: A$1,000, Mondays 9 am), and the app mustn't copy game rules, so it can't work out "tomorrow's" or "Monday's" by itself. Nothing in `/v1` says when the next one lands.

**Ask (additive).** Add `nextStimulusAt` (ISO 8601 UTC) to the params of `INSUFFICIENT_CASH`. A `nextStimulusAt` on `Portfolio` would serve the Portfolio screen too, if that's easier; the app would read either.

**Meanwhile.** `lib/l10n/strings.dart` already reads `params.nextStimulusAt` when it's there ("tomorrow's", "Monday's", from the exchange's calendar) and says "the next stimulus check" when it isn't. W05's golden in A3 uses a fixture with the param, so it matches the reference.

## 3. The change amount on ticks (2026-10-25 · answered, synced 2026-10-28 in draft.7)

**Answered: accepted, with `/stream` (Phase 1).** Each `ticks` listing carries `changeAbs` since the previous close (API-CONTRACT.md → Realtime). `LiveMarket` uses it when it's there and still works it out from price and percent when a tick doesn't have it.

**What's missing.** A `ticks` message gives each listing's `price` and `changePct` but not `changeAbs`, which every price row shows (`↑ +7.79 (+6.70%)`, `AuraPriceChange`).

**Ask (additive).** Add `changeAbs` (decimal string, 2 dp) to each listing in `ticks`, like `ListingSummary.changeAbs`.

**Meanwhile.** `LiveMarket` (`lib/data/live_market.dart`) works the amount out from the tick's own price and percent (`price − price × 100 / (100 + changePct)`, rounded half-up to 2 dp). That matches the fixtures (124.10 at +6.70% → +7.79; 101.90 at −9.34% → −10.50), but because the percent is already rounded it can be a cent off the server's figure.

## 4. A heartbeat in quiet market states (2026-10-25 · answered, synced 2026-10-28 in draft.7)

**Answered: accepted, with `/stream` (Phase 1).** Every subscribed exchange gets a `ticks` message at least every 30 s in every market state, with `listings: []` when nothing changed. So the single "older than 60 s → Delayed" rule holds everywhere. The app already moves `asOf` on an empty `ticks` (tested); CLOSED still reads "at the close", as W09 is drawn.

**The question.** The app marks prices Delayed when `asOf` is over 60 s old (API-CONTRACT.md → Freshness). Ticks come "at most every 15 s" and only with the listings that changed. While the market is OPEN the price engine moves every listing every 15 s, so that's fine. But in PRE, AFTER and an exchange-wide HALTED nothing may move for minutes, and the app would show Delayed although nothing was missed.

**Ask.** Either send a `ticks` message (with an empty `listings` array if nothing changed) at least every 60 s to each subscribed exchange in every market state, or say in API-CONTRACT.md that `asOf` only goes stale while OPEN, and the app will treat the other states like CLOSED.

**Meanwhile.** The app follows the contract as written, except that CLOSED reads "at the close" (as W09 is drawn).

## 5. ASCII example tokens (2026-10-25 · answered, synced 2026-10-28 in draft.7)

**Answered: accepted.** `TokenPair`'s examples are now `eyJhbGciOiJIUzI1NiJ9.e30.c2lnbmF0dXJl` and `rt_9d8c4e2a`, so a refresh against Prism can be replayed.

**What's wrong.** `TokenPair`'s examples are `"accessToken": "eyJhbGciOi…"` and `"refreshToken": "rt_9d8c…"`. The `…` (U+2026) can't be sent in an HTTP header, so after Prism answers `POST /auth/refresh`, the client can't replay the request with the new token. It fails before sending.

**Ask.** ASCII examples, e.g. `eyJhbGciOiJIUzI1NiJ9.e30.c2lnbmF0dXJl` and `rt_9d8c4e2a`. No shape change.

**Meanwhile.** The Prism check forces `AUTH_EXPIRED` signed out (no refresh). The refresh and replay are tested against a fake server.

## 6. A refused quote that still shows its numbers (2026-10-25 · answered, synced 2026-10-28 in draft.7)

**Answered: option B, served now.** `INSUFFICIENT_CASH` and `SHORT_CAP` add `price`, `gross`, `feeRate`, `fee` and `total` (for the quantity asked) to their params. Option A was declined: it would turn an existing 422 into a 201. `ORDER_TOO_LARGE` keeps only `maxQuantity`, because an order that large is refused before it's priced. So the app builds W05's receipt from the refusal's params (`refusedReceipt()` in `trade_model.dart`), live and in the gallery, and a too-large order shows the cap and the fix without a receipt (S10b).

**What's missing.** W05 shows a refused trade with its receipt (20 × A$124.10 = A$2,482.00, fee A$12.41, estimated total A$2,494.41) **and** the reason with its fix ("You're A$229.91 short … Buy 18 instead"). Today `POST /quotes` either returns a `Quote` (whose `cashAfter` can be negative, "the trade would be rejected", but which has no `maxQuantity`) or fails with `422 INSUFFICIENT_CASH` (which has `maxQuantity` but no gross, fee or total). Neither answer has both.

**Ask (additive), either of:**
- **A.** On a quote that would be refused, return `201` with the `Quote` plus a `rejection` field in the error shape (`code`, `params`, `retryable`, `action`). The app shows the receipt and the banner from one answer. Preferred.
- **B.** Keep the 422, and add the priced numbers to the params of `INSUFFICIENT_CASH`, `ORDER_TOO_LARGE` and `SHORT_CAP`: `price`, `gross`, `feeRate`, `fee`, `total`.

**Meanwhile.** `tradeTicketModel()` (`lib/features/trade/trade_model.dart`) takes a `Quote` and an optional `ApiError` rejection, which is option A's shape. The W05 fixture supplies both.

## 7. How a liquidation settled (2026-10-25 · answered, synced 2026-10-28 in draft.7)

**Answered: accepted with two changes, filled in Phase 1 (margin).** `Position.liquidation` (the `Liquidation` schema), `null` unless `LIQUIDATED`. It's `feeRate`, not `feeRatePct` (the name `Quote.feeRate` already uses), and `collateral` moved inside it. The local `Liquidation` record is gone: W08 reads the generated one, and `/positions/:id` opens W08 for a liquidated short, with the tape's line once the stock's tape has it.

**What's missing.** W08 is the liquidation receipt: when it happened, the price the stock crossed and the maintenance ratio it fell under, the collateral held, the buy-back (quantity, price, cost), the fee, what came back to your cash, and the realised loss on the trade with its percent. `Position` (status `LIQUIDATED`) gives the collateral and quantity, but nothing in `/v1` gives the settlement. Working it out in the app would copy the server's settlement rules.

**Ask (additive).** On `Position`, when `status` is `LIQUIDATED`, a `liquidation` object: `at`, `triggerPrice`, `maintenanceRatioPct`, `price`, `cost`, `feeRatePct`, `fee`, `returned`, `realizedPnl`, `realizedPnlPct` (decimal strings like the rest). The liquidation notification's deep link can then open `GET /positions/{id}`.

**Meanwhile.** `Liquidation` (`lib/features/portfolio/liquidated_model.dart`) has exactly these fields, and the W08 fixture fills it.

## 8. What Chapter 7 would do (2026-10-25 · answered: deferred to Phase 2)

**Answered: deferred to Phase 2 (bankruptcy).** The shape will be as asked: `minimumEquity`, `resetCash`, `badge`, `tapeHeadline` on `Portfolio` while `canDeclareBankruptcy`. The local `BankruptcyOffer` stays until then.

**What's missing.** W04 offers bankruptcy at the moment of the loss and shows its terms: the minimum to trade (A$100.00), the cash you'd restart with (A$2,000.00), the badge you'd carry until the season ends ("Chapter 7"), and the Analyst's line for the tape. `/v1` has `Portfolio.canDeclareBankruptcy` and `POST /exchanges/{id}/bankruptcy` ("reset to A$2,000 with a badge" in its summary), but none of those values. They're game rules, so the app shouldn't hold them.

**Ask (additive).** When `canDeclareBankruptcy` is true, a `bankruptcyOffer` on `Portfolio`: `minimumEquity`, `resetCash`, `badge`, `tapeHeadline` (the line the tape would run). Or a `GET /exchanges/{id}/bankruptcy` returning the same.

**Meanwhile.** `BankruptcyOffer` (`lib/features/portfolio/bankruptcy_model.dart`) has these fields, and the W04 fixture fills them. The banner's copy is the same `underMinimumCopy()` that `EQUITY_TOO_LOW` uses.

## 9. What the "about you" screens need besides the event (2026-10-25 · answered, synced 2026-10-28 in draft.7)

**Answered, split.** `Membership.superInjunctionsPerSeason` is served now, and W02 reads it ("2 of 3 left"). `Event.denialPenaltyPct` is in the spec (always set, `"20.00"`, filled with the event pipeline in Phase 1), and W01 reads it. `ratingChange` (W02) and the `SecCase` schema (W03) are deferred to Phase 2; W02's rating change stays an input and `SecCharge` stays the stand-in. The API asks one question for Phase 2: can a ruling move the rating by itself, when PLAN.md makes ratings weekly?

**What's missing.** W01–W03 come mostly from `Event`, `Ruling`, `Votes`, `Appeal` and `Membership`, but a few numbers are game rules the app shouldn't hold, and the SEC case has no schema at all:

- **W01:** how much bigger a confirmed hit gets if you deny it ("If it's confirmed, the hit is 20% bigger"). Ask: `denialPenaltyPct` on `Event` while it's a rumor about you, or on the exchange's settings.
- **W02:** the rating's change in the source line ("The Analyst · **Downgrade** · target A$96.00"); `Analyst.rating` is BUY/HOLD/SELL, not the change. Ask: `ratingChange` (`UPGRADE`, `DOWNGRADE`, `REITERATE`) on `Ruling` or `Analyst`. Also how many super-injunctions a season allows ("2 of 3 left"); `Membership.superInjunctionsLeft` gives the 2. Ask: `superInjunctionsPerSeason` on `Membership` or the exchange's settings.
- **W03 (Phase 2):** an `SecCase` schema: `caseNumber`, `status`, `chargedAt`, `headline`, `taken`, `finePct`, the evidence (the event you filed with a short name such as "the gym rumor" and when, the trade with quantity, ticker, time and price, the profit when it ruled, the odds of getting caught), the scandal it filed against you (ticker, impact, move), the appeal deadline, and the clean window in minutes.

**Meanwhile.** The presenters take these as inputs (`lib/features/events/about_you_models.dart`; `SecCharge` is the W03 record) and the fixtures fill them.


## 10. CORS for the web preview (2026-10-25 · done, live since 2026-10-25, checked 2026-10-26 and 2026-10-28)

**Answered.** `/v1` allows the origins in the server's `CORS_ORIGINS` (`http://localhost:5555` on the box): preflights get 204 with the allow headers, every response (errors too) carries `Access-Control-Allow-Origin`, and no credentials are used. So the Chrome dev build can call `https://tae.app.elicit-marketing.com/v1`:

```powershell
flutter run -d chrome --web-port 5555 --dart-define=API_BASE_URL=https://tae.app.elicit-marketing.com/v1
```

The original request follows.

**What's wrong.** The app is previewed in Chrome on Windows (`flutter run -d chrome --web-port 5555`, CLAUDE.md → Previewing on Windows), so its requests to the live API are cross-origin. The live server at `https://tae.app.elicit-marketing.com/v1` doesn't allow that:

```
OPTIONS /v1/auth/email/start   Origin: http://localhost:5555
                               Access-Control-Request-Method: POST
→ 404 Not Found, no Access-Control-Allow-* headers

GET /v1/health                 Origin: http://localhost:5555
→ 200, but no Access-Control-Allow-Origin, and Cross-Origin-Resource-Policy: same-origin
```

So the browser blocks every call, and the preview can't sign in against the real API. The phone build isn't affected (native requests have no CORS), and Prism allows any origin, which is why it works there.

**Ask.** Allow the dev preview's origin on `/v1`:
- Answer preflights (`OPTIONS`) with `204` and `Access-Control-Allow-Origin: http://localhost:5555` (or a list from an env var such as `CORS_ORIGINS`; not `*`, since requests carry a bearer token), `Access-Control-Allow-Methods: GET, POST, PATCH, DELETE`, `Access-Control-Allow-Headers: Authorization, Content-Type, Idempotency-Key, X-App-Version, X-App-Build`, and `Access-Control-Max-Age: 600`.
- Send `Access-Control-Allow-Origin` (and `Vary: Origin`) on the actual responses, including errors, so the app can read the error shape.
- Expose `Retry-After` and the `X-RateLimit-*` headers (`Access-Control-Expose-Headers`) if the app should read them.
- `Cross-Origin-Resource-Policy: cross-origin` (or none) on `/v1` responses for allowed origins.
- The WebSocket (`/v1/stream`) checks `Origin` the same way, if it checks at all.

This changes no shapes; it's a server setting, but it decides whether the preview can reach the API, so it's written here.

**Meanwhile.** The preview runs against Prism. Against the live API, sign-in is checked from a script (same requests, no browser) and on the phone once Nathan runs iOS release.

## 11. Who's joined and who's been invited (2026-10-25 · open)

**What's missing.** W12 (Home on IPO day) lists the people the market is waiting for: "Mia · Joined · picking a ticker" (a member who hasn't listed yet) and "Jake · Invited 2 h ago · hasn't opened it" (an invite nobody has used), each with a nudge. `/v1` only has the listed members (the market's listings) and the counts (`Exchange.memberCount`, `listedCount`). There's no list of members, and no list of the invites an exchange has sent.

**Ask (additive), either of:**
- **A.** `GET /exchanges/{id}/members` → `{ items: [{ membershipId, displayName, joinedAt, listing: ListingRef | null }] }`, and `GET /exchanges/{id}/invites` → `{ items: [{ code, createdAt, expiresAt, openedAt | null, acceptedAt | null, invitedName | null }] }`. Preferred.
- **B.** On `Exchange`, while `listedCount < minListingsToOpen`, a `waitingOn` array with the same fields.

A "Nudge" would also need somewhere to go (a notification to that member), which can wait.

**Meanwhile.** IPO day shows who's listed besides you (from the market) and Invite someone; the joined-but-unlisted and invited rows are left out. W12's golden keeps its drawn rows through a fixture.

