# Reviewer APK delivery

## Scope

The `Android reviewer build` GitHub Actions workflow provides the no-compile Android handover required by `DELIVERY-01`. It builds the `prod` flavor in release mode from the pull-request source head and publishes an installable APK as an artifact of this private repository.

This is a reviewer channel, not a store release. The APK uses Android's debug signing key, generated on the GitHub-hosted runner, and is labelled `debug-signed` in both its filename and bundled instructions. No signing key, repository secret, external crash service, GitHub Release, or public hosting is involved.

## When it runs

The workflow runs for pull requests into `dev` or `main`. It can also be started manually with `workflow_dispatch` after the workflow exists on the repository's default branch. Pull-request builds check out and verify the source head SHA directly, so the delivered APK has an unambiguous source revision and does not depend on this workflow already being merged.

Concurrency cancellation keeps only the newest run for a pull request or branch. The build is intentionally separate from the existing CI quality job: it installs the enforced lockfile, generates localizations, and compiles the native artifact without duplicating the full format, analysis, and test gate.

## Artifact contents and access

The workflow uploads one private Actions artifact retained for 30 days. Reviewers must have access to this repository and can download it from the workflow run summary or the run's **Artifacts** section.

The archive contains:

- `mamo-reviewer-prod-release-debug-signed.apk` — the installable Android API 24+ package;
- `SHA256SUMS.txt` — the APK SHA-256 digest;
- `source-commit.txt` — the exact source head used by the build;
- `flutter-version.txt` — the Flutter and Dart versions actually used, checked against `.fvmrc`;
- `apk-signature.txt` — `apksigner` verification output showing the Android debug certificate;
- `README.md` — short verification and installation instructions.

To install after downloading and extracting the artifact:

```sh
sha256sum -c SHA256SUMS.txt
adb install -r mamo-reviewer-prod-release-debug-signed.apk
```

Launch **Mamo** on the device. Android may require the user to approve installation through their chosen local transfer method; `adb` installation requires USB debugging and an authorized device.

## Provenance and limitations

The job reads the SDK version from `.fvmrc`, records the actual `flutter --version` and `dart --version`, and fails if the resolved Flutter framework version differs from the pin. It builds with:

```sh
flutter pub get --enforce-lockfile
flutter gen-l10n
flutter build apk --flavor prod -t lib/main_prod.dart --release
```

The Android Gradle release configuration currently selects the debug signing config. The job also verifies the built APK with the Android SDK's `apksigner` and requires the signer certificate output to identify `Android Debug` before upload.

This artifact does not claim production signing, Play Store readiness, durable payment execution, or independent native-authentication evidence. Application data is session-only and resets when the OS process is terminated. CI compilation and signature verification do not replace device installation, critical-journey, or physical-device authentication checks; those remain separate delivery evidence when the corresponding features are integrated.
