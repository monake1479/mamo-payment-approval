# Testing Strategy

Tests are placed at the lowest level that proves the behaviour reliably.

Use FVM for local Flutter/Dart commands with the version pinned in `.fvmrc`. CI reads that same pin directly. Record the SDK actually used; see [ADR 0006](../decisions/0006-fvm-managed-flutter.md).

Maestro is the selected mobile E2E tool; see [ADR 0005](../decisions/0005-maestro-for-mobile-e2e.md). Flutter unit/widget tests remain mandatory. Do not add a duplicate `integration_test` or other full-app suite without a specific gap that Maestro cannot cover.

## Native flavor configuration

For native flavor changes, follow the compilation and packaged-identity checks in [ADR 0007](../decisions/0007-native-flavors.md). `dev`, `staging`, and `prod` share Dart behaviour, so the shared widget suite runs once; native configuration needs per-flavor evidence. Record the selected flavor and its platform-specific app ID for every E2E run.

## Unit tests

Use unit tests for:

- payment status transitions and repeated-action protection;
- current-month approved-only totals/counts, excluding pending and rejected payments;
- valid whole-fils `double` amounts and fixed English AED formatting (for example `AED 1,234.56`) independent of device locale; after the remaining ADR 0002 details are agreed, test boundary validation and comparison/summation without visible floating-point artefacts. Do not add a business-rounding feature to cover hypothetical fractional-fils payments;
- pending-request exclusion from Home recent items and Payments history;
- newest-decision-first history/recent-payment ordering, including older requests decided now; monthly membership by decision time, distinct from creation time;
- UTC/ISO 8601 round trips; account-zone month/year boundaries (inclusive start, exclusive end); unchanged totals after device-zone changes; alternate IANA zones including a daylight-saving transition to detect a hardcoded Dubai offset;
- masking and reveal state;
- successful, failed, unavailable, and cancelled authentication;
- approval blocked before authenticated disclosure, authentication alone causing no decision, and rejection requiring no authentication (`APPROVAL-04/05`);
- actual backgrounding revoking reveal/approval authorization; stale authentication completion after backgrounding or disposal remaining ineffective; fresh authentication restoring disclosure, distinct from transient inactivity caused by the native prompt (`APPROVAL-10`);
- BLoC/Cubit transitions and stale or repeated actions.
- Normalization of external error codes and presentation mapping of every concrete failure to `AppLocalizations`, including safe unknown-code fallback and allowlisted parameters. These tests arrive with the first failure-producing operation.

## Widget tests

Use widget tests for:

- generated localization wiring, English/regional-English locale resolution, unsupported-locale fallback, localized application title, and compact/expanded foundation rendering with large text;
- home, list, details, and overlay states;
- navigation back to the originating screen;
- foundation `go_router` injection, root stack behavior, location retention across rebuilds, and safe unknown-route recovery; startup/build errors render without router initialization;
- the approval overlay remaining above the active route;
- outside tap, swipe, and Back leaving the approval overlay/request intact; failed decisions remaining open for recovery;
- the FAB staying visible but unable to create, queue, or replace a request while another is active;
- masked and revealed content;
- Approve unavailable before authenticated disclosure and after background remasking, Reject available without authentication, and remasking covering semantics/copyable content without closing the overlay or adding an app-wide lock;
- debug-action visibility, dragging, and session position;
- compact and expanded portrait layouts, semantics, loading, empty, error, and success states in both implemented light and dark appearances (`UI-01/02`).

## Maestro end-to-end tests

Keep a small set of critical journeys, introduced with their implementation slices:

1. Generate a request, authenticate, approve, and verify the list and monthly summary.
2. Generate a request, reject it without authentication, and verify return navigation and excluded totals.
3. Navigate between screens and verify the debug action retains its position.
4. Open decided-payment details from Home and Payments and return to the originating screen.

The repository includes `maestro/foundation.yaml` (normal launch and resume,
`RUNTIME-01/03`) and `maestro/configuration_failure.yaml` (safe mismatched-flavor
rejection, `RUNTIME-01/03`), plus payment list/details, approval rejection/origin,
native-approval preparation/verification, and draggable-action flows. The native
approval pair brackets the real operating-system authentication event instead of
bypassing it. The failure flow requires an Android build with
`--flavor dev -t lib/main_prod.dart --release`; it is not a production test flag.
Reinstall the correctly paired build after that test. Flows operate only on the
supplied `APP_ID`; normal launch resets that test installation. Privacy-preview
inspection is separate from a passing resume assertion. Keep flows under `maestro/`.

