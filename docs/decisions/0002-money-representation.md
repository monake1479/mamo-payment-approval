# ADR 0002: Money representation

- Status: Deferred until domain modelling
- Date: 2026-09-15

## Current direction

The challenge owner has specified that payment amounts should use Dart `double` values rather than integer minor units. The implementation will follow that direction.

## Details to settle before implementation

- supported currencies and decimal precision;
- rounding points and rounding mode;
- equality and total-calculation behaviour;
- parsing rules and locale-aware display formatting;
- how a future API would encode amounts on the wire.

These details matter because binary floating-point values cannot represent every decimal fraction exactly. The final decision should preserve the requested `double` model while centralising rounding and formatting so floating-point behaviour does not leak into widgets.
