# ADR 0011: Shared data and use-case layer

- Status: Accepted
- Date: 2026-09-18

## Context

Payment models, repository operations, and use cases can be consumed by more than one feature surface. Keeping those contracts below `lib/features/payments/` would force unrelated features to import another feature's internal hierarchy. The application also keeps its data-source boundary separate from the authoritative in-process mock backend.

## Decision

Keep feature-specific UI and Cubits under `lib/features/`, but group reusable data and application operations by domain under `lib/common/data/<domain>/`:

```text
lib/common/data/
  payments/
    converters/
    data_sources/
    dtos/
    models/
    use_cases/
    payments_repository.dart
lib/common/result/
  models/
lib/mock_backend/
  payments/
```

Repositories depend on data sources. The concrete `PaymentsRepository` owns source selection; a separate abstract interface is not justified while the application has one repository implementation. A repository may select or combine local and remote sources for its own aggregate, but it does not coordinate unrelated repositories. Use cases depend on repositories, validate operation inputs and returned models, and own workflows that may require one or multiple repositories. Presentation depends on use cases and shared models, not repositories or concrete data sources.

Register data sources, repositories, and use cases with `injectable` as lazy singletons. Generated registration remains confined to app composition through the process-wide `getIt`; business code receives constructor-injected dependencies and never reads the service locator directly.

The baseline supplies `PaymentsRemoteDataSource` and a narrow `PaymentsBackendClient` contract. App composition binds that contract to the project's authoritative `MockPaymentsBackend` under `lib/mock_backend/payments/`. The mock owns account configuration and returns raw transport-shaped maps and backend exceptions. It must not import application DTOs, repositories, use cases, state, or UI. The remote data source remains responsible for DTO validation and typed failure mapping. Fallible application operations use `Result<Failure, T>` from `lib/common/result/models/`; payload-free success uses `Unit`.

Immutable data classes and sealed unions use Freezed, with one authored model per file. `PaymentDto` owns generated JSON serialization and validates stored values before mapping them into `Payment`. Typed `JsonConverter` classes handle amount strings and UTC timestamps; no separate record codec mirrors the DTO. The remote data source maps generated deserialization and backend failures into typed payment failures. Behaviour-only services remain handwritten.

The mock backend can deterministically simulate every nth request failing when configured in a test. The DI default disables simulation. It retains atomic backend-like consistency for duplicate requests and final decisions; it does not invent account transaction or aggregate limits.

## Consequences

- Multiple features can consume shared payment operations without importing another feature's folder.
- Use cases are the coordination boundary for work spanning repositories.
- Cubits receive ready-to-emit canonical collections and do not validate repository DTOs or business transitions.
- Repository and data-source lifetimes are explicit and consistent across consumers.
- DI generation and its generated configuration become reviewed source inputs and must stay reproducible.
- The common layer must not become a miscellaneous dumping ground; only cross-feature data contracts and operations belong there.
- Domain subdirectories prevent unrelated shared-data contracts from becoming one flat global layer.

## Verification

- Static analysis enforces imports and generated DI validity.
- Bootstrap tests resolve each payment dependency twice and assert lazy-singleton identity.
- Repository, data-source, use-case, DTO serialization, reporting, and Cubit tests cover the same behaviour after the move.