Use Android emulators and iOS simulators for repeatable local runs, with deterministic data/session reset and stable semantics identifiers. Each journey must run independently. Cover affected states and materially different layouts; use lower-level tests for exhaustive combinations. The [Maestro workflow](../../.ai/workflows/maestro-e2e.md) defines authoring, commands, artifact collection, and reruns.

## Native authentication verification

Keep deterministic authentication fakes in unit/widget tests and exercise the native adapter in full-app journeys. Do not silently bypass authentication for Maestro. Simulator/emulator authentication input, where supported, must be labelled as simulated rather than real-device biometric evidence.

Separately verify native authentication success, cancellation,
failure/unavailability, and lifecycle behaviour on iOS and Android. Cover
biometrics and the operating system's device PIN/passcode fallback, including no
available credential. Verify that the native prompt's own lifecycle transitions do
not invalidate a successful result, while actually switching away remasks the
request and prevents a late authentication result from revealing it. Return must
preserve the overlay, require fresh authentication for disclosure/approval, and
impose no global app lock. Confirm that successful authentication still requires a
separate Approve action. Unit/widget coverage implements these state contracts;
native observations remain separate platform evidence and must identify the tested
binary.

Record hardware, OS, setup, and limitations without capturing credentials. Current
Maestro iOS execution targets simulators; real iOS-device checks are manual. If a
native step cannot be automated, report it as manual or blocked, not a passing
automated flow. Process termination resets the session. A decision submitted before
backgrounding may complete once, with its terminal UI effect consumed once after
resume.

## Local push tooling

Run `python3 -B -m unittest discover -s tool/tests -p 'test_*.py' -v` for tooling changes and full verification. The suite uses disposable local Git repositories and a fake FVM executable: it covers change-based test selection, full-suite fallbacks, actual local push blocking, check failures, clean-input validation, single-use approved exceptions, concurrent consumption, invalid journals, and worktree-local installation. It never contacts GitHub or substitutes for real Flutter tests.

The pre-push hook uses [the explicit impact map](../../tool/test_scope.py). Documentation-only changes require no Flutter run; mapped app/test changes select consumer tests; shared/unknown/deleted inputs or unavailable history fall back to all Flutter tests. Add mapping coverage with each slice. CI always runs full Flutter and tooling suites. Follow [the push workflow](../../.ai/workflows/push-gate.md) for setup and audited exceptions; branch protection remains separate.

## Evidence contract

Use the [verification record template](evidence-template.md) and the [mamo-verify skill](../../.ai/skills/mamo-verify/SKILL.md) to turn these expectations into selected checks and an honest result record.

Each PR identifies criteria, test files/scenarios, source commit, exact commands, results, and CI run/artifact links. UI evidence includes device/OS, viewport/orientation, text scale, and screenshots or recording. Label manual observations and unrun checks honestly.

Maestro evidence adds CLI version, installed app binary checksum/build mode, deterministic setup, flow results, JUnit XML, and diagnostic artifacts under ignored `build/maestro/`. Before committing, identify local source and flow changes with a checksummed snapshot including untracked inputs, not just HEAD. Publish relevant evidence with the PR; a local path is not reviewer access.

CI retains format, analysis, and machine-readable test logs for 30 days. Preserve evidence needed beyond that period before expiry. Logs must contain no sensitive payment/authentication data.

Current coverage includes runtime startup/flavor/error-handler tests, localized
failure/theme layout tests, push-tooling and scanner-wrapper regression tests,
payment domain/data/collection-state tests, Home/Payments/details widget tests,
native-authentication adapter/controller tests, approval-overlay/lifecycle widget
tests, and native foundation/payment/rejection/debug-action Maestro flows. Swift
`RunnerTests` cover the privacy cover itself; run them through the `dev` Xcode
scheme on a selected simulator. These tests do not replace OS app-switcher
inspection. CI enforces the lockfile, runs pinned Gitleaks, generates
localizations, and runs format/analyze/full Flutter and tooling tests, not native
tests or Maestro. No arbitrary coverage percentage replaces meaningful scenario
coverage.

Use controlled futures/fake time for duplicate decisions, stale loads, request replacement, and completion after disposal. Cover compact/expanded layouts, long content, large text, semantics, and safe-area changes. Add regression tests for reproduced defects where practical.

Follow `.ai/workflows/review-loop.md` and `.ai/workflows/quality-gate.md` for review and reruns.
