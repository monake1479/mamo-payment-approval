# ADR 0012: User-selectable, persistent theme mode

- Status: Accepted
- Date: 2026-09-21

## Context

The accepted baseline follows the system appearance with no manual selector and
no persistence. This is recorded in the [product Q&A](../product/requirements.md#planning-qa-accepted-decisions)
(Q1) and the [UI contract](../product/ui-contract.md) ("Follow system appearance;
no manual theme switch or persistence in this increment"), and the
[extension backlog](../product/extension-backlog.md) directs contributors to
"preserve baseline criteria and session-only storage unless explicitly changed".

The owner subsequently requested, explicitly, a user-facing appearance control
with three states — System, Light, Dark — whose selection persists across app
launches and defaults to System. That request changes the baseline, so it is
recorded here rather than chosen silently. Light and dark `ThemeData` already
exist in `AppTheme`; only the selection, its persistence, and the surface to
change it are new. The runtime foundation deliberately kept storage session-only
and added no persistence dependency, so introducing one is a material decision.

## Decision

Add an appearance domain under `lib/common/data/appearance/` following the
established shared-data layering:

- `ThemePreference` — a Flutter-free domain enum (`system`, `light`, `dark`) with
  a stable `storageValue` decoupled from `name`.
- `ThemePreferenceLocalDataSource` — the single concrete data source over
  `SharedPreferences`. Reading is total (a missing or unrecognized value means
  "follow the system"); writing returns a typed `AppearanceFailure` through the
  shared `Result`/`Unit` primitives.
- `ThemePreferenceRepository` and `LoadThemePreferenceUseCase` /
  `SaveThemePreferenceUseCase`, registered as `@lazySingleton`, so presentation
  depends on use cases rather than the storage SDK, mirroring the
  device-authentication feature.

Presentation adds a `ThemeModeCubit` (Freezed `ThemeModeState`) that hydrates the
persisted preference during composition and drives `MaterialApp.themeMode`. The
domain enum is mapped to Flutter's `ThemeMode` in a presentation-only extension.
A `Settings` screen, reachable from a labelled action in the Home header and
pushed as `/settings` above the navigation shell, hosts a `ThemeModeSelector`
whose selected option is conveyed by both an indicator icon and accessibility
state, never colour alone.

Adopt `shared_preferences` as the persistence mechanism. It is the smallest,
officially maintained key/value store for a single non-sensitive preference.
Alternatives considered: a hand-rolled file/`dart:io` store (more code and error
handling for no benefit) and keeping the preference session-only (rejected
because the owner explicitly asked for persistence across launches). The
instance is pre-resolved in DI so the initial preference is available before the
first frame, avoiding an appearance flash.

The default remains `System`. Only the non-sensitive appearance preference is
stored; no payment, authentication, or otherwise sensitive data is persisted. A
failed write keeps the applied selection effective for the session; the choice
simply will not survive a restart, and the user can retry by selecting again.

## Consequences

- The app gains its first persistence dependency. It is confined to the
  appearance domain behind a narrow data source and must not become a general
  store for sensitive data (see the backlog's app-PIN note).
- `MamoPaymentApprovalApp` now requires a `ThemeModeCubit`; app composition and
  tests supply it.
- `AppFailureApp` continues to follow the system appearance; the override applies
  to normal app composition only.
- The baseline documents change: `UI-03` is added, Q1 is amended, and the UI
  contract records the appearance control.

## Verification

- Data-source tests cover reading the default, each stored value, an
  unrecognized value, a successful write, and a storage exception mapped to
  `AppearanceFailure.persistenceFailed`.
- Use-case and Cubit tests cover load/default, applying and persisting a
  selection, the no-op reselection, and keeping the applied preference when a
  write fails.
- Widget tests cover the selector (both appearances, 200% text, selected state,
  touch target) and the settings screen; an app-level test covers opening in the
  persisted appearance and toggling from Home through Settings with persistence.
- Bootstrap DI tests assert the new registrations resolve as lazy singletons.
