# ADR 0004: PR-based delivery and quality evidence

- Status: Accepted
- Date: 2026-09-16
- Updated: 2026-09-17 (explicit owner authorization for agent merges)

## Context and alternatives

The owner wants reviewable increments and an explainable history: implementation PRs enter `dev`, followed by promotions to `main`. Direct-to-main development is simpler but lacks this integration and release checkpoint.

## Decision

Bootstrap `dev` from the foundation. Feature/fix/docs PRs target `dev`; only this repository's `dev` may source a promotion into `main`. Preserve ancestry with merge commits for promotions; feature PRs may be squashed.

Apply: scope -> implement -> local checks and review -> authorized PR and CI -> verify findings -> fix and retest -> documented acceptance -> explicitly authorized merge. Preserve review history with replies linking fixes and evidence. Retain code comments explaining important constraints; remove stale or commented-out code.

Agents must not merge or enable auto-merge without the owner's explicit authorization for that specific merge. Review acceptance, green CI, or permission to publish is not merge authorization. A promotion merge requires separate authorization from an implementation merge.

## Consequences

- PRs carry criteria, architectural reasoning, tested commits, commands/results, and relevant UI/native evidence.
- Current-head CI is mandatory. Native and integration evidence belongs to promotions once executable flows exist.
- Self-review does not substitute for owner or delegated review acceptance.
- CI defines direction checks and downloadable logs. Branch protection and bots require separate configuration; this ADR does not claim they are active.
- Release automation is introduced incrementally with evidence.

## Verification

Inspect PR base/source, CI artifacts, thread dispositions, and acceptance evidence. Follow `.ai/workflows/review-loop.md`.
