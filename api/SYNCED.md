# Contract syncs

`api/openapi.yaml` is a copy of the API repo's `openapi/v1.yaml`. The API repo owns it: never edit the copy here to make the app work. If the app needs something the contract doesn't have, write it in `docs/aura/CONTRACT-REQUESTS.md`.

To sync: copy `..\Aura-Exchange\openapi\v1.yaml` to `api/openapi.yaml`, regenerate the client (`dart run swagger_parser`, then `dart run build_runner build`; delete the files of any schema that was renamed or removed), run `test/api/generated_test.dart`, fix compile errors, then add a row here.

| Date | Source | Spec version | API `CHANGES.md` entry |
| --- | --- | --- | --- |
| 2026-10-24 | `aura-handoff/shared/openapi.yaml`, the planning draft (49 paths, 53 operations) | 1.0.0-draft.1 | None yet: the API repo hadn't published `openapi/v1.yaml` |
| 2026-10-25 | `Aura-Exchange` branch `aura-v1` at `7212276`: the committed `openapi/v1.yaml` (the working copy was mid-edit toward draft.6 and wasn't taken), plus its `docs/aura/API-CONTRACT.md` (10 new error rows) | 1.0.0-draft.5 | draft.2 (`FORBIDDEN`, `CONFLICT`, `IDEMPOTENCY_IN_PROGRESS`), draft.3 (429 and 503 everywhere, 400 and 409 on writes), draft.4 (`LOGIN_CODE_INVALID`, `LOGIN_CODE_EXPIRED`), draft.5 (`INVITE_EXPIRED`, `EXCHANGE_FULL`, `TICKER_TAKEN`, `TRADING_NOT_OPEN`, `INSUFFICIENT_SHARES`). No client yet to regenerate (A2 generates the first). Prism serves it on :4010; forced codes still share one example body (contract request #1) |
