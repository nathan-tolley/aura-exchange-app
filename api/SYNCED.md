# Contract syncs

`api/openapi.yaml` is a copy of the API repo's `openapi/v1.yaml`. The API repo owns it: never edit the copy here to make the app work. If the app needs something the contract doesn't have, write it in `docs/aura/CONTRACT-REQUESTS.md`.

To sync: copy `..\Aura-Exchange\openapi\v1.yaml` to `api/openapi.yaml`, regenerate the client (`dart run swagger_parser`), fix compile errors, then add a row here.

| Date | Source | Spec version | API `CHANGES.md` entry |
| --- | --- | --- | --- |
| 2026-10-24 | `aura-handoff/shared/openapi.yaml`, the planning draft (49 paths, 53 operations) | 1.0.0-draft.1 | None yet: the API repo hadn't published `openapi/v1.yaml` |
