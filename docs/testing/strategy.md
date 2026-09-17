# Testing Strategy

Tests are placed at the lowest level that proves the behaviour reliably.

Use FVM for local Flutter/Dart commands with the version pinned in `.fvmrc`. CI reads that same pin directly. Record the SDK actually used; see [ADR 0006](../decisions/0006-fvm-managed-flutter.md).

Maestro is the selected mobile E2E tool; see [ADR 0005](../decisions/0005-maestro-for-mobile-e2e.md). Flutter unit/widget tests remain mandatory. Do not add a duplicate `integration_test` or other full-app suite without a specific gap that Maestro cannot cover.

## Native flavor configuration

For native flavor changes, follow the compilation and packaged-identity checks in [ADR 0007](../decisions/0007-native-flavors.md). `dev`, `staging`, and `prod` share Dart behaviour, so the shared widget suite runs once; native configuration needs per-flavor evidence. Record the selected flavor and its platform-specific app ID for every E2E run.

## Unit tests

Use unit tests for:

- payment status transitions and repeated-action protection;
- current-month totals and rejection exclusion;
- newest-first and recent-payment ordering;
- masking and reveal state;
- successful, failed, unavailable, and cancelled authentication;
- BLoC/Cubit transitions and stale or repeated actions.
- Normalization of external error codes and presentation mapping of every concrete failure to `AppLocalizations`, including safe unknown-code fallback and allowlisted parameters. These tests arrive with the first failure-producing operation.

## Widget tests

Use widget tests for:

- generated localization wiring, English/regional-English locale resolution, unsupported-locale fallback, localized application title, and compact/expanded foundation rendering with large text;
- home, list, details, and overlay states;
- navigation back to the originating screen;
- foundation `go_router` injection, root stack behavior, location retention across rebuilds, and safe unknown-route recovery; startup/build errors render without router initialization;
- the approval overlay remaining above the active route;
- masked and revealed content;
- debug-action visibility, dragging, and session position;
- compact and expanded layouts, semantics, loading, empty, and error states.

## Maestro end-to-end tests

Keep a small set of critical journeys, introduced with their implementation slices:

1. Generate a request, authenticate, approve, and verify the list and monthly summary.
2. Generate a request, reject it, and verify return navigation and excluded totals.
3. Navigate between screens and verify the debug action retains its position.
4. Open decided-payment details from Home and Payments and return to the originating screen.

The runtime foundation adds `maestro/foundation.yaml` (normal launch and resume,
`RUNTIME-01/03`) and `maestro/configuration_failure.yaml` (safe mismatched-flavor
rejection, `RUNTIME-01/03`). The failure flow requires an Android build with
`--flavor dev -t lib/main_prod.dart --release`; it is not a production test flag.
Reinstall the correctly paired build after that test. Both flows operate only on
the supplied `APP_ID`; normal launch resets that test installation. Privacy-preview
inspection is separate from a passing resume assertion. A seeded payments-list
flow arrives with slice 1. Keep flows under `maestro/`.

Use Android emulators and iOS simulators for repeatable local runs, with deterministic data/session reset and stable semantics identifiers. Each journey must run independently. Cover affected states and materially different layouts; use lower-level tests for exhaustive combinations. The [Maestro workflow](../../.ai/workflows/maestro-e2e.md) defines authoring, commands, artifact collection, and reruns.

## Native authentication verification

Keep deterministic authentication fakes in unit/widget tests and exercise the native adapter in full-app journeys. Do not silently bypass authentication for Maestro. Simulator/emulator authentication input, where supported, must be labelled as simulated rather than real-device biometric evidence.

Separately verify real authentication success, cancellation, failure/unavailability, and lifecycle behaviour on iOS and Android devices. Record hardware, OS, setup, and limitations. Current Maestro iOS execution targets simulators; real iOS-device checks are manual. If a native step cannot be automated, report it as manual or blocked, not a passing automated flow. Native fallback and lifecycle policy remain owner decisions.

## Local push tooling

Run `python3 -B -m unittest discover -s tool/tests -p 'test_*.py' -v` for tooling changes and full verification. The suite uses disposable local Git repositories and a fake FVM executable: it covers change-based test selection, full-suite fallbacks, actual local push blocking, check failures, clean-input validation, single-use approved exceptions, concurrent consumption, invalid journals, and worktree-local installation. It never contacts GitHub or substitutes for real Flutter tests.

The pre-push hook uses [the explicit impact map](../../tool/test_scope.py). Documentation-only changes require no Flutter run; mapped app/test changes select consumer tests; shared/unknown/deleted inputs or unavailable history fall back to all Flutter tests. Add mapping coverage with each slice. CI always runs full Flutter and tooling suites. Follow [the push workflow](../../.ai/workflows/push-gate.md) for setup and audited exceptions; branch protection remains separate.

## Evidence contract

Use the [verification record template](evidence-template.md) and the [mamo-verify skill](../../.ai/skills/mamo-verify/SKILL.md) to turn these expectations into selected checks and an honest result record.

Each PR identifies criteria, test files/scenarios, source commit, exact commands, results, and CI run/artifact links. UI evidence includes device/OS, viewport/orientation, text scale, and screenshots or recording. Label manual observations and unrun checks honestly.

Maestro evidence adds CLI version, installed app binary checksum/build mode, deterministic setup, flow results, JUnit XML, and diagnostic artifacts under ignored `build/maestro/`. Before committing, identify local source and flow changes with a checksummed snapshot including untracked inputs, not just HEAD. Publish relevant evidence with the PR; a local path is not reviewer access.

CI retains format, analysis, and machine-readable test logs for 30 days. Preserve evidence needed beyond that period before expiry. Logs must contain no sensitive payment/authentication data.

Current coverage includes runtime startup/flavor/error-handler tests, localized
failure/foundation layout tests, push-tooling and scanner-wrapper regression tests,
and native foundation Maestro flows. Swift `RunnerTests` cover the privacy cover
itself; run through the `dev` Xcode scheme on a selected simulator. These tests do
not replace OS app-switcher inspection. CI enforces the lockfile, runs pinned
Gitleaks, generates localizations, and runs format/analyze/full Flutter and tooling
tests, not native tests or Maestro. Payment coverage arrives with each slice. No
arbitrary coverage percentage replaces meaningful scenario coverage.

Use controlled futures/fake time for duplicate decisions, stale loads, request replacement, and completion after disposal. Cover compact/expanded layouts, long content, large text, semantics, and safe-area changes. Add regression tests for reproduced defects where practical.

Follow `.ai/workflows/review-loop.md` and `.ai/workflows/quality-gate.md` for review and reruns.
