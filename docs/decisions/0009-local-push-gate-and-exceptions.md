# ADR 0009: Local Push Gate and Audited Test Exceptions

Status: Accepted

Date: 2026-09-17

## Context

Documented checks and CI do not stop an unchecked local push. Occasionally the owner may explicitly permit a push without local Flutter tests, but the reason, approval, and actual omission must remain visible.

## Decision

- Keep a versioned pre-push hook with opt-in, worktree-local installation. Verify a clean checkout corresponding to the single branch commit being pushed.
- Select checks from the complete pushed diff: explicit source-to-consumer-test mappings, direct changed tests, no Flutter commands for documentation-only changes, and hook tests for tooling changes. Fall back to the full Flutter suite for shared/unknown inputs or missing comparison history. Keep the full suite in CI.
- For Flutter changes, resolve dependencies with the lockfile enforced, generate localizations, format-check changed Dart files, analyze, and run selected tests. Reject direct integration/promotion branch updates.
- Support only a single-attempt Flutter-test exception tied to exact source and destination, with separate request and owner-approval records. Consume it before checks; failed attempts also consume approval.
- Keep a local JSONL journal and command logs in Git metadata. Export relevant sanitized evidence with an authorized PR; never report omitted tests as passing.
- Use a small Python standard-library CLI for structured JSON, subprocess exit
  statuses, and filesystem locking. A shell entry point integrates with Git. This
  adds a development-only Python 3.9-or-newer prerequisite, no Flutter/runtime or
  package-manager dependency. The supported development hosts are macOS/Linux;
  Windows support is not claimed.

## Consequences

Hooks are not distributed as active settings by a clone; each worktree needs installation. Strict clean-tree checks avoid claiming that uncommitted code proves a pushed commit. A local journal is neither tamper-proof nor authenticated approval, and pre-push cannot observe the later transfer outcome. The owner can bypass Git hooks, so server protection remains a separate configuration task. CI never accepts local test exceptions; merge authorization remains explicit.

Regression tests use temporary repositories and a fake FVM executable, including actual pushes to a temporary local bare repository. They prove hook behaviour, not Flutter correctness; the real Flutter suite remains separate. See the [operating workflow](../../.ai/workflows/push-gate.md).

The impact map is deliberately small and reviewable, not an inferred dependency graph. Its entries must include indirect consumers and grow with the application. Conservative full-suite fallbacks prevent silently omitting tests when the map cannot establish scope; they may be narrowed later with evidence.

## References

- [Git pre-push contract](https://git-scm.com/docs/githooks#_pre_push)
- [Git worktree configuration](https://git-scm.com/docs/git-worktree#_configuration_file)
