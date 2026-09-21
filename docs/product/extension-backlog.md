# Product Extension Backlog

## Status and selection

This backlog contains discussion candidates and explicitly deferred owner requests. The owner will choose an original contribution after the core flow works. Neither a candidate nor a deferred request authorizes implementation.

Choose a small addition with clear user value, a demonstrable journey, explainable architecture, realistic effort, and focused tests. Preserve baseline criteria and session-only storage unless explicitly changed. The owner explicitly changed the storage guardrail once, for the non-sensitive appearance preference only: `UI-03` persists the selected theme mode via `shared_preferences` (see [ADR 0013](../decisions/0013-persistent-theme-mode.md)). This does not authorize persisting payment or authentication data, or a general local database.

| Candidate | User value | Questions and costs |
|---|---|---|
| Payment decision timeline | Explain when a request arrived and was decided | Timestamp semantics, privacy, distinction from durable audit logs |
| Search and status filtering | Find payments as the list grows | Selected for slice 5: `SEARCH-01..05`, [feature note](../features/payments-search.md), [ADR 0014](../decisions/0014-event-driven-bloc-for-payments-search.md); filter ownership, empty results, and return-navigation state are resolved there |
| Deterministic demo scenarios | Exercise recovery as well as success | Separate from real authentication; no release auth bypass |
| Accessible decision feedback | Clear results through text, motion, optional haptics | Duplicate feedback, reduced motion, platform settings |

Accessibility, errors, and authentication correctness are baseline quality, not optional differentiators. Each selected extension needs acceptance criteria, design rationale, tests, evidence, and a PR to `dev`.

## Deferred owner request: app PIN and session expiry

Recorded on 2026-09-17. Status: retained for future planning; not implemented and not part of the current foundation increment.

- Add an app-entry PIN and a session valid for an agreed duration. The duration is intentionally unspecified; do not invent a timeout.
- Current direction: obscure app content in the background/task-switcher preview, without requiring biometrics or a PIN merely on returning to the foreground. The privacy cover is separate from the future session lock; this note does not claim either is implemented.
- App-entry authentication is distinct from the device authentication required to reveal sensitive payment data under `APPROVAL-04`. A future app PIN must not silently replace that requirement.
- Before implementation, agree on PIN setup/change/recovery, secure verification/storage, failed-attempt limits, absolute versus inactivity-based expiry, and session behaviour across backgrounding and process restarts.
- Define locked/expired-session behaviour, accessibility, deterministic clock-based tests, and native end-to-end scenarios with that slice. Do not persist sensitive data or add storage dependencies merely to prepare for it.

## Deferred owner request: pending payments screen

Status: retained for a later increment, not part of the initial payment approval flow.

- Add a dedicated screen for requests still awaiting a decision. Initially, pending requests are visible only in the approval overlay; Home and Payments show decided history.
- Before implementation, agree on entry/navigation, masking and authentication, reopening a request, ordering, and behaviour across session/process termination.
- Keep the same authoritative payment collection. This request does not authorize a second store, persistence, or a new status such as processing/settling after approval.
