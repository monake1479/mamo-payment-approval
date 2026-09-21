# Application Structure

Keep feature-specific presentation under `lib/features/` and group reusable data/application operations by domain under `lib/common/data/<domain>/`. The intended dependency direction is:

```text
feature presentation -> common use cases -> repositories -> data sources
                              |                   |
                              +---- models -------+
                                      ^
                              app composition DI
```

## Responsibilities

- `lib/app/`: app composition, router, root shell, global theme, and dependency wiring.
- `lib/mock_backend/<domain>/`: demo-only backend contracts and deterministic in-memory implementations that return transport-shaped data and backend error codes. They must not import application DTOs, repositories, use cases, Cubits, or UI.
- `lib/common/converters/`: reusable typed converters that are not owned by one data domain, such as UTC `DateTime` JSON conversion.
- `lib/common/widgets/`: presentation building blocks shared by more than one feature, such as the scrolled page body used by payment details and settings. Feature-specific widgets stay under their feature.
- `lib/common/data/<domain>/error_handling/`: each domain's typed application failures, colocated with that domain's data so related types stay together instead of in a global bucket. A domain failure is a shared type consumed across that domain's data, use-case, and presentation boundaries. Transport/SDK exception mapping remains in the owning data source or domain-specific data error boundary.
- `lib/common/result/models/`: shared `Result` and `Unit` primitives that are independent of any data domain.
- `lib/common/data/<domain>/`: one bounded shared-data area per domain; do not mix unrelated models, sources, repositories, and use cases at the root of `common/data`.
- `lib/common/data/payments/models/`: reusable Freezed payment entities and reporting models. Keep one authored model per file.
- `lib/common/data/payments/dtos/`: stored or transported Freezed shapes. DTOs validate boundary data before mapping it to domain models.
- `lib/common/data/payments/converters/`: payment-specific `JsonConverter` implementations, such as the stored amount representation. Promote a converter to `lib/common/converters/` when it has no payment-specific semantics.
- `lib/common/data/payments/data_sources/`: production-shaped transport adapters. `PaymentsRemoteDataSource` consumes the backend-client contract, maps raw records through DTOs, and translates backend/transport exceptions into typed failures.
- `lib/common/data/payments/payments_repository.dart`: the shared payment repository, which delegates to its data sources.
- `lib/common/data/payments/use_cases/`: application operations consumed by presentation. A use case may coordinate multiple repositories when one workflow owns that coordination.
- `lib/features/payments/`: payment screens, overlays, widgets, and state owners. Keep each Cubit/BLoC in its own directory under `states/`; do not add a redundant `presentation/` directory below the feature.

Create directories and abstractions when the first real type needs them; do not commit empty architecture ceremony.

## Boundary rules

- Presentation depends on use cases and shared models, not repositories or concrete data sources. Cubits manage UI state, in-flight guards, and stale async completions; use cases validate operation inputs and repository results and return ready-to-emit application data.
- Data implementations translate storage or platform failures before returning across the boundary.
- Colocate each domain's typed failures with its data under `lib/common/data/<domain>/error_handling/`. A domain failure is a shared type, like a domain model, so presentation may import it directly even though it does not import that domain's repositories or concrete data sources. Transport/SDK parsing and exception translation stay with the owning data boundary.
- Repositories coordinate their own local/remote data sources. Cross-repository workflows belong in use cases, not inside repositories.
- Data sources own SDK/client calls, record mapping, and infrastructure-error translation. Demo storage, latency, deterministic failure simulation, and authoritative concurrent mutation checks belong to `lib/mock_backend/`, not the data source.
- Keep the mock-backend boundary transport-shaped: raw request/response values and backend exceptions cross into data sources. Do not let mock implementations return application DTOs, domain models, `Result`, or `PaymentsFailure`, because that would bypass the application's data boundary.
- Register mock-backend implementations in app composition behind narrow client contracts. Data sources, repositories, use cases, and Cubits must not branch on whether the active backend is mocked or real.
- Use Freezed for immutable data classes and sealed unions, including presentation state. Keep DTO validation at the data boundary and use typed `JsonConverter` classes for non-trivial wire values; do not duplicate generated `fromJson`/`toJson` with a handwritten record codec.
- Put feature state owners under `lib/features/<feature>/states/<state-name>/`, using one directory per state concern. Name the directory after the concern without a technology suffix, for example `states/payments/` or `states/approval/`, never `payments_cubit/` or `approval_bloc/`. Keep the implementation technology in the filenames inside it: a Cubit has `<name>_cubit.dart` and `<name>_state.dart`; a BLoC has `<name>_bloc.dart`, `<name>_event.dart`, and `<name>_state.dart`. Do not use a single feature-level `cubit/` or `bloc/` bucket for multiple state owners.
- Annotate shared data sources, repositories, and use cases with `@lazySingleton`; generated registration is owned by `lib/app/di/`. Do not resolve `getIt` inside business methods. Annotate feature BLoCs/Cubits with `@injectable` and resolve them in a `BlocProvider(create:)` placed as close as possible to the subtree that uses them (at the top of the page only when several parts of the page share the instance); resolving or constructing a page's state owner in the router or in `lib/app/di/` is an anti-pattern because the router would then have to know what every page injects below it.
- Device authentication follows the shared data layering. `IsLocalAuthSupportedUseCase`, `LocalAuthenticationUseCase`, and `StopLocalAuthenticationUseCase` delegate to `LocalAuthRepository`. `LocalAuthClient` is the data source: one concrete class (no interface) over the injected `local_auth` plugin that owns the SDK calls and translates plugin exceptions into typed results, so the repository never handles raw plugin exceptions. `LocalAuthRepository` owns only the cross-call occupancy/cancellation state machine and caches a confirmed positive device-support result (a negative or failed probe is re-checked); that in-flight/stale coordination lives here as an interim owner until the approval state owner (a Cubit) exists. Authentication results are never cached. No Web simulator is planned.
- Navigation is application infrastructure. Domain and data layers know nothing about routes or `BuildContext`.
- The payment collection has one authoritative state owner so decisions update the home summary, list, and details consistently.
- Temporary overlay concerns, such as revealing masked data, should not leak into the persisted payment entity.
- Prefer constructor injection and explicit composition in `lib/app/`. `get_it` is in use (ADR 0011): resolve dependencies in composition for process-wide owners and in the nearest `BlocProvider(create:)` above the consuming subtree for feature owners, never inside business methods and never in route builders.
- Keep feature-only visual state out of `common/data`. Shared placement is justified by cross-feature consumption, not by a generic preference for global folders.

## Anchors

- `docs/decisions/0011-shared-data-and-use-case-layer.md`
- `docs/architecture/overview.md`
- `lib/app/app.dart` (current composition entry point; feature wiring is planned)
