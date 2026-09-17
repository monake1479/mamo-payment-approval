---
name: mamo-feature-slice
description: Plan or implement a runnable feature increment or behavioural fix in this project. Use for new features, reproduced defects, or vertical-slice planning; not for documentation-only edits or review-only tasks.
---

# Mamo Feature Slice

## Establish the assignment

Read the repository [router](../../INDEX.md), [requirements](../../../docs/product/requirements.md), [implementation plan](../../../docs/implementation-plan.md), and triggered rules. Inspect the actual code and tests before proposing types. Paths in this skill are relative to this file; commands run from the repository root.

Choose the mode from the user's request:

- **Plan/diagnose:** inspect and explain; do not implement, edit repository documents, or mutate GitHub unless the user separately requested those writes. Return a proposed plan in the response or an explicitly authorized report.
- **Implement/fix:** complete the authorized behaviour and verification. This mode does not itself authorize a commit, push, PR, or merge.

Inspect `git status --short` before editing and preserve existing work. Do not switch branches or clean the worktree merely to start a slice. Respect the owner's instruction to batch local changes until the agreed checkpoint.

## Plan one runnable increment

1. Name the affected acceptance criteria, current behaviour, desired result, exclusions, and failure paths. For a defect, reproduce it and add a focused failing test first when practical; document why if that is not possible.
2. Read the [decision gate](../../workflows/decision-gate.md) and affected ADRs. Ask about unresolved behaviour before encoding it, including in fixtures or assertions. Preserve accepted decisions and leave deferred choices open.
3. Identify the state owner and operation path, including where success/error becomes a UI effect. Explain each new dependency or abstraction through a concrete boundary or test, not a standard folder checklist.
4. For changed UI, use [mamo-flutter-ui](../mamo-flutter-ui/SKILL.md) to prepare or amend the screen contract before implementation. In plan-only mode, propose the contract without writing it. A narrow fix may amend an existing contract rather than create a new document.
5. When implementation or documentation edits are authorized, record the slice's scope, decisions, and criterion-to-test plan in `docs/implementation-plan.md`; link a feature note only when the detail merits one. Otherwise include them in the response. Unaccepted choices stay labelled open. Selecting future tests does not start implementation or test-execution stages.

## Implement and verify

- Build the smallest domain/data/state/UI path that makes the increment usable. Add only types needed by that path; the current foundation is not a precedent requiring pass-through layers or code generation.
- Add focused tests as behaviour appears. Unit/widget tests own deterministic failures and async races; Maestro flows accompany executable journeys using the [Maestro workflow](../../workflows/maestro-e2e.md).
- Keep docs consistent with the implementation. Update requirements only for an owner-agreed behaviour change, not to accommodate accidental implementation differences.
- Use [mamo-verify](../mamo-verify/SKILL.md) to check the complete local change, including untracked sources, and retain results. When a fix changes a previously tested input, rerun the affected check and required gate.

## Handoff

Report implemented criteria, decisions, tests actually run, remaining gaps, and changed files. Keep a failed or unavailable selected check visible. Do not call a slice complete while its acceptance criteria or required evidence remain unverified.

If a teammate is authorized, give them the same concrete scope, the full spec path, file ownership, open decisions, and read-only/edit permissions. This skill does not require or authorize delegation by itself.

## Current code anchors

- [App composition](../../../lib/app/app.dart)
- [Foundation page](../../../lib/features/payments/presentation/pages/foundation_page.dart)
- [Foundation test](../../../test/app/app_test.dart)

These are the current starting points. Use the closest implemented feature and its tests when available; do not invent source paths.
