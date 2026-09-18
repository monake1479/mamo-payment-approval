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
- Use the local `Result<Failure, T>` and `Unit` primitives from `lib/common/result/models/`. Use `Unit` for a successful operation without a payload, do not use `void` as a success value, and do not add a functional-programming dependency for this small contract.
- Data sources translate SDK, transport, parsing, and storage failures. Repositories preserve those typed failures while selecting sources or managing cache. Use cases add input and business-rule validation without replacing a more specific infrastructure failure. Cubits store the failure in state; presentation selects localized copy.
- Mock backends throw transport-shaped backend exceptions or return raw malformed payloads in tests; they do not construct application `Failure` or `Result` values. The normal data source must prove the same exception/payload mapping path used by a future real client.
- Add value objects where they protect actual invariants, not for every primitive.
- Test mapped failures and retries with fakes. Do not expose sensitive exception payloads in logs or UI.

## Anchors

- `.ai/architecture/app-structure.md`
- `docs/architecture/overview.md`
- `docs/testing/strategy.md`
