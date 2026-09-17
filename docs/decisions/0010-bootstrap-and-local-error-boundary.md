# ADR 0010: Bootstrap and local error boundary

- Status: Accepted
- Date: 2026-09-17

## Decision

Use three thin entry points (`main_dev.dart`, `main_staging.dart`, `main_prod.dart`)
and one bootstrap. This replaces ADR 0007's initial single-entrypoint arrangement.
The entry point and Flutter's native `appFlavor` must agree at runtime, not only
in assertions. Keep binding initialization and `runApp` in the same zone.

Use `get_it` with manual registration in `configureDependencies`, receiving the
selected environment. One process-wide `getIt` instance is configured once;
composition resolves dependencies and consumers use constructor injection. Only
the environment, local diagnostics, and app router exist today. Add per-environment adapters
when actual capabilities differ, not three identical registration branches or
code generation in anticipation of future services.

Startup is a linear sequence: initialize bindings, validate the environment,
await `configureDependencies(environment)`, configure error handlers, then
`runApp`. It needs no lifecycle controller, observable root state, widget-owned
container disposal, or navigator replacement. Tests reset `getIt` between cases.

Startup failures launch localized failure UI and return before normal app launch.
`FlutterError.onError` and `PlatformDispatcher.onError` record sanitized local
diagnostics. `ErrorWidget.builder` uses a widget class for localized build-error
UI, including when no localization ancestor exists. Runtime logging does not
navigate, restart the app, or replace its state. Expected operation failures still
need explicit typed outcomes and feature-owned recovery; global hooks do not
establish business success or failure and do not supervise custom isolates.

Local diagnostics accept only enum codes/origins, environment,
and at most twelve allowlisted app source locations. They never accept
an exception message, arbitrary context, payload, or complete stack. Records go to
the local developer log; there is no persistence, remote telemetry, or external
crash SDK, diagnostic reference registry, or automatic operation replay.

## Alternatives and consequences

- A single entry point using only `appFlavor` is valid, but explicit entry points
  make launch intent visible in IDE/build commands. Runtime validation prevents
  their independent selectors from silently diverging.
- The locator is confined to composition, not used from business methods.
  Manual registration is sufficient; generated registration has no current benefit.
- A universal `Result` wrapper and feature-wide failure hierarchy are unnecessary
  before business operations exist. The current three codes describe real app
  failures, exhaustively mapped to `AppLocalizations` in UI.
- Sanitized diagnostics deliberately lose exception detail. Debug locally with a
  debugger; never loosen logging to include payment or authentication payloads.
- A build-error widget is not a universal recovery mechanism or an automatic
  session reset. Tests and analysis must catch programming defects. Error-handler
  tests restore the Flutter test harness themselves; no production cleanup
  controller exists solely to support tests.

## Navigation composition

Use the owner-selected `go_router` through `MaterialApp.router`. A singleton
in `getIt` owns its lifetime and disposes it on container reset. Create it during
dependency configuration so initialization errors stay inside the startup catch.
The stateless app
receives the router through its constructor; rebuilding widgets cannot recreate
navigation state. One factory declares real routes directly, without an additional
router service or generated route layer. This provides the selected declarative
navigation API without building a custom Navigator integration.
The `cupertino_icons` asset package supplies the font referenced by the router's
Cupertino dependency; retain it to avoid missing-font warnings in release builds.

Initially `/` displays the foundation page; unknown paths use safe localized error
UI and never render the URI or `state.error`. `AppFailureApp` deliberately uses a
standalone `MaterialApp` so startup/build errors need neither working DI nor router.
Future feature routes and origin-preserving back behavior are implemented and
tested with their feature slices, not represented by empty screens now.

## Verification

See [the runtime contract](../product/runtime-foundation.md), bootstrap/widget
tests, and native configuration checks. Run all flavor builds after entrypoint or
native configuration changes. Verify configuration rejection in a release-mode
build as well as unit tests; a debug-only assertion is insufficient.

## References

- [Flutter error handling](https://docs.flutter.dev/testing/errors)
- [Flutter native flavors](https://docs.flutter.dev/deployment/flavors)
- [get_it](https://pub.dev/packages/get_it)
- [go_router](https://pub.dev/packages/go_router)
