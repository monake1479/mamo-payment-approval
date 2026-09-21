# Architecture Overview

## Goals

The architecture makes the review conversation straightforward: each class has a clear reason to exist, domain rules can be tested without Flutter bindings, and native authentication sits behind a testable interface.

## Current versus planned implementation

The foundation contains a shared bootstrap, process-wide `get_it` registrations, local error logging, a stateless app root, system-following light/dark themes, and a placeholder page. Bootstrap and localization/layout/theme tests cover the implemented foundation. Flutter UI copy comes from English ARB resources through generated `AppLocalizations` (ADR 0008). The shared payment models, production-shaped remote data source, repository, use cases, mock-backend client, generated dependency registrations, and authoritative collection Cubit are implemented; the decided-history search adds one event-driven BLoC beside the Cubits ([ADR 0012](../decisions/0012-event-driven-bloc-for-payments-search.md)); payment screens and their provider/router wiring remain separate increments. The [implementation contract](implementation-contract.md) records the delegated baseline choices for the feature increments.

## Runtime shape

Three thin flavor entry points call `bootstrap`: initialize Flutter bindings, validate native `appFlavor`, await `configureDependencies(environment)`, configure error handlers, and launch the app. There is no startup state controller. Dependencies are resolved in composition and injected into consumers, not looked up from domain code. See ADRs [0007](../decisions/0007-native-flavors.md) and [0010](../decisions/0010-bootstrap-and-local-error-boundary.md).

```text
App shell
  |-- Router and theme
  |-- Session-scoped debug action
  |-- Common data
  |    `-- Payments
  |         |-- Freezed domain models
  |         |-- Freezed DTOs and JSON converters
  |         |-- Use cases
  |         |-- Payments repository
  |         `-- Remote data source
  |-- Common result primitives
  |-- Mock backend: raw payment records and backend failures
  `-- Payments feature: pages, overlay, widgets, BLoC/Cubit
```

The application composes `PaymentsRemoteDataSource` with an in-memory `MockPaymentsBackend`, which is the project's only backend. The mock is seeded with deterministic raw records and can reproduce every-nth-request backend failures without making the normal demo unreliable. It owns account reporting configuration, session persistence, latency, and atomic final-decision checks. The remote data source remains production-shaped: it consumes the backend-client contract, maps raw records through `PaymentDto`, and translates backend exceptions into `PaymentsFailure`. The concrete asynchronous `PaymentsRepository` delegates to that data source; a separate repository interface is unnecessary while there is only one repository implementation.

## Planned time contract

Domain timestamps represent UTC instants; serialized records use ISO 8601 with a UTC `Z` suffix. Preserve creation and decision timestamps separately. History and monthly membership use decision time.

Inject the account's IANA reporting-zone configuration; the demonstration account uses `Asia/Dubai`. Do not derive it from the device, currency, or language. Monthly reporting constructs calendar boundaries in that zone and converts them to UTC for an inclusive-start/exclusive-end comparison. Initial date display uses the same account zone. This keeps reports consistent for users of one account across countries without adding account-management UI or a persistent database. See [product Q6](../product/requirements.md#planning-qa-accepted-decisions).

## State ownership

Navigation is configured in `lib/app/navigation/app_router.dart`. One DI-owned
`MamoPaymentRouter` constructs, exposes, and disposes the application `GoRouter`;
the app injects that stable router into `MaterialApp.router`, so routes are not
recreated in `build`. Only `/` exists today. Unknown locations show a localized
fallback without exposing the URI. Startup/build failures use standalone
`AppFailureApp`, outside normal navigation, so rendering them does not depend on
successful DI initialization.

- A payments state owner emits the canonical collection and manages UI progress and stale completions. Injected use cases validate repository results, enforce business transitions, and project ordering and totals before returning ready-to-emit application data.
- A short-lived approval state owner coordinates masked/revealed UI state, authentication, and decision submission.
- A session-scoped debug-action state owner stores the position. Activation enters the feature's request-creation path through app composition; position state does not become a second payment collection.
- The router controls navigation, while the approval UI is presented above the active route.

Widgets may create scoped controllers with `BlocProvider` and access them through `BuildContext`. Controllers themselves do not accept context, show dialogs, or navigate. Constructor injection keeps dependencies explicit; `get_it` is confined to composition. Global logging does not own navigation or feature state; a normal widget class renders startup/build errors.

Each state concern has a dedicated directory under `lib/features/<feature>/states/`, named after the concern without `_cubit` or `_bloc`; its controller, state, and events remain separate technology-specific files. Payment feature files live directly under `lib/features/payments/` in `states/`, `pages/`, and `widgets/`; there is no additional `presentation/` directory or shared feature-level `cubit/` bucket.

The decision path is: approval action -> use case -> repository -> data source -> backend client -> authoritative collection update -> terminal approval outcome -> composition closes the overlay and navigates. Use cases, rather than repositories, coordinate workflows that span multiple repositories. The implemented state layer keeps the single write owner explicit and tests canonical-before-return updates plus failure preservation. When payment UI arrives, composition must close or navigate only after a successful result. Details select canonical state rather than keeping a stale payment copy.

## Security and privacy

Failures cross boundaries through the local `Result<Failure, T>` contract, using `Unit` when success has no payload, with stable codes/slugs and safe parameters. Only presentation maps them to text using `AppLocalizations`; repositories and controllers do not own user messages. Local diagnostics retain only fixed technical metadata and allowlisted app locations; no raw exception or remote crash service. Data sources normalize infrastructure failures, repositories preserve them, and use cases add operation-level validation; see [failure boundaries](../../.ai/architecture/failures-and-boundaries.md).

- Payment details begin masked in the approval overlay.
- The platform authentication result crosses the app through a narrow interface.
- Authentication errors are mapped to recoverable application states.
- Logs and analytics must not contain counterparty names, references, complete amounts, or authentication payloads.

## Native authentication and delivery

iOS and Android will use native authentication adapters allowing biometrics or the operating system's device PIN/passcode; deterministic fakes are test dependencies. No Web target or production auth simulator is planned. Real native prompt verification supplements fake-based tests.

The planned approval controller permits approval only after successful authentication and disclosure for its active request, followed by an explicit approval action. Rejection needs no authentication. Actual backgrounding revokes reveal/approval authorization and remasks the still-open request; stale authentication completions cannot restore it. The native prompt's own transient inactive state must not be mistaken for backgrounding. This is separate from app-switcher privacy and does not introduce an app-wide lock or application PIN. See [product Q9–Q11](../product/requirements.md#planning-qa-accepted-decisions). Process termination and backgrounding during an already submitted decision remain open; invalidating disclosure must not silently replay an operation.

Reviewer access uses an installable Android APK without compilation. iOS remains supported/tested but does not require TestFlight/store distribution. See ADR 0003.

## Deliberate limits

- No external or deployed backend is planned for the challenge. `lib/mock_backend/` is the authoritative in-process backend behind the client/data-source boundary.
- No general design-system package is created for a single application; tokens live under `lib/app/theme/`.
- Code generation and dependency injection frameworks are added only if their value exceeds their setup cost.
- Optimisation follows measurement. Narrow rebuilds are encouraged, but premature caching and repaint boundaries are not defaults.
