---
name: mamo-flutter-ui
description: Specify, implement, or verify Flutter screens, widgets, themes, and overlays in this project. Use for visible UI changes or responsive/accessibility checks; not for pure domain logic or invisible routing scaffolds.
---

# Mamo Flutter UI

## Inputs and modes

Read the [router](../../INDEX.md), [UI rules](../../principles/flutter-ui.md), affected [requirements](../../../docs/product/requirements.md), current widgets/theme/tests, and any approved screen spec. Read [state rules](../../architecture/state-and-side-effects.md) for controller interactions and [privacy rules](../../architecture/authentication-and-sensitive-data.md) for sensitive data or authentication.

Use only the mode authorized by the task: **specify**, **implement**, or **verify**. Verification is read-only unless fixes were also requested. A request for a visual change does not authorize new product behaviour or dependencies.

## Specify before implementation

Prepare a concise screen contract when introducing a screen or materially changing its composition. In plan-only/read-only mode, return it in the response or an explicitly authorized report. Persist it under `docs/product/` only when implementation or documentation edits are authorized; for a small change, amend the existing contract. No separate spec is required for an invisible route placeholder. Consulting verification steps to plan tests does not authorize executing them.

Include the following where affected; mark irrelevant dimensions with a reason:

- criteria and route entry/exit, including origin-preserving back navigation and overlay placement;
- state-to-content/action mapping: loading, empty, data, error/retry, and intermediate states such as submitting or refreshing;
- composition and app-owned colour/spacing/type tokens, with reuse versus new-token rationale;
- compact/expanded layout behaviour, breakpoint source, orientation/safe areas, long content, large text, and scroll behaviour;
- controller inputs and outcomes, who owns/disposes it, and which widget listeners perform navigation;
- readable English copy, semantic labels and identifiers, non-colour status cues, focus, touch targets, and any reduced-motion behaviour;
- deterministic examples, widget assertions, Maestro checkpoints, and required rendered evidence.

Get owner agreement for a new visual direction or unresolved behaviour. Implement routine details within an approved contract without repeated approval requests. A mockup cannot silently override security or accepted product decisions.

## Implement against the contract

1. Reuse the [app theme](../../../lib/app/theme/app_theme.dart) and existing meaningful widget classes. Add feature-local components before extracting cross-feature infrastructure.
2. Keep repositories/authentication out of widgets. Access providers through context in UI; never pass context into controllers. Add subscriptions at the smallest useful boundary rather than applying selectors or caching mechanically.
3. Implement every affected state and interaction, then tests. Test explicit failures and repeated actions rather than showing a success-only preview.
4. Add stable, non-sensitive semantics identifiers for Maestro; widget keys alone are insufficient. Inspect the resulting native tree, including masking. Preserve readable accessible labels rather than speaking test IDs.
5. Preserve required cross-screen controls and security behaviour from the affected feature contract. Test-only controls must not alter the behaviour of reviewer builds.

## Verify rendered behaviour

Use [mamo-verify](../mamo-verify/SKILL.md) and the [Maestro workflow](../../workflows/maestro-e2e.md). Compare the running app against the agreed contract on materially different compact/expanded layouts, relevant orientation/safe-area changes, and large text. A screenshot proves appearance at that checkpoint, not navigation, state transitions, or accessibility behaviour.

Report each material gap with file/location, expected versus observed behaviour, reproduction, and proposed fix. Retest corrected states on the same configurations. If app launch, a device, or an interaction tool is unavailable, identify the unverified dimension; code inspection does not replace rendered evidence.

Use the [evidence template](../../../docs/testing/evidence-template.md) for results. New screenshots use deterministic synthetic data only. Do not overwrite valid baseline evidence to disguise a regression.

## Delegated work

When delegation is authorized, one spec owner supplies the complete contract to implementers. Missing product decisions return to that owner. Independent verification uses the contract and current code, not the implementer's conclusions. A solo agent may perform the same stages but must label its review as self-review.
