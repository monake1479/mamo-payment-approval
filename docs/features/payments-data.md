# Payments data and collection state

Status: implemented and locally verified on the feature branch. User-facing screen wiring remains outside this slice.

## Scope

This slice supplies the shared payment contract for `PAY-01`, `PAY-04`, `HOME-01`, `HOME-02`, and `MONEY-01`:

- reusable Freezed payment models under `lib/common/data/payments/models/`, with one authored model per file, and a cross-layer `PaymentsFailure` union under `lib/common/data/payments/error_handling/`;
- a Freezed `PaymentDto` with a payment-specific amount converter under `common/data/payments/converters/` and reusable UTC conversion under `common/converters/`;
- UTC record serialization and account-zone monthly reporting with `Asia/Dubai` as the demonstration account setting;
- a production-shaped asynchronous remote data source backed in demo composition by a deterministic in-memory backend client, with seeded decided history, one active request, final decisions, and opt-in deterministic failure simulation;
- lazy-singleton load, create-request, decision, and refresh use cases registered through generated DI;
- one authoritative `PaymentsCubit` collection with load, request creation, decision writes, current-month summary, and decided-history projections.

`Result<Failure, T>` and `Unit` live under `lib/common/result/` because they are shared application primitives, not payment storage types. Presentation is flat under `lib/features/payments/`; the collection controller and state are separate files in their dedicated `states/payments/` directory.

## Public contract

The concrete `PaymentsRepository` delegates asynchronous `load`, `createRequest`, and `decide` operations to `PaymentsRemoteDataSource`; no abstract repository interface is introduced without a second implementation. The data source consumes `PaymentsBackendClient`, maps raw records through `PaymentDto`, and converts backend exceptions to `PaymentsFailure`. Demo composition binds that client contract to `MockPaymentsBackend`; presentation calls use cases and cannot observe whether the service is mocked or real.

`PaymentsCubit` exposes `load`, `createRequest`, `decide`, and synchronous `refreshDerivedState()`. Payload-free methods return `Result<PaymentsFailure, Unit>`, never `Result<void>`. Its immutable `PaymentsState` contains the canonical payments, approved-only summary, UTC reporting-period start, reporting-zone identifier, reporting currency, typed failure, initial-load readiness, and operation progress. Downstream UI reads `decidedPayments`, `activeRequest`, `paymentById`, and `canCreateRequest` from that state; it must not create a parallel payment collection.

Use cases enforce application workflow and validate repository transitions. `PaymentDto` validates stored values before mapping them into `Payment`. `PaymentsCollection.fromPayments` orders decided history by decision time descending and stable ID ascending, then calculates the current account-month summary using an inclusive local-month start and exclusive next-month start converted to UTC. Pending, rejected, and payments in a currency other than the configured reporting currency do not contribute to that summary.

The Cubit applies every successful mutation's complete canonical collection before returning success. It rejects duplicate in-flight operations, ignores stale load completions after newer loads or writes, preserves the existing collection on failures and races, and has no dependency on another Cubit. Request creation stays unavailable until the first successful load establishes a trustworthy collection.

## Money and currency

`Payment` carries the three-letter uppercase currency supplied by the data source. The current demo data source defaults to AED, but it can be configured with another currency without changing the model, repository, use cases, or Cubit. Summary totals are scoped to the configured reporting currency so values in different currencies are never added together.

Amounts remain positive finite Dart `double` values with at most two decimal places at the DTO boundary. The application does not currently define a maximum transaction or aggregate amount. If product scope adds limits, their authoritative configuration and enforcement belong to `MockPaymentsBackend`. There is no precision tolerance, integer-fils shadow model, or special money wrapper. Wire amounts round-trip through `PaymentAmountJsonConverter`; exactly two decimal places are a presentation concern.

## Boundaries and exclusions

The mock backend is the project's only backend. It is session-only and resets to deterministic seed data after process termination. Its failure interval is disabled in normal composition and can be enabled explicitly in tests; uncontrolled randomness is not used. Clock, records, latency, reporting time zone, currency, and failure cadence belong to `MockPaymentsBackend`, which validates its account configuration. The production-shaped data source therefore has one dependency-only constructor and no `@ignoreParam` configuration. No external backend, database, navigation, screen, authentication adapter, or approval-disclosure state is introduced here.

Additional field Value Objects remain deferred until an input form or another concrete boundary needs them. There is no `PaymentRecordCodec`, `PaymentMoney`, or `PaymentOperations`: generated DTO serialization owns record mapping, use cases own workflows, and the collection model owns deterministic projections.

## Verification

Unit tests cover the raw mock-backend contract, DTO validation and serialization, backend-error mapping, multiple currencies, UTC timestamps, malformed records, deterministic seeds and simulated failures, duplicate creation and decisions, large uncapped amounts, missing records, equal-time ordering, Dubai UTC month edges, a daylight-saving reporting zone, approved-only single-currency totals, reporting-period refresh, guarded initial loading, stale load/write races, disposal, canonical-before-return writes, and full-collection preservation after failures.
