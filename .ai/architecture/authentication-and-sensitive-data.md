# Authentication and Sensitive Data

## Rule and rationale

Reveal approval data only after successful native authentication for the active request. Cancellation, stale results, and accessibility content must not bypass masking.

## How to apply

- Keep authentication behind a domain-facing contract; use native adapters on iOS/Android and deterministic fakes in tests only.
- Keep amount and counterparty masked after cancellation, failure, or unavailability; keep the reference visible.
- Test text, semantics, and copyable content for disclosure. Hidden full-value widgets must not expose data to accessibility services.
- Scope reveal state to one request, discard it on closing, and ignore late results after disposal or replacement.
- Authentication reveals data and never implicitly approves a payment.
- Follow [accepted product Q7–Q11](../../docs/product/requirements.md#planning-qa-accepted-decisions) for dismissal, device-credential fallback, authentication before approval, and background remasking. Reject needs no authentication; the native prompt alone must not invalidate authentication. Resolve the remaining operation-lifecycle decisions before implementing them.
- Handle repeated authentication/decision taps explicitly. Never log sensitive payment data, authentication results, or raw plugin payloads.
- Keep the required request-generation action available in reviewer builds; the word debug does not mean release builds may hide it.

## Anchors

- `docs/product/requirements.md`
- `docs/decisions/0003-mobile-only-platform-scope.md`
- `docs/testing/strategy.md`
