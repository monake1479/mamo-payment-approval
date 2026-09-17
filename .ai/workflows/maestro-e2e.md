# Maestro Mobile E2E Workflow

## Rule and scope

Use Maestro for native application journeys. Read this workflow when changing a screen, navigation, an approval interaction, a flow, or the E2E runner. Flutter unit/widget tests still own detailed business rules, semantics assertions, and controlled async races.

The repository has launch/resume, configuration-failure, payment list/details,
approval-rejection, native-approval preparation/verification, and draggable-action
flows under `maestro/`. The approval pair brackets a real operating-system event;
native authentication evidence and Maestro CI remain separate as described in
`docs/implementation-plan.md`.

## Before authoring or running

1. Identify affected acceptance criteria, states, routes, and platforms. Resolve product decisions before writing assertions that encode them.
2. Inspect current UI and its exposed semantics. Add stable `Semantics.identifier` values for flow controls and assertions; keep accessible labels readable and identifiers free of payment/authentication data. Flutter keys alone are not exposed to Maestro.
3. Select a dedicated Android emulator or iOS simulator explicitly. Record device ID/model, OS, orientation, logical dimensions, text scale, locale, and reporting time assumptions. Never reset another app or a user's personal device to prepare a test.
4. Build and install this worktree's app for the selected target using `fvm flutter`, an explicit `--flavor <name> -t lib/main_<name>.dart`, and the SDK pinned in `.fvmrc`. Select the matching platform-specific app ID from [ADR 0007](../../docs/decisions/0007-native-flavors.md). Record source revision plus local changes and the installed binary's checksum/flavor/build mode. An iOS simulator `.app` is not an unsigned device build or a distribution artifact.
5. Establish a deterministic initial dataset, clock, and app-session reset. Each journey must run independently; share setup only when it has a real second consumer. Document how the actual seed/reset mechanism works when implemented.

## Flow contract

- Add English YAML flows under `maestro/` with the first runnable slice, and map each journey to acceptance criteria in the testing strategy. Do not add empty folders or flows for nonexistent UI.
- Assert outcomes, not just successful taps: status/order, overlay closure, originating route, and affected views as appropriate.
- Inspect selectors on both platforms. Avoid coordinate taps when a semantic target exists; dragging may use documented coordinates tied to the tested layout.
- Wait for observable conditions with bounded timeouts. Do not hide failures with optional assertions, arbitrary sleeps, or repeat-until-green retries. Preserve failed attempts and explain environment-related reruns.
- Exercise changed states and materially different compact/expanded layouts, including rotation and large text when relevant. Keep exhaustive arithmetic and async combinations in lower-level tests rather than multiplying E2E flows.
- Keep native authentication in the full journey. Do not add a production flag, deep link, or automation-detection branch that silently authenticates. Fakes belong to unit/widget tests; any future isolated E2E fake build requires an explicit decision and cannot replace native evidence.
- Verify successful, cancelled, failed/unavailable authentication and lifecycle behaviour separately on native targets. If a system interaction cannot be automated reliably, record the missing automation and perform a labelled manual check; never present it as a passing Maestro flow.

## Execute and retain evidence

From the repository root, inspect `maestro --version` and `maestro test --help`. Pin the project CLI version only after proving the first flows on both platforms; never upgrade the user's global installation implicitly.

Set `E2E_DEVICE_ID` to the chosen target, `E2E_APP_ID` to this project's installed package/bundle ID, `E2E_FLOW` to an existing flow (for example `maestro/foundation.yaml`), and `E2E_EVIDENCE_DIR` to a fresh directory under ignored `build/maestro/`. Flows receive `APP_ID` from the CLI. Do not overwrite a previous run's evidence. Do not run the configuration-failure flow against a correctly paired build; follow the testing strategy's deliberate mismatch build first.

```sh
mkdir -p "${E2E_EVIDENCE_DIR:?Set a fresh build/maestro run directory}"
maestro test \
  --device "${E2E_DEVICE_ID:?Select the test device}" \
  -e APP_ID="${E2E_APP_ID:?Select this project app}" \
  --format junit \
  --output "$E2E_EVIDENCE_DIR/report.xml" \
  --test-output-dir "$E2E_EVIDENCE_DIR" \
  --debug-output "$E2E_EVIDENCE_DIR" \
  "${E2E_FLOW:?Select an existing flow}"
```

Preserve the exit status, JUnit result, logs, and explicit screenshots/recordings of important checkpoints. Passing runs do not necessarily include screenshots unless the flow requests them. Inspect artifacts before sharing: use synthetic payment fixtures only, and never capture credentials, passcodes, or sensitive native authentication payloads.

Attach criterion-to-flow results and environment/build provenance to the PR. While changes are uncommitted, record the base SHA plus a checksummed source/flow snapshot including untracked inputs; a base SHA alone cannot identify the tested tree. Rebuild and rerun after relevant app changes. Local evidence must be published to an agreed reviewer-accessible location before claiming the PR evidence is complete; do not commit generated artifacts.

## Gate and current limits

- Run affected Maestro journeys before completing or pushing a behavioural slice. Add missing coverage for touched behaviour; inspect impacts beyond the changed screen.
- Before promotion, run the implemented critical journeys on Android and iOS and include separate real-device authentication evidence where the authentication slice is included.
- Documentation-only work may mark device runs not applicable with a reason. Missing hardware or a failing selected flow is missing evidence, not a pass.
- Current GitHub CI runs Flutter checks only. Maestro CI and artifact upload are separate planned work; local Maestro evidence is required until that automation exists. Cloud execution is not assumed or authorized by this workflow.

## Anchors and external references

- `docs/decisions/0005-maestro-for-mobile-e2e.md`
- `docs/testing/strategy.md`
- `docs/implementation-plan.md`
- `.ai/workflows/quality-gate.md`
- [Maestro Flutter semantics](https://docs.maestro.dev/get-started/supported-platform/flutter)
- [Maestro reports and artifacts](https://docs.maestro.dev/maestro-flows/workspace-management/test-reports-and-artifacts)
- [Maestro iOS execution](https://docs.maestro.dev/get-started/supported-platform/ios)

The documentation currently describes iOS simulator execution, not physical iOS automation. Recheck support when selecting the runner; retain a separate manual device check.
