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

## 2. When the next stimulus check lands (2026-10-25 · open)

**What's missing.** W05's rejection says "wait for **tomorrow's** stimulus check". The allowance is a game rule (PLAN.md: A$1,000, Mondays 9 am), and the app mustn't copy game rules, so it can't work out "tomorrow's" or "Monday's" by itself. Nothing in `/v1` says when the next one lands.

**Ask (additive).** Add `nextStimulusAt` (ISO 8601 UTC) to the params of `INSUFFICIENT_CASH`. A `nextStimulusAt` on `Portfolio` would serve the Portfolio screen too, if that's easier; the app would read either.

**Meanwhile.** `lib/l10n/strings.dart` already reads `params.nextStimulusAt` when it's there ("tomorrow's", "Monday's", from the exchange's calendar) and says "the next stimulus check" when it isn't. W05's golden in A3 uses a fixture with the param, so it matches the reference.

## 3. The change amount on ticks (2026-10-25 · open)

**What's missing.** A `ticks` message gives each listing's `price` and `changePct` but not `changeAbs`, which every price row shows (`↑ +7.79 (+6.70%)`, `AuraPriceChange`).

**Ask (additive).** Add `changeAbs` (decimal string, 2 dp) to each listing in `ticks`, like `ListingSummary.changeAbs`.

**Meanwhile.** `LiveMarket` (`lib/data/live_market.dart`) works the amount out from the tick's own price and percent (`price − price × 100 / (100 + changePct)`, rounded half-up to 2 dp). That matches the fixtures (124.10 at +6.70% → +7.79; 101.90 at −9.34% → −10.50), but because the percent is already rounded it can be a cent off the server's figure.

## 4. A heartbeat in quiet market states (2026-10-25 · question)

**The question.** The app marks prices Delayed when `asOf` is over 60 s old (API-CONTRACT.md → Freshness). Ticks come "at most every 15 s" and only with the listings that changed. While the market is OPEN the price engine moves every listing every 15 s, so that's fine. But in PRE, AFTER and an exchange-wide HALTED nothing may move for minutes, and the app would show Delayed although nothing was missed.

**Ask.** Either send a `ticks` message (with an empty `listings` array if nothing changed) at least every 60 s to each subscribed exchange in every market state, or say in API-CONTRACT.md that `asOf` only goes stale while OPEN, and the app will treat the other states like CLOSED.

**Meanwhile.** The app follows the contract as written, except that CLOSED reads "at the close" (as W09 is drawn).

## 5. ASCII example tokens (2026-10-25 · open)

**What's wrong.** `TokenPair`'s examples are `"accessToken": "eyJhbGciOi…"` and `"refreshToken": "rt_9d8c…"`. The `…` (U+2026) can't be sent in an HTTP header, so after Prism answers `POST /auth/refresh`, the client can't replay the request with the new token. It fails before sending.

**Ask.** ASCII examples, e.g. `eyJhbGciOiJIUzI1NiJ9.e30.c2lnbmF0dXJl` and `rt_9d8c4e2a`. No shape change.

**Meanwhile.** The Prism check forces `AUTH_EXPIRED` signed out (no refresh). The refresh and replay are tested against a fake server.

## 6. A refused quote that still shows its numbers (2026-10-25 · open)

**What's missing.** W05 shows a refused trade with its receipt (20 × A$124.10 = A$2,482.00, fee A$12.41, estimated total A$2,494.41) **and** the reason with its fix ("You're A$229.91 short … Buy 18 instead"). Today `POST /quotes` either returns a `Quote` (whose `cashAfter` can be negative, "the trade would be rejected", but which has no `maxQuantity`) or fails with `422 INSUFFICIENT_CASH` (which has `maxQuantity` but no gross, fee or total). Neither answer has both.

**Ask (additive), either of:**
- **A.** On a quote that would be refused, return `201` with the `Quote` plus a `rejection` field in the error shape (`code`, `params`, `retryable`, `action`). The app shows the receipt and the banner from one answer. Preferred.
- **B.** Keep the 422, and add the priced numbers to the params of `INSUFFICIENT_CASH`, `ORDER_TOO_LARGE` and `SHORT_CAP`: `price`, `gross`, `feeRate`, `fee`, `total`.

**Meanwhile.** `tradeTicketModel()` (`lib/features/trade/trade_model.dart`) takes a `Quote` and an optional `ApiError` rejection, which is option A's shape. The W05 fixture supplies both.

## 7. How a liquidation settled (2026-10-25 · open)

**What's missing.** W08 is the liquidation receipt: when it happened, the price the stock crossed and the maintenance ratio it fell under, the collateral held, the buy-back (quantity, price, cost), the fee, what came back to your cash, and the realised loss on the trade with its percent. `Position` (status `LIQUIDATED`) gives the collateral and quantity, but nothing in `/v1` gives the settlement. Working it out in the app would copy the server's settlement rules.

**Ask (additive).** On `Position`, when `status` is `LIQUIDATED`, a `liquidation` object: `at`, `triggerPrice`, `maintenanceRatioPct`, `price`, `cost`, `feeRatePct`, `fee`, `returned`, `realizedPnl`, `realizedPnlPct` (decimal strings like the rest). The liquidation notification's deep link can then open `GET /positions/{id}`.

**Meanwhile.** `Liquidation` (`lib/features/portfolio/liquidated_model.dart`) has exactly these fields, and the W08 fixture fills it.

## 8. What Chapter 7 would do (2026-10-25 · open)

**What's missing.** W04 offers bankruptcy at the moment of the loss and shows its terms: the minimum to trade (A$100.00), the cash you'd restart with (A$2,000.00), the badge you'd carry until the season ends ("Chapter 7"), and the Analyst's line for the tape. `/v1` has `Portfolio.canDeclareBankruptcy` and `POST /exchanges/{id}/bankruptcy` ("reset to A$2,000 with a badge" in its summary), but none of those values. They're game rules, so the app shouldn't hold them.

**Ask (additive).** When `canDeclareBankruptcy` is true, a `bankruptcyOffer` on `Portfolio`: `minimumEquity`, `resetCash`, `badge`, `tapeHeadline` (the line the tape would run). Or a `GET /exchanges/{id}/bankruptcy` returning the same.

**Meanwhile.** `BankruptcyOffer` (`lib/features/portfolio/bankruptcy_model.dart`) has these fields, and the W04 fixture fills them. The banner's copy is the same `underMinimumCopy()` that `EQUITY_TOO_LOW` uses.

