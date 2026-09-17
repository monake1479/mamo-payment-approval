# ADR 0006: FVM-managed Flutter

- Status: Accepted
- Date: 2026-09-17

## Context and alternatives

The owner requires the latest stable Flutter through FVM. A global SDK makes results depend on the developer's machine; a moving channel alias can change a build without a source change.

## Decision

Pin Flutter 3.47.4 in `.fvmrc`, with its bundled Dart 3.13.3. The [official release manifest](https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json) identified this as the latest stable release when checked on 2026-09-17.

Use `fvm use` to install/link the configured SDK and `fvm flutter` / `fvm dart` for local commands. Keep the generated `.fvm/` directory out of Git; commit the version file and relative VS Code SDK setting. Do not change the global SDK.

CI uses the existing Flutter setup action's `flutter-version-file: .fvmrc` support. It installs the same pinned SDK directly on PATH, avoiding an additional manager installation in the runner. There is no separate CI version pin.

Select the latest stable release when an SDK update is authorized, pin its exact version, resolve dependencies, inspect the lockfile changes, and rerun the quality gate. Do not use a floating channel alias or silently upgrade during unrelated work.

## Consequences and verification

- Each checkout/worktree runs `fvm use` to establish its own SDK link.
- The iOS deployment target is 15.0 after the SDK migration; Android uses Flutter's minimum API 24. This SDK update does not preserve iOS 13/14 support.
- Android uses Gradle 9.3.1, AGP 9.1.0, and Kotlin 2.4.0, matching the pinned Flutter SDK's template versions. This coordinated update replaces the previous versions that triggered Flutter's future-support warnings. Prefer the SDK's known combination over independently selecting the newest Android tooling.
- Kotlin compilation uses AGP's built-in support (`android.builtInKotlin=true`) and `kotlin.compilerOptions`, with Java and Kotlin both targeting JVM 17. The Kotlin declaration in settings pins the compiler dependency without applying the legacy Android Kotlin plugin to the app.
- Keep `android.newDsl=false`: Flutter 3.47's Gradle plugin still accesses legacy AGP DSL types. This is a required compatibility setting, not a warning suppression. Revisit it with a Flutter SDK version that supports the new DSL; do not bypass dependency validation or silence diagnostics.
- VS Code uses the stable relative `.fvm/flutter_sdk` link. Automatic FVM editor rewrites are disabled so the editor configuration does not duplicate the version pin.
- Flutter's SDK migration excludes generated build output and native scaffold directories from Dart analysis. No Dart sources currently live in those scaffold directories; `lib/`, `test/`, strict analysis settings, and all lint rules remain covered and unchanged.
- Record `fvm flutter --version` and `fvm dart --version`; verify they match the configured SDK.
- Run formatting, analysis, and tests through FVM. Check native compilation when the SDK or platform changes; distinguish environment failures from application failures.
- CI execution remains unverified until an authorized push runs the updated workflow.

## References

- [Flutter SDK archive](https://docs.flutter.dev/install/archive)
- [FVM project configuration](https://fvm.app/documentation/getting-started/configuration)
- [Flutter CI version-file support](https://github.com/subosito/flutter-action#use-version-from-pubspecyaml-or-fvm-config)
- [Flutter built-in Kotlin migration](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers)
- [Flutter AGP DSL compatibility](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin)
- [AGP 9.1 compatibility](https://developer.android.com/build/releases/agp-9-1-0-release-notes)
- [Kotlin and Gradle compatibility](https://kotlinlang.org/docs/gradle-configure-project.html)
