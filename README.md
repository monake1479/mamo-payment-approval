# Mamo Approval

A production-minded Flutter implementation of a payment approval flow (the "Mamo Payment Approval" challenge).

The application is intentionally small, but it is structured as code that could evolve safely: business rules are separated from Flutter widgets, external capabilities sit behind interfaces, and acceptance criteria are backed by focused tests.

> Status: project foundation. The user-facing payment flow will be implemented in the next iteration.

## Product scope

The app will provide:

- a home summary for the current month and recent payments;
- a newest-first list of all payments;
- details for payments that have already been approved or rejected;
- an approval overlay with masked sensitive data;
- an explicit device-authentication step before sensitive data is revealed;
- a draggable debug action available on every screen to simulate an incoming payment request.
- a settings screen with the appearance mode and an About section that summarises the delivered scope and shows the installed version/build/environment/package and device-authentication availability.

See [the product requirements](docs/product/requirements.md) for the complete acceptance-criteria map.

## Engineering approach

- Flutter for Android and iOS only.
- Feature-first structure with domain, data, and presentation boundaries added when they earn their place.
- BLoC/Cubit for explicit state transitions and testable business logic.
- `go_router` in app composition, passed to `MaterialApp.router`; feature routes arrive with their screens.
- External capabilities, including device authentication, behind replaceable interfaces.
- Dependency direction from presentation to domain contracts, never from domain code to Flutter.
- Tests chosen at the lowest useful level: Flutter unit tests for logic, widget tests for rendering and interaction, and Maestro for native E2E journeys.

The architecture is described in [docs/architecture/overview.md](docs/architecture/overview.md). Decisions and unresolved trade-offs are recorded under [docs/decisions](docs/decisions).

## Run locally

