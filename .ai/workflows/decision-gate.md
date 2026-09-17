# Decision Gate

## Rule

Resolve behaviour-changing ambiguities with the owner before encoding them. Implement routine details autonomously within accepted decisions.

## How to apply

1. Identify affected acceptance criteria and read relevant ADRs and current code.
2. Describe material choices through context, realistic alternatives, recommendation, consequences, and verification.
3. Ask only about unresolved product decisions or meaningful architectural departures. Existing authorization remains valid.
4. Record agreed behaviour in requirements and significant trade-offs in an ADR: status, date, context, alternatives, decision, consequences, verification.
5. Update architecture and tests in the implementation PR. Distinguish current code from intended design.

New dependencies need a concrete reason and an alternative considered, not automatic permission for every package. Deferred decisions stay deferred until the owner's discussion is recorded.

## Current gates

- Money semantics: ADR 0002 preserves `double`, with details open.
- Monthly summary: status inclusion, reporting calendar, and timestamp semantics.
- Approval: masks, native fallback, dismissal, and background/resume policy.
- Distribution: installable iOS channel and signing access.
- Product additions: evaluate with the owner after the baseline works.

## Anchors

- `docs/decisions/0002-money-representation.md`
- `docs/product/requirements.md`
- `docs/product/extension-backlog.md`
