# About section

This slice adds an About section to the settings screen (`DELIVERY-03`), the
in-app counterpart of the repository handover notes required by `DELIVERY-02`.
See [ADR 0014](../decisions/0014-about-section-and-package-info.md) for the
dependency and ownership decisions.

## Contract and integration

Application information follows the shared data layering.
`LoadAppBuildInfoUseCase` delegates to `AppInfoRepository`, which delegates to
`PackageInfoClient`, the concrete data source over the `package_info_plus`
platform seam (`PackageInfoPlatform`). The data source returns
`Result<AppInfoFailure, AppBuildInfo>`; `AppInfoFailure.unavailable` carries the
stable code `app_info.unavailable` and is the only failure, produced when the
platform cannot report the installed package.

`AboutCubit` (Freezed sealed `AboutState`: `loading`, `loaded`, `failed`) owns
the section for one visit. `load()` reads the build identity and probes
device-authentication availability through the existing
`IsLocalAuthSupportedUseCase`, then emits one combined result. It never starts
authentication. A repeated `load()` while one is in flight is ignored; a call
after a failure retries through `loading`; nothing is emitted after close. The
validated `AppEnvironment` is injected (the plugin reports no flavor) and
rendered as the environment row. The page owns the Cubit: `AboutCubit` is an
`@injectable` factory, and `SettingsPage` provides it at its top with
`BlocProvider(create: (_) => getIt<AboutCubit>()..load())`, so the provider
creates, loads, and closes a fresh instance per visit. The router provides
nothing. Failure and environment copy are private methods of
`AboutDetailsCard`.

## Surface and accessibility

`AboutSection` sits below the appearance chooser on the settings screen under an
"About" heading. `AboutDetailsCard` renders the Cubit state: a live-region
loading row; a live-region failure message with a "Try again" action that stays
above the 48-pixel minimum; or five `AboutDetailRow`s — Version, Build,
Environment, Package, and Device authentication — each with a stable
`settings.about.<row>` semantics identifier and a selectable value. The
device-authentication row conveys availability through its text and icon
(fingerprint versus blocked), never colour alone. `AboutSummaryCard` holds the
static description, the "What is included" list, and the "Known limitations"
list as `AboutBulletList`s; bullets are decorative and excluded from semantics.
All copy is English ARB resolved through `AppLocalizations`.

## Scope and limits

The section is read-only: it reads availability but never authenticates, and it
adds no licences page (rejected by the owner). Static copy must be updated when
delivered features or limitations change; it summarises, it does not replace,
the repository documentation. The package identifier shown is the installed
one, so a `dev` or `staging` install shows that flavor's suffixed identifier.

## Verification

`DELIVERY-03` maps to the application-information data-source and use-case
tests, the About Cubit tests, the About section widget tests, the settings-page
tests, and the bootstrap DI registration checks. They cover platform data
mapping and exception translation; loading, loaded (available and unavailable,
with no authentication call), failed, retry, duplicate in-flight, and
post-close behaviour; all five detail rows, the failure with retry and its touch
target, and both appearances at 200% text on a compact width; and the section
alongside a usable appearance chooser while About is still loading. Rendered
device evidence remains a separate manual step.