Install [FVM](https://fvm.app/documentation/getting-started/installation), then run from the repository root:

```sh
fvm use
fvm flutter pub get
fvm flutter run --flavor dev -t lib/main_dev.dart
```

The project pins Flutter 3.47.4 (Dart 3.13.3), the latest stable release verified on 2026-09-17. `.fvmrc` is the SDK version source of truth. Use FVM for local Flutter/Dart commands; no global SDK change is needed. VS Code uses the project-local `.fvm/flutter_sdk` link created by `fvm use`. Reopen the editor window if its analysis server still uses an earlier SDK.

Updates select the latest stable release at the time of the change, then pin an exact version and rerun the checks. Do not track a moving `stable` alias. See [ADR 0006](docs/decisions/0006-fvm-managed-flutter.md).

Select an Android device/emulator (API 24 or newer) or iOS device/simulator (iOS 15 or newer). These minimum versions follow the pinned Flutter SDK and native project configuration. Only Android and iOS platform scaffolds are included.

### Flavors

The app has three native flavors: `dev`, `staging`, and `prod`. Each has a thin entry point calling the same bootstrap, which validates the native flavor and initializes its `get_it` container. All flavors now share the single identity `mamo.payment.approval` and the launcher name `Mamo Approval`, so they cannot be installed side by side; the flavors only select the Dart entry point and native scheme. See [the flavor decision](docs/decisions/0007-native-flavors.md), [the single-identity decision](docs/decisions/0012-single-application-identity.md), and [bootstrap decision](docs/decisions/0010-bootstrap-and-local-error-boundary.md).

```sh
fvm flutter run --flavor dev -t lib/main_dev.dart
fvm flutter run --flavor staging -t lib/main_staging.dart
fvm flutter run --flavor prod -t lib/main_prod.dart
```

Always specify the matching entry point and native flavor. There is no implicit `main.dart`; the native default alone does not select a Dart entry point. VS Code provides three launch configurations; Xcode provides three shared schemes with matching targets. Build mode is independent of flavor: `prod --debug` is valid, and `staging --release` does not select production.

Use an explicit flavor for artifacts and E2E runs:

```sh
fvm flutter build apk --flavor prod -t lib/main_prod.dart --release
fvm flutter build ios --flavor prod -t lib/main_prod.dart --release --no-codesign
fvm flutter build ios --flavor dev -t lib/main_dev.dart --simulator --debug
```

The APK is written to `build/app/outputs/flutter-apk/app-prod-release.apk`. Android release builds still use the debug signing key; they are not store-ready releases. Unsigned iOS device builds are compilation evidence, not installable distributions. Simulator builds use `build/ios/iphonesimulator/Runner.app`; copy or install each one before building another flavor because this output path is reused.

### Branding (placeholder)

The launcher icon and native splash are **placeholders**: a white `MA` monogram on the brand colour (`#6938EF`, the `app_theme` seed). Source art lives in `assets/branding/`; generation is configured in `flutter_launcher_icons.yaml` and `flutter_native_splash.yaml`. Replace the source art and regenerate before release:

```sh
fvm dart run flutter_launcher_icons
fvm dart run flutter_native_splash:create
```

## Quality gate

```sh
fvm flutter gen-l10n
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
python3 -B -m unittest discover -s tool/tests -p 'test_*.py'
```

CI is configured for PRs targeting `dev` or `main` and pushes to both branches. It checks PR direction and uploads logs. The setup action reads `.fvmrc` directly and places that exact SDK on PATH, so CI runs Flutter/Dart commands without a separate FVM installation. Local commands use the FVM wrapper.

Maestro is the selected Android/iOS E2E tool. Foundation launch/resume and configuration-failure flows live under `maestro/`; payment journeys are added with their slices. CI does not run Maestro yet. See [the testing strategy](docs/testing/strategy.md) and [Maestro workflow](.ai/workflows/maestro-e2e.md) for build pairing, commands, and evidence.

CI enforces `pubspec.lock` and scans publishable files/history with pinned Gitleaks.
Run `python3 tool/scan_secrets.py` locally with Gitleaks 8.30.1 on PATH, or supply
`--binary`. See [configuration hygiene](docs/architecture/configuration-hygiene.md).

### Local push guard

After checkout setup, run `sh tool/install_hooks.sh` once per worktree (Python 3 on macOS/Linux and FVM required). Cloning does not activate hooks. The hook checks committed inputs, runs tests selected from the pushed changes, and blocks on failure. Documentation-only pushes run no Flutter checks; shared or unmapped changes use the full suite. CI always runs the full suite.

An explicitly owner-approved, single-attempt exception may omit the selected local Flutter tests. Requests, approvals, actual use, and check logs stay in local Git metadata; include sanitized records in PR evidence when publishing. See [the push workflow](.ai/workflows/push-gate.md) for installation, selection, commands, and enforcement limits.

## Application copy

Flutter UI text is authored in `lib/l10n/app_en.arb`, with English descriptions for each message, and read through generated `AppLocalizations`. English is the only supported locale; unsupported device languages fall back to English. Run `fvm flutter gen-l10n` after changing ARB files. `flutter pub get` also generates the classes when preparing a checkout.

Generated files under `lib/l10n/generated/` are ignored and must not be edited manually. CI regenerates them before analysis and tests. Native launcher names are configured by flavor outside the Dart runtime. See [ADR 0008](docs/decisions/0008-localization.md) for these boundaries.

## Development and review

Each runnable slice enters `dev` through a PR. Verified increments reach `main` through a separate promotion PR from `dev`. Preserve review discussions and record verification against a source commit.

Local review does not require a PR. Agents may merge or enable auto-merge only after the owner explicitly authorizes that specific merge; passing checks and review acceptance are not authorization.

See [the review loop](.ai/workflows/review-loop.md), [PR template](.github/pull_request_template.md), and [implementation plan](docs/implementation-plan.md). Branch protection and automated reviewer integrations require separate configuration and are not implied by these documents.

## Repository map

```text
lib/
  app/                         # Application composition, navigation, and theme
  core/                        # Cross-feature primitives only when genuinely shared
  features/payments/
    data/                      # Repository implementations and local/demo data source
    domain/                    # Payment model, contracts, and business rules
    presentation/             # Pages, widgets, and BLoC/Cubit state
docs/
  architecture/               # System boundaries and dependency rules
  decisions/                  # Small architecture decision records
  product/                    # Requirements and acceptance criteria
  testing/                    # Test strategy and coverage expectations
.ai/                           # Concise, tool-agnostic instructions for AI-assisted work
```

## Delivery

The final submission will include:

- the source repository;
- an installable Android APK with instructions;
- iOS source support and verification, without a TestFlight/store delivery requirement;
- a short implementation note covering decisions, trade-offs, and what would be improved with more time.

The About section on the settings screen carries an in-app summary of the delivered scope (`DELIVERY-03`, [ADR 0015](docs/decisions/0015-about-section-and-package-info.md)); decisions and limitations remain only in the repository documentation.

Reviewer access without compilation remains required. Candidate original additions live in [the extension backlog](docs/product/extension-backlog.md) for joint selection after the baseline flow works.
