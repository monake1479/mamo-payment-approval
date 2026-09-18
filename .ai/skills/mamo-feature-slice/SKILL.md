---
name: mamo-feature-slice
description: Plan, implement, or integrate a runnable feature increment or behavioural fix in this project. Use for new features, reproduced defects, vertical-slice planning, or integration reconciliation; not for documentation-only edits or review-only tasks.
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

- Build the smallest shared-data/use-case/state/UI path that makes the increment usable. Group reusable models, DTOs, domain-specific converters, data sources, repositories, and application use cases by domain under `lib/common/data/<domain>/`; put general converters under `lib/common/converters/`, cross-layer typed failures under `lib/common/error_handling/`, and cross-domain result primitives under `lib/common/result/`. Keep transport/SDK exception translation beside its owning data boundary. Keep feature-specific state owners and widgets directly under `lib/features/<feature>/` without a redundant `presentation/` level. Put each state concern in its own `states/<state-name>/` directory, name that folder without `_cubit` or `_bloc`, and keep its controller, state, and event declarations in separate technology-specific files. Model immutable data classes and sealed unions with Freezed, keep one authored model per file, validate stored/transported data in DTOs, and use typed `JsonConverter` classes instead of parallel codecs. Shared data sources, repositories, and use cases use the generated lazy-singleton DI contract from ADR 0011.
- For a demo without a real service, place the deterministic implementation under `lib/mock_backend/<domain>/` behind a narrow backend-client contract. It returns raw transport-shaped values and backend exceptions, while the normal remote data source owns DTO mapping and typed application failures. Register the mock in composition; repositories, use cases, Cubits, and UI must not know whether the backend is mocked.
- Add focused tests as behaviour appears. Unit/widget tests own deterministic failures and async races; Maestro flows accompany executable journeys using the [Maestro workflow](../../workflows/maestro-e2e.md).
- Keep docs consistent with the implementation. Update requirements only for an owner-agreed behaviour change, not to accommodate accidental implementation differences.
- Use [mamo-verify](../mamo-verify/SKILL.md) to check the complete local change, including untracked sources, and retain results. When a fix changes a previously tested input, rerun the affected check and required gate.

## Handoff

Report implemented criteria, decisions, tests actually run, remaining gaps, and changed files. Keep a failed or unavailable selected check visible. Do not call a slice complete while its acceptance criteria or required evidence remain unverified.

If a teammate is authorized, give them the same concrete scope, the full spec path, file ownership, open decisions, and read-only/edit permissions. This skill does not require or authorize delegation by itself.

## Current code anchors

- [App composition](../../../lib/app/app.dart)
- [Payment flow composition](../../../lib/app/payment_flow_layer.dart)
- [Home page](../../../lib/features/payments/pages/home_page.dart)
- [Payment collection state](../../../lib/features/payments/states/payments/payments_cubit.dart)
- [App composition tests](../../../test/app/app_test.dart)
- [Approval-flow tests](../../../test/app/approval_flow_test.dart)

Use the closest implemented feature and its tests; do not invent source paths.
