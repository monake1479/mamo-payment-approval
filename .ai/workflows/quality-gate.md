# Quality Gate

Use `.ai/skills/mamo-verify/SKILL.md` to select scope, execute checks, review findings, and produce a record using `docs/testing/evidence-template.md`. Tests and local gates do not require a commit; publication remains subject to the user's instruction.

Run `fvm use` once in a new checkout to install/link the SDK pinned in `.fvmrc`. Use that SDK for all local Flutter/Dart checks; do not rely on the global SDK. CI reads the same file through its setup action and uses the resulting SDK directly on PATH.

Run from the repository root before every commit:

```sh
fvm flutter pub get --enforce-lockfile
fvm flutter gen-l10n
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
python3 -B -m unittest discover -s tool/tests -p 'test_*.py'
```

Before publishing, also run `python3 tool/scan_secrets.py` with Gitleaks 8.30.1
available on PATH (or pass `--binary`). It scans publishable tracked/untracked files
and all locally available Git history, with no inline suppressions or secret output.
CI downloads a checksum-pinned scanner and scans full fetched history. Ignored
signing files are not publishable inputs; keep them ignored and never attach them
to evidence. A clean scan is not a guarantee that arbitrary sensitive data is absent.
See [dependency and configuration hygiene](../../docs/architecture/configuration-hygiene.md).

Before promotion to `main`, verify native compilation and the implemented critical journeys:

```sh
fvm flutter build apk --flavor prod -t lib/main_prod.dart --release
fvm flutter build ios --flavor prod -t lib/main_prod.dart --release --no-codesign
```

## Test selection

Native flavor/configuration changes also require the per-flavor build and identity checks in [ADR 0007](../../docs/decisions/0007-native-flavors.md). Always record flavor as well as build mode; an omitted flavor selects `dev`, including in release mode.

- Unit tests: domain rules, totals, ordering, decisions, authentication coordination, and state transitions.
- Widget tests: responsive rendering, masking/reveal behaviour, overlay interactions, navigation, and loading/error states.
- Maestro E2E: incoming request to approval/rejection, route behaviour, and cross-screen consistency. Follow `.ai/workflows/maestro-e2e.md` for native setup, selectors, execution, and evidence.
- Development tooling: isolated Git/CLI regression tests under `tool/tests/`; no remote network or real Flutter invocation in the hook fixtures.

The local pre-push guard is a smaller, change-based check, not a repetition of every verification step: follow [push-gate.md](push-gate.md) for installation, explicit test-impact mapping, fallbacks, and audited one-attempt test exceptions. Full Flutter and tooling suites remain mandatory in CI. A selected local run does not claim the full suite passed.

Run affected Maestro flows before completing or pushing a behavioural slice, and the implemented critical journeys on both Android and iOS before promotion. `fvm flutter test` does not run Maestro. Current CI has no Maestro job; local E2E evidence remains required as flows arrive with their slices.

Tests must assert observable behaviour, not implementation details. Every production defect fixed during the challenge should first receive a focused regression test when practical.

For documentation-only changes, check links, routing, decision status, and consistency with code; do not invent behavioural tests. A process-only promotion may mark native builds and device journeys not applicable with rationale. CI quality is still required.

iOS compilation needs macOS/Xcode. An unsigned iOS build is not an installable artifact. Fake-auth tests do not prove real device authentication; native verification must cover both platforms before delivery.

## Evidence and reruns

- Record tested commit, commands, results, and CI run/artifact links in the PR.
- For uncommitted work, also identify the tested local source/flow snapshot, including untracked inputs. A base commit alone is not evidence for local edits; do not create a commit merely to run a gate.
- UI evidence names device/OS, dimensions/orientation, text scale, scenario, result, and screenshot or recording.
- CI preserves quality logs even on failure. Keep sensitive data out of evidence.
- After fixes, run the focused regression and required local gate. Every push needs green CI for its current head.
- Reuse older manual evidence only with an explanation of why changed paths cannot affect it.
- Never weaken analysis, hide failed/skipped tests, or re-record goldens merely to make checks pass. Only explicit owner approval under [push-gate.md](push-gate.md) permits omitting selected local Flutter tests for one push attempt; it does not complete the quality gate or waive CI.

Do not declare work complete based only on generated code, a successful build, or a visual check. Report exactly which commands were run and any checks that remain.

## Anchors

- `.github/workflows/ci.yml`
- `.github/pull_request_template.md`
- `docs/testing/strategy.md`
- `.ai/workflows/review-loop.md`
- `docs/decisions/0006-fvm-managed-flutter.md`
