# Implementation Contracts

These concrete contracts guided the parallel feature work and now describe the
integrated baseline. The owner delegated remaining routine design decisions on
2026-09-17; those coordinator-selected decisions remain subject to owner review.
Verification claims belong in commit/PR evidence rather than in this contract.
Existing accepted product Q&A takes precedence.

## Scope and boundaries

Implement the baseline Home, Payments, details, incoming overlay, native reveal/approval, rejection, draggable action, and APK reviewer delivery. No PIN/session feature, pending-payments screen, external or deployed backend, persistent database, or production authentication simulator.

Use `flutter_bloc` for narrow immutable state, `timezone` for account calendar boundaries, `local_auth` for native device authentication, `injectable` for generated registration of the shared data graph, and Freezed for immutable data classes and sealed unions. Verify compatible stable versions against the pinned SDK and commit lockfile changes. Group reusable models, DTOs, payment-specific converters, data sources, repositories, and use cases by domain under `lib/common/data/<domain>/`; general converters live under `lib/common/converters/`, cross-layer failures under `lib/common/error_handling/`, and cross-domain `Result` and `Unit` primitives under `lib/common/result/`. Transport/SDK exception mapping stays with its owning data boundary. Payment presentation remains directly under `lib/features/payments/`. Put each state concern in a dedicated `states/<state-name>/` directory without `_cubit` or `_bloc` in the folder name, and keep its controller, state, and events in separate technology-specific files. Keep one authored model per file, validate stored/transported values in DTOs, use typed `JsonConverter` classes for non-trivial wire values, and do not add a parallel handwritten codec. Fallible operations use the local `Result<Failure, T>` contract and `Unit` for payload-free success. Only composition uses `getIt` and navigation.

## Money and timestamps

- Payment `amount` is a positive finite Dart `double` with at most two decimal places at the DTO boundary. Do not impose a client-side transaction or aggregate maximum. If the product adds account limits, `MockPaymentsBackend` owns and enforces their authoritative configuration.
- Every payment carries a validated three-letter uppercase currency code. The demonstration data source defaults to AED, but shared models and operations must not hardcode it. Never add amounts in different currencies; current summaries use the data source's reporting currency.
- Do not add a precision tolerance, hidden integer-minor-unit representation, or business-rounding layer. Wire values round-trip through typed converters; fixed grouping and exactly two decimal places belong to presentation formatting.
- Serialized demo records use an amount string such as `"1234.56"`, an explicit currency code such as `"AED"`, and ISO 8601 UTC timestamps ending in `Z`. This project uses only the in-process mock backend; no external HTTP API is planned. DTO parsing and validation are independent of device locale.
- Preserve `createdAt` and nullable `decidedAt` as UTC instants. Pending has no decision time; approved/rejected has one. Order by decision time descending, then stable ID ascending. Use the account's IANA zone (`Asia/Dubai` initially) for month boundaries and display, with an injected clock. Date display uses English `dd MMM yyyy, HH:mm`; show the reporting-zone name as context.
- Seed a small collection relative to injected time with approved/rejected entries in the current and prior month. Request generation is deterministic with unique session IDs and at most one pending request. No wall-clock dependency in unit tests.

## Collection and approval coordination

The data/state task owns and publishes the exact Dart signatures before downstream integration. Use a small immutable Payment, status enum, typed failures/results, async PaymentsRepository, production-shaped `PaymentsRemoteDataSource`, operation-specific use cases, and PaymentsCubit. The remote data source consumes a backend-client contract; app composition permanently supplies the deterministic in-memory implementation from `lib/mock_backend/payments/` for this project. The mock is the authoritative backend: it owns account configuration, raw transport records, backend errors, persistence, latency, and atomic mutation rules. The data source owns DTO mapping and typed application failures. Data sources, the repository, use cases, and the composed backend client are lazy singletons. Repositories own data-source selection; use cases own workflows and may coordinate multiple repositories.

PaymentsCubit is the single collection state owner. Its dedicated `states/payments/` directory contains `payments_cubit.dart` and `payments_state.dart`. It owns UI progress, stale-completion guards, and canonical state emission, while injected use cases validate inputs, repository results, and business transitions. The Cubit updates the collection before returning operation success. UI and details derive from this state. The short-lived ApprovalCubit owns only authentication, disclosure, and submission state for one request and receives the sibling `states/approval/` directory. Inject authenticator and a typed decision callback/operation; it must not subscribe to another Cubit or maintain a second collection. App composition connects the callback to the authoritative write path.

`DeviceAuthenticator.authenticate()` returns
`Result<DeviceAuthenticationFailure, Unit>`; the Freezed failure union distinguishes
cancelled, unavailable, and failed outcomes. The capability and adapter live under
`lib/common/data/device_authentication/`, while the failure union lives under
`lib/common/error_handling/`. Presentation supplies localized prompt text through
composition, not data-layer imports. Cancellation or late completion never grants
disclosure. The production `local_auth` plugin remains in the data adapter;
deterministic fakes remain in tests.

Only a native authentication result may reveal the current request. Approval additionally requires a separate explicit action while authorized. Reject does not require authentication. Guard duplicate requests, decisions, disposal, and stale auth completions.

## Lifecycle and storage limits

Actual backgrounding revokes disclosure immediately, including an in-flight authentication attempt. Native-prompt-only inactivity must not do so. Do not reauthenticate automatically on return.

A decision submitted before backgrounding may finish once; do not cancel or replay it automatically. Apply its canonical result, then perform any navigation effect once when the app can present it. Failed decisions remain recoverable in the overlay, with sensitive data masked after backgrounding.

All demo state is session-only. OS process termination resets to the seed on the next launch; there is no claim of durable payment execution or recovery. Explain this clearly in reviewer documentation. App-switcher content remains concealed. On Android versions without recents-only screenshot protection, use the existing privacy boundary and document any additional screenshot restriction required for concealment rather than silently claiming coverage.

## Branch and integration contract

The accepted UI/theme and shared payment-data increments are part of `dev` as of
2026-09-18. Feature and integration work must preserve that ancestry and resolve
composition against its theme, motion, orientation, accessibility, data, use-case,
and state contracts. No worker merges PRs, enables auto-merge, force-pushes, or
writes to `dev`/`main`.

Workers may commit tested local increments and publish feature PRs into `dev` only
when authorized. Coordinate shared dependency, ARB, router, and generated-code
changes rather than assuming another branch already provides them. The integration
branch deliberately reconciles the tested authentication, screen, approval, and
reviewer-delivery increments with accepted `dev` ancestry. Shared composition and
documentation changes require a combined full gate and native journey evidence; a
green feature branch alone is not proof that the integrated application works.

The coordinator owns integration and emulator allocation. Do not run concurrent installs on the same simulator/emulator. Use separate devices or a requested exclusive lease. Every report identifies branch, commit, tests, evidence, and remaining gaps. A blocked native/manual check stays visible; no fake-auth release or test bypass is permitted.
