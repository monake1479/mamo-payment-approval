# Failures and Boundaries

## Rule and rationale

Expected failures cross application boundaries as explicit typed outcomes. Infrastructure adapters translate exceptions so presentation can handle recovery without knowing platform details.

## How to apply

- Domain contracts contain no Flutter, plugin, route, or localization types.
- Distinguish success, cancellation, unavailability, and failure where behaviour differs.
- Pass stable error codes/slugs as typed failures, with only explicitly safe parameters, through domain operations and BLoC/Cubit state. Do not return ready-made user messages from repositories or controllers.
- Resolve failures to user-facing copy only in presentation: a small method or mapper accepts the failure and `AppLocalizations` and returns the localized message. Keep retry policy explicit. Controllers do not receive `BuildContext` or localization objects.
- Normalize external codes at the data boundary into known application failures or an explicit unknown failure. Handle known failures exhaustively in the UI mapper; unknown codes use a safe localized fallback. Never display a raw code, server message, exception, or `toString()` as user copy.
- Error codes are a stable application contract, not ARB keys. Changing wording must not require changing the failure contract. Use allowlisted ARB placeholders; never interpolate sensitive payment or authentication payloads.
- Add concrete failure types and their mapper with the first operation that needs them, not a speculative global error catalogue. Test every known mapping, unknown-code fallback, and safe parameter handling alongside that operation.
- Catch known infrastructure exceptions at their boundary. Do not indiscriminately convert programming errors into empty success.
- Start with operation-specific sealed outcomes or a small shared Result type when concrete contracts justify it. A generic monad or `Option` dependency is not mandatory.
- Add value objects where they protect actual invariants, not for every primitive.
- Test mapped failures and retries with fakes. Do not expose sensitive exception payloads in logs or UI.

## Anchors

- `.ai/architecture/app-structure.md`
- `docs/architecture/overview.md`
- `docs/testing/strategy.md`
