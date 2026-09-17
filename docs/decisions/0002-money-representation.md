# ADR 0002: Money representation

- Status: Accepted for implementation under delegated authority; owner review pending
- Date: 2026-09-15

## Current direction

The challenge owner has specified that payment amounts should use Dart `double` values rather than integer minor units. The implementation will follow that direction.

The planning Q&A confirms AED as the only initial currency. Incoming payment amounts are already expressed to whole fils (at most two decimal places); fractional-fils payments are not supported. Do not silently round an invalid incoming amount into a different payment.

Display uses fixed English conventions regardless of device locale: `AED 1,234.56`, with comma grouping, a decimal point, and exactly two decimal places. The app approves existing amounts and sums them for reporting; calculations requiring business rounding are outside the initial scope. No half-up/half-even policy or rounding framework is needed for hypothetical future features.

The owner delegated remaining implementation decisions on 2026-09-17. The [implementation contract](../architecture/implementation-contract.md#money-and-timestamps) selects bounded whole-fils validation, canonical currency equality, a temporary exact accumulator with `double` inputs/results, and two-decimal string serialization. The domain amount remains `double`; integer storage was not selected. These technical decisions remain subject to owner review.

## Verification obligations

- Test equality and totals for valid whole-fils amounts represented as `double`, including repeated sums and upper bounds.
- Test boundary parsing/validation and amount serialization, distinguishing invalid business precision from binary floating-point representation effects.

Binary floating-point values cannot represent every decimal fraction exactly, even when the requested payment has only two decimal places. Preserve the `double` model and test comparison, summation, and formatting centrally so representation artefacts do not leak into the UI. This does not authorize introducing a real API or additional calculation features.
