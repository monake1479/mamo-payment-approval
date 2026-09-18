# ADR 0002: Money representation

- Status: Accepted
- Date: 2026-09-15
- Updated: 2026-09-18

## Context

The challenge owner selected Dart `double` for payment amounts. The demonstration source currently provides AED, but a real bank account or API may allow another currency. Transaction and aggregate limits would be account/backend policy, not constants invented by the mobile client.

Incoming records still need a clear local boundary: amount values must be positive, finite, and have at most two decimal places. The app approves existing values and sums them for reporting; it does not calculate new monetary values requiring a business rounding policy.

## Decision

`Payment` carries both `double amount` and a validated three-letter uppercase `currency`. The demo backend defaults to AED and can supply another configured currency. Monthly summaries include only the configured reporting currency so amounts in different currencies are never added together.

`PaymentDto` validates boundary values before mapping them into the domain model. `PaymentAmountJsonConverter` round-trips the amount as a string, while exactly two visible decimal places, grouping, and the explicit currency code are presentation concerns. For example, the demo UI renders `AED 1,234.56` independently of device locale.

There is no `PaymentMoney` wrapper, precision tolerance, shadow integer-fils representation, client-side transaction maximum, or aggregate cap. If a backend or account configuration later supplies limits, its data source maps violations to typed failures and the relevant use case decides how the workflow responds.

## Consequences and verification

- Test positive finite DTO values, excess decimal precision, malformed serialized values, and currency-code validation.
- Test that another configured currency traverses source, repository, use cases, and state without code changes.
- Test approved-only reporting and exclude values in a different currency.
- Test large finite values to prove the client adds no artificial maximum.
- Keep fixed two-decimal UI formatting tests with the presentation feature.

Binary floating-point totals can contain representation artefacts internally. UI formatting owns their visible two-decimal representation; introducing tolerance-based equality or a second monetary representation would require a new demonstrated need and an updated decision.
