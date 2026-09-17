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

For the authorized implementation increment, consult [delegated implementation contracts](../../docs/architecture/implementation-contract.md) and the [UI contract](../../docs/product/ui-contract.md). They resolve baseline details listed below under delegated authority; product extensions and publication/merge restrictions remain unchanged. Do not attribute coordinator-selected details to direct owner Q&A answers.

- Money semantics: ADR 0002 preserves `double`, with details open.
- Monthly summary: approved-only inclusion, decision-time membership, and account-level reporting time zone are accepted in product Q2/Q5/Q6; do not reopen them without a new owner request.
- Approval: the delegated implementation contract selects masks, session reset on
  process termination, and one allowed completion for a decision already submitted
  before backgrounding. Non-dismissible approval, one active request,
  device-credential fallback, authentication before approval, and remasking after
  actual backgrounding are accepted in product Q7–Q11.
- Distribution: installable iOS channel and signing access.
- Product additions: evaluate with the owner after the baseline works.

## Anchors

- `docs/decisions/0002-money-representation.md`
- `docs/product/requirements.md`
- `docs/product/extension-backlog.md`
