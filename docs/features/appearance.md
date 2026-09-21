# Appearance mode

This slice adds a user-selectable, persistent appearance mode — System, Light, or
Dark — satisfying `UI-03`. It builds on the existing system-following light/dark
themes in `AppTheme`; see [ADR 0013](../decisions/0013-persistent-theme-mode.md)
for why the baseline changed.

## Contract and integration

The capability follows the shared data layering. `LoadThemePreferenceUseCase` and
`SaveThemePreferenceUseCase` expose it to presentation and delegate to
`ThemePreferenceRepository`, which delegates to `ThemePreferenceLocalDataSource`,
the concrete `SharedPreferences` data source (no interface). The data source owns
the storage SDK calls and translates storage failures into typed results, so the
repository never handles raw storage exceptions.

`ThemePreference` is the appearance-domain enum. Its `storageValue` is a stable
string, decoupled from `name`, so a future rename cannot invalidate a stored
value. The same file carries the `ThemePreferenceMaterial` extension that maps
the enum onto Flutter's `ThemeMode`, so the enum file is the one place that
imports Flutter within the appearance data domain. Reading is total: a missing or unrecognized value resolves to
`ThemePreference.system`. Writing returns `Result<AppearanceFailure, Unit>`;
`AppearanceFailure.persistenceFailed` carries the stable code
`appearance.persistence_failed`.

`ThemeModeCubit` owns the selected preference (Freezed `ThemeModeState`). It is a
process-wide singleton, hydrated once during composition via `loadInitial()` so
the app opens in the stored appearance without a flash, and it drives
`MaterialApp.themeMode`. `select` applies the new value immediately, then
persists it. A failed save keeps the in-session selection rather than reverting
a deliberate choice, and is stored in the state as a typed `AppearanceFailure`;
the settings screen maps it to a localized snackbar, and selecting the same
option again retries the save. A save result that arrives after a newer
selection is discarded. `App` maps the enum to Flutter's `ThemeMode`
through `ThemePreferenceMaterial`; the Cubit and its state stay Flutter-free
apart from the `bloc` base class.

## Surface and accessibility

A labelled `Settings` action in the Home header opens the `/settings` route,
pushed above the navigation shell like payment details. The settings screen hosts
`ThemeModeSelector`, a mutually exclusive System/Light/Dark chooser that renders
one `ThemeModeOption` row per `ThemeModeOptionData` entry. Each option is a
full-width target that stays taller than the 48-pixel minimum at 200% text,
carries a stable `settings.themeMode.<value>` semantics identifier and radio
selection semantics, and shows its selected state through an indicator icon as
well as colour. All copy is English ARB resolved through `AppLocalizations`.

## Persistence and scope

Only the non-sensitive appearance preference is stored, through
`shared_preferences`. No payment or authentication data is persisted. The default
is `System`. Reading tolerates a missing, unrecognized, or non-string stored
value. If the platform store cannot be opened during composition, the
preferences module installs `SessionOnlySharedPreferencesStore`, which reads as
empty and refuses writes, so the app still starts in the system appearance and
every save reports the persistence failure instead of blocking startup. `AppFailureApp` continues to follow the system appearance; the
override applies to normal app composition only.

## Verification

`UI-03` maps to the appearance data-source, use-case, Cubit, selector, settings,
and app-level theme-mode tests, plus the bootstrap DI registration checks. They
cover the stored default, each value, and a non-string stored value; a failed
save surfacing in state and on the settings screen, retry, and a newer selection
clearing the failure; composition over an unavailable platform store; applying
and persisting a selection; opening in the persisted appearance; and toggling
from Home through Settings. The selector itself is verified in both appearances
at 200% text.
