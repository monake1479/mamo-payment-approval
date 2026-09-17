# UTC and Determinism

## Rule and rationale

Store instants in UTC and inject time when business behaviour or fixtures depend on it. Wall-clock fixtures and unstable ordering make failures hard to reproduce.

## How to apply

- Keep timestamps and comparisons in UTC; localize only for display.
- Decide the reporting calendar, relevant timestamp, and month boundaries before implementing the summary. UTC storage alone does not decide the reporting period.
- Seed demo data relative to a supplied reference instant so the current-month screen remains useful. Tests supply a fixed instant and deterministic identifiers.
- Define a stable tie-breaker for equal ordering timestamps.
- Test month/year rollover, excluded statuses, equal timestamps, and relevant async ordering.
- Preserve ADR 0002's `double` direction. Discuss rounding, equality, formatting, currency, and serialization with the owner before implementing money.

## Anchors

- `docs/product/requirements.md`
- `docs/decisions/0002-money-representation.md`
- `docs/testing/strategy.md`
