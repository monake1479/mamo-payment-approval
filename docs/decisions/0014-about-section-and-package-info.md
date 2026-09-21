# ADR 0014: In-app About section and the package_info_plus dependency

- Status: Accepted (coordinator-selected under delegated authority; subject to owner review)
- Date: 2026-09-21

## Context

`DELIVERY-02` requires the repository to explain key decisions and what would be
improved with more time. That explanation lived only in documentation. The
coordinator asked for an in-app counterpart on the existing settings screen
(ADR 0013) so a reviewer holding the APK can see what the app does, what was
delivered, the known limitations, the installed version/build/environment/package
identity, and whether native device authentication is available on the device,
without opening the repository. The owner rejected a licences page, so none is
added.

The installed version, build number, and package identifier are platform facts
that the Dart runtime cannot read without a plugin. The active environment is
already known to composition as the validated `AppEnvironment` (ADR 0007).
Device-authentication availability is already exposed by
`IsLocalAuthSupportedUseCase`.

## Decision

Add an About section to the existing settings screen rather than a second
settings surface or a separate route. The section has a static part (what the
app does, what is included, known limitations) authored as English ARB
resources, and a dynamic part loaded once per visit.

Adopt `package_info_plus` to read the installed build identity. Alternatives
considered: hardcoding the `pubspec.yaml` version through a generated constant
(drifts from the native build number and cannot show the installed package
identifier of the active flavor), and a small hand-written platform channel
(duplicates a maintained federated plugin for no benefit). The plugin is the
smallest maintained option and is verified against the pinned SDK; the lockfile
and `ios/Podfile.lock` are updated with it.

Add an application-information domain under `lib/common/data/app_info/`
following the shared data layering (ADR 0011): `AppBuildInfo` (Freezed model),
`AppInfoFailure` (typed failure, code `app_info.unavailable`),
`PackageInfoClient` (the single concrete data source), `AppInfoRepository`, and
`LoadAppBuildInfoUseCase`, all lazy singletons. The data source reads the
federated `PackageInfoPlatform` seam directly instead of the plugin's static
`PackageInfo.fromPlatform()` accessor: the static accessor caches its first
success process-wide with no reset, which would make the failure path
untestable next to the success path. Every plugin exception is translated into
the typed failure at this boundary. `package_info_plus_platform_interface` is
therefore a runtime dependency, mirroring `shared_preferences_platform_interface`.

The section state is owned by a screen-scoped `AboutCubit` with a Freezed
sealed `AboutState` (`loading`, `loaded`, `failed`). Loading the section is a
single request-to-result operation over two ready-to-emit inputs (the build
identity result and the availability boolean), not a stream of events, so a
Cubit is used rather than a BLoC. The Cubit never starts authentication; it only
reads availability. The router's settings route creates the Cubit through a
factory supplied by composition, starts its single load, and closes it when the
route is popped, so every visit re-reads availability and nothing about the
device is cached in presentation. `AppEnvironment` is injected into the Cubit
by composition because it is a static launch fact, not fetched data, and the
shared data layer must not depend on `lib/app/`.

## Consequences

- The app gains a second platform plugin, confined to the application-information
  domain behind a narrow data source. It reads no sensitive data.
- `MamoPaymentRouter` now requires an `AboutCubit` factory; composition and
  app-level tests supply it.
- The settings screen requires an `AboutCubit` above it, provided by the route.
- `DELIVERY-03` records the in-app handover summary as an acceptance criterion;
  the static copy must be kept truthful as features and limitations change.
- No licences page is added; the owner rejected it.

## Verification

- Data-source and use-case tests cover mapping the platform data and translating
  plugin exceptions into `AppInfoFailure.unavailable`.
- Cubit tests cover the initial loading state, a loaded result with availability
  true and false (asserting no authentication call), the failure path, a retry
  that passes through loading, an ignored duplicate in-flight load, and no
  emission after close.
- Widget tests cover the loading, loaded (all five rows), unavailable, and failed
  states with retry and its touch target, in both appearances at 200% text on a
  compact width; settings-page tests cover the section alongside the appearance
  chooser, including interaction while About is still loading.
- Bootstrap DI tests assert the new registrations resolve as lazy singletons.
