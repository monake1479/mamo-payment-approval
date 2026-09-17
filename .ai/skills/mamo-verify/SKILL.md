---
name: mamo-verify
description: Select and run verification for a project change, review its quality, and produce evidence before handoff or an authorized commit/push. Use for tests, regression checks, or quality gates, including documentation-only changes; does not grant permission to fix or publish.
---

# Mamo Verification

## Select the scope

Read the [router](../../INDEX.md), [quality gate](../../workflows/quality-gate.md), [testing strategy](../../../docs/testing/strategy.md), and affected requirements. Use the [evidence template](../../../docs/testing/evidence-template.md).

Establish whether the task permits fixes or only inspection/checks. Inspect `git status --short`, staged/unstaged changes, untracked source/test files, and any committed branch changes in scope. Use the agreed base for local work and the actual PR base for PR work; a PR is not required. Do not assume `HEAD` contains the assignment or that `origin/dev` is fresh. Fetch only when network operations are in scope; otherwise report base freshness as unverified.

Retain a changed-path inventory, expanding untracked directories to individual files. Reconcile every authored/local changed path with the input manifest or an explicit exclusion reason, including deletions and renames. An unclassified path keeps the affected verification incomplete; a checksum of an incomplete list is not full input provenance. Attach both the manifest and coverage inventory to the local record.

Map changed contracts to consumers and failure risks. Select tests at the lowest layer that proves each criterion, then add native journeys for cross-screen/platform behaviour. Run the full Flutter gate.

## Execute

From the repository root run the required FVM commands in [quality-gate.md](../../workflows/quality-gate.md). Record exact commands, exit statuses, and tested inputs. Run focused tests with an existing path, for example `fvm flutter test test/app/app_test.dart`; do not use a placeholder test path as evidence.

- **Logic/state:** exercise meaningful boundaries, explicit failures, controlled time/futures, duplicate actions, and stale completion/disposal where affected.
- **UI:** follow [mamo-flutter-ui verification](../mamo-flutter-ui/SKILL.md), including semantics and materially different layouts.
- **Native journeys:** follow [maestro-e2e.md](../../workflows/maestro-e2e.md). `fvm flutter test` is not a Maestro run; a platform fake is not native evidence.
- **Documentation/skills only:** inspect routing, local links, status/decision consistency, and contradictory instructions. Check skill frontmatter and realistic task routing. Do not invent UI tests or claim an independent behavioural evaluation from a syntax validator.
- **Delivery:** load [delivery-checklist.md](../../workflows/delivery-checklist.md). Compilation, simulated authentication, real-device verification, and installable distribution are different claims.

If a selected check fails, retain its output and distinguish a product defect from a tool/environment failure. Reproduce inherited failures against a safe baseline before labelling them pre-existing. Do not reset the worktree, weaken checks, or retry until green without a diagnosed reason. Report blocked/unrun separately from passed/not-applicable.

## Inspect quality

Review the actual diff for dead/debug/commented-out code, unnecessary layers, ownership/disposal, explicit error paths, docs drift, and consistency with the closest applicable local implementation. Check for secrets, sensitive logs, and machine-specific configuration. Preserve comments that explain a non-obvious safeguard or trade-off.

For authentication, sensitive-data disclosure, or related lifecycle changes, read the triggered security rules and perform a focused check even if all changed files are frontend code. Verify the affected access, visibility, cancellation, stale-result, and logging contracts. Test doubles must not enter reviewer composition. Open policy choices go through the decision gate rather than being invented by the reviewer.

If repairs are authorized, fix valid findings and add focused regression tests where practical. Re-run the affected checks and required gate on the updated inputs. Otherwise return findings without edits.

## Close the local gate

Record `passed`, `failed`, `blocked`, or `not applicable` per check, with rationale and source/build/artifact provenance. Evidence for local edits needs a base revision plus identified changed/untracked inputs. Never stage or commit merely to obtain an evidence SHA.

A green local gate does not imply green current-head CI or independent approval. Publication and merging still follow [review-loop.md](../../workflows/review-loop.md) and the user's authorization. Respect an instruction to keep changes local.
