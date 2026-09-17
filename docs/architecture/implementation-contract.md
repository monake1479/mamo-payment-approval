# Implementation Contracts

These concrete contracts support parallel implementation. The owner delegated remaining routine design decisions on 2026-09-17; the decisions below are coordinator-selected and remain subject to owner review. They do not claim implementation or verification. Existing accepted product Q&A takes precedence.

## Scope and boundaries

Implement the baseline Home, Payments, details, incoming overlay, native reveal/approval, rejection, draggable action, and APK reviewer delivery. No PIN/session feature, pending-payments screen, backend, persistent database, or production authentication simulator.

Use `flutter_bloc` for narrow immutable state, `timezone` for account calendar boundaries, and `local_auth` for native device authentication. Verify compatible stable versions against the pinned SDK and commit lockfile changes; no generator or general-purpose state framework. Feature-specific code stays under `lib/features/payments/`. Only composition uses `getIt` and navigation.

## Money and timestamps

- Payment `amount` is a Dart `double`, with currency `AED`. Incoming amounts are positive, finite, whole-fils values; cap individual amounts and aggregate totals at `999999999.99` AED for the bounded demo. Invalid data returns an explicit failure rather than silently altering the payment.
- Validate against two-place currency precision while allowing binary representation noise (less than `0.0000001` AED). Reject actual extra decimal precision. Use a canonical two-decimal value for equality and serialization, not raw intermediate floating-point equality.
- Domain amounts remain `double`. A temporary integer-fils accumulator may be used solely to sum already validated amounts exactly, converting back to `double` at the result boundary. This is not an integer-money model or a business-rounding feature. Test `0.10 + 0.20`, repeated sums, upper bounds, NaN/infinity, and excess precision.
- Serialized demo records use an amount string such as `"1234.56"` with explicit `"AED"`, and ISO 8601 UTC timestamps ending in `Z`. No real HTTP API is introduced. Parsing validates the contract rather than relying on device locale.
- Preserve `createdAt` and nullable `decidedAt` as UTC instants. Pending has no decision time; approved/rejected has one. Order by decision time descending, then stable ID ascending. Use the account's IANA zone (`Asia/Dubai` initially) for month boundaries and display, with an injected clock. Date display uses English `dd MMM yyyy, HH:mm`; show the reporting-zone name as context.
- Seed a small collection relative to injected time with approved/rejected entries in the current and prior month. Request generation is deterministic with unique session IDs and at most one pending request. No wall-clock dependency in unit tests.

## Collection and approval coordination

The data/state task owns and publishes the exact Dart signatures before downstream integration. Use a small immutable Payment, status enum, typed failures/results, async PaymentsRepository, deterministic in-memory implementation, and PaymentsCubit. Avoid pass-through use cases without business work.

PaymentsCubit is the single collection state owner. It owns loading, request creation, and decision writes through domain operations/repository, and updates the collection before returning operation success. UI and details derive from this state. The short-lived ApprovalCubit owns only authentication, disclosure, and submission state for one request. Inject authenticator and a typed decision callback/operation; it must not subscribe to another Cubit or maintain a second collection. App composition connects the callback to the authoritative write path.

The authentication task can implement its domain-facing contract independently: `DeviceAuthenticator.authenticate()` returns a typed success/cancelled/unavailable/failed outcome and exposes cancellation where supported. Presentation supplies localized prompt text through composition, not domain imports. Cancellation or late completion never grants disclosure. Platform plugins live only in data adapters.

Only a native authentication result may reveal the current request. Approval additionally requires a separate explicit action while authorized. Reject does not require authentication. Guard duplicate requests, decisions, disposal, and stale auth completions.

## Lifecycle and storage limits

Actual backgrounding revokes disclosure immediately, including an in-flight authentication attempt. Native-prompt-only inactivity must not do so. Do not reauthenticate automatically on return.

A decision submitted before backgrounding may finish once; do not cancel or replay it automatically. Apply its canonical result, then perform any navigation effect once when the app can present it. Failed decisions remain recoverable in the overlay, with sensitive data masked after backgrounding.

All demo state is session-only. OS process termination resets to the seed on the next launch; there is no claim of durable payment execution or recovery. Explain this clearly in reviewer documentation. App-switcher content remains concealed. On Android versions without recents-only screenshot protection, use the existing privacy boundary and document any additional screenshot restriction required for concealment rather than silently claiming coverage.

## Branch and integration contract

The UI/theme PR targets `dev` and remains unmerged. Feature workers use separate Git and Orca child worktrees based on its exact branch/commit. Each task owns a small feature branch and its tests. No worker merges PRs, enables auto-merge, force-pushes, or writes to `dev`/`main`.

Workers may commit their tested local increments and publish feature PRs into `dev` with an explicit dependency link to the theme PR; until dependencies merge, these PRs include that ancestor. Coordinate shared dependency/ARB/router changes rather than assuming another branch already provides them. Integrate selected commits into a separate work branch with provenance and rerun the full gate. A green branch is not proof that the combined application works.

The coordinator owns integration and emulator allocation. Do not run concurrent installs on the same simulator/emulator. Use separate devices or a requested exclusive lease. Every report identifies branch, commit, tests, evidence, and remaining gaps. A blocked native/manual check stays visible; no fake-auth release or test bypass is permitted.
