# Architecture Overview

## Goals

The architecture makes the review conversation straightforward: each class has a clear reason to exist, domain rules can be tested without Flutter bindings, and native authentication sits behind a testable interface.

## Current implementation

The integrated baseline contains the shared bootstrap, process-wide `get_it`
registrations, sanitized local diagnostics, system-following light/dark themes,
generated English localization, payment domain/data/state, Home, Payments,
decided-payment details, native device authentication, the incoming approval
overlay, and the session-scoped draggable request action. The accepted shared
design system, portrait-only platform contract, and motion primitives are inherited
from `dev`; feature composition uses those primitives directly. The
[implementation contract](implementation-contract.md) records the boundaries that
the delivered code follows.

## Runtime shape

Three thin flavor entry points call `bootstrap`: initialize Flutter bindings, validate native `appFlavor`, await `configureDependencies(environment)`, configure error handlers, and launch the app. There is no startup state controller. Dependencies are resolved in composition and injected into consumers, not looked up from domain code. See ADRs [0007](../decisions/0007-native-flavors.md) and [0010](../decisions/0010-bootstrap-and-local-error-boundary.md).

```text
App shell
  |-- Router and theme
  |-- Session-scoped debug action
  `-- Payments feature
       |-- Presentation: pages, overlay, BLoC/Cubit
       |-- Domain: payment rules, repository and authenticator contracts
       `-- Data: deterministic in-memory repository and platform adapters
```

The implementation uses a deterministic in-memory repository. Its asynchronous
domain contract supports explicit failures and testable races without claiming a
remote API, persistent storage, or durable payment execution.

## Money and time contract

Domain timestamps represent UTC instants; serialized records use ISO 8601 with a UTC `Z` suffix. Preserve creation and decision timestamps separately. History and monthly membership use decision time.

Inject the account's IANA reporting-zone configuration; the demonstration account uses `Asia/Dubai`. Do not derive it from the device, currency, or language. Monthly reporting constructs calendar boundaries in that zone and converts them to UTC for an inclusive-start/exclusive-end comparison. Initial date display uses the same account zone. This keeps reports consistent for users of one account across countries without adding account-management UI or a persistent database. See [product Q6](../product/requirements.md#planning-qa-accepted-decisions).

## State ownership

Navigation is configured in `lib/app/navigation/app_router.dart`. The app receives
`MamoPaymentRouter` constructs, exposes, and disposes the application `GoRouter`;
the app injects that stable router into `MaterialApp.router`, so routes are not
recreated in `build`. Stateful Home and Payments branches own pushed detail routes,
preserving the route of origin. Detail pushes use `AppMotionPage`; branch changes
use `AppPageTransitionSwitcher`. Unknown locations show a localized fallback
without exposing the URI. Startup/build failures use standalone `AppFailureApp`,
outside normal navigation, so rendering them does not depend on successful DI.

- A payments state owner maintains the canonical collection, ordering, totals, and decisions.
- A short-lived approval state owner coordinates masked/revealed UI state, authentication, and decision submission.
- A session-scoped debug-action state owner stores the position. Activation enters the feature's request-creation path through app composition; position state does not become a second payment collection.
- The router controls navigation, while the approval UI is presented above the active route.

Widgets may create scoped controllers with `BlocProvider` and access them through `BuildContext`. Controllers themselves do not accept context, show dialogs, or navigate. Constructor injection keeps dependencies explicit; `get_it` is confined to composition. Global logging does not own navigation or feature state; a normal widget class renders startup/build errors.

The decision path is: approval action -> `ApprovalCubit` callback ->
`PaymentsCubit.decide` -> repository result -> authoritative collection update ->
terminal approval outcome -> `PaymentFlowLayer` closes the overlay and applies the
one navigation effect. Failed decisions keep the overlay open. Details resolve a
stable identifier against canonical state rather than retaining a stale payment
copy.

## Security and privacy

Failures cross boundaries as typed outcomes with stable codes/slugs and safe parameters. Only presentation maps them to text using `AppLocalizations`; repositories and controllers do not own user messages. The first concrete codes cover environment mismatch, failed startup, and unexpected runtime failures. Local diagnostics retain only fixed technical metadata and allowlisted app locations; no raw exception or remote crash service. Feature failures will be normalized at their own boundaries; see [failure boundaries](../../.ai/architecture/failures-and-boundaries.md).

- Payment details begin masked in the approval overlay.
- The platform authentication result crosses the app through a narrow interface.
- Authentication errors are mapped to recoverable application states.
- Logs and analytics must not contain counterparty names, references, complete amounts, or authentication payloads.

## Native authentication and delivery

iOS and Android use the `local_auth` adapter with biometric or operating-system
PIN/passcode fallback; deterministic fakes exist only in tests. No Web target or
production authentication simulator exists. Native prompt verification supplements
fake-based tests and must distinguish simulator input from physical-device proof.

The approval controller permits approval only after successful authentication and
disclosure for its active request, followed by an explicit approval action.
Rejection needs no authentication. Actual backgrounding revokes reveal/approval
authorization and remasks the still-open request; stale authentication completions
cannot restore it. Native-prompt-only inactivity is ignored. A decision already
submitted may complete once while backgrounded, and composition consumes its
navigation effect once after resume. This is separate from app-switcher privacy and
does not introduce an app-wide lock or application PIN. See
[product Q9–Q11](../product/requirements.md#planning-qa-accepted-decisions).

Reviewer access uses a private Actions artifact containing a release-mode,
debug-key-signed Android APK, source SHA, checksum, signature evidence, and
installation instructions. iOS remains supported and compiled/tested but does not
require TestFlight/store distribution. See [the reviewer delivery note](../features/reviewer-delivery.md)
and ADR 0003.

## Deliberate limits

- No backend is required for the challenge, so the data source is local and deterministic.
- No general design-system package is created for a single application; tokens live under `lib/app/theme/`.
- Code generation and dependency injection frameworks are added only if their value exceeds their setup cost.
- Optimisation follows measurement. Narrow rebuilds are encouraged, but premature caching and repaint boundaries are not defaults.
