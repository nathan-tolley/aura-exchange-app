# Contract requests

What the app needs from `/v1` that the contract doesn't give yet. The API repo owns the contract (`openapi/v1.yaml`), so each request goes to Nathan and the API session. Until one lands, the app builds against a local fixture. Mark a request done with the sync date from `api/SYNCED.md`.

## 1. Named examples for each error code (2026-10-24 · open)

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

