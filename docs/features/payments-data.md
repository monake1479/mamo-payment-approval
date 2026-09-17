# Payments data and collection state

Status: implemented and locally verified on the feature branch. Integration into app composition and user-facing screens remains outside this slice.

## Scope

This slice supplies the shared payment contract for `PAY-01`, `PAY-04`, `HOME-01`, `HOME-02`, and `MONEY-01`:

- immutable payment/status/decision types and explicit operation results;
- bounded whole-fils `double` validation, exact temporary fils accumulation, fixed AED formatting, and canonical string serialization;
- UTC record serialization and account-zone monthly reporting with `Asia/Dubai` as the demonstration account setting;
- an asynchronous deterministic in-memory repository with seeded decided history, one active request, and final decisions;
- one authoritative `PaymentsCubit` collection with load, request creation, decision writes, current-month summary, and decided-history projections.

The Cubit applies a successful create or decision to its canonical collection before returning success. It rejects duplicate in-flight operations, ignores stale load completions after newer loads or writes, preserves the complete existing collection on failures and races, and has no dependency on another Cubit. Request creation stays unavailable until the first successful load establishes a trustworthy collection.

## Public contract

`PaymentsRepository` exposes asynchronous `load`, `createRequest`, and `decide` operations returning `PaymentsResult`. `PaymentsCubit` exposes the same three operations plus synchronous `refreshDerivedState()`. Its immutable `PaymentsState` contains the canonical payments, summary, UTC reporting-period start, reporting-zone identifier, typed failure, initial-load readiness, and operation progress. Downstream UI reads `decidedPayments`, `activeRequest`, `paymentById`, and `canCreateRequest` from that state; it must not create a parallel payment collection. App lifecycle composition calls `refreshDerivedState()` on resume so month rollover uses the injected clock without another state owner.

`PaymentOperations` orders decided history by decision time descending and stable ID ascending, and calculates approved-only current-month totals using inclusive account-month start and exclusive next-month start. Pending and rejected amounts never contribute to the summary. The in-memory repository validates the aggregate cap before persisting an approval, so a failed projection cannot leave storage and Cubit state inconsistent.

## Boundaries and exclusions

The storage implementation is session-only and resets to deterministic seed data after process termination. No backend, database, navigation, screen, authentication adapter, or approval-disclosure state is introduced here. The UI/theme ancestor remains a required unmerged dependency for downstream integration.

## Verification

Unit tests cover money precision and caps, `0.10 + 0.20`, repeated totals, zero and nonzero fixed AED formatting, UTC serialization, malformed records, deterministic seeds, duplicate creation/decisions, atomic aggregate rejection, missing records, equal-time ordering, Dubai UTC month edges, a daylight-saving reporting zone, approved-only totals, reporting-period refresh, guarded initial loading, stale load/write races, disposal, canonical-before-return writes, and full-collection preservation after failures.
