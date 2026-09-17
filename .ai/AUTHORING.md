# Authoring Agent Rules

## Rule

Keep each rule short, triggerable, and grounded in this repository. Update its `INDEX.md` route in the same change.

## Why

Duplicated requirements drift. Rules describe how contributors preserve contracts; requirements and ADRs own what was decided and why.

## How to apply

- Extend an existing file when it already owns the concern.
- State the requirement, the failure it prevents, how to apply it, and real repository anchors. Add forbidden examples when they resolve ambiguity.
- Link accepted ADRs rather than duplicating them. Clearly label planned implementation and link existing plans instead of inventing source anchors.
- Write concise English instructions grounded in the project's requirements and implementation.
- Do not require metadata with no consumer: severity tiers and reviewer IDs are unnecessary here. Rule files need no frontmatter; project `SKILL.md` files use required `name` and `description` fields for skill compatibility and routing.
- Let linters enforce mechanical style; avoid duplicating the language guide.
- Update renamed links and routing atomically. Do not add empty architecture directories.

## Project skills

- Keep canonical skills under `.ai/skills/<name>/SKILL.md`, with lowercase hyphenated names and a precise task trigger in the description. Update the skill router in `.ai/INDEX.md` in the same change.
- Link the existing rules rather than copying their bodies. Describe inputs, relevant execution modes, ordered work where necessary, evidence, and stopping/permission boundaries.
- Keep planning/review-only requests read-only. A skill cannot authorize delegation, a commit, a push, a remote comment, or a merge that the user has not authorized.
- Add reusable scripts/templates only for real repeated work. Validate scripts by execution; validate skill frontmatter and local references. Do not treat syntax validation as independent behavioural testing.
- Exercise realistic requests and check the resulting decisions. Distinguish author walkthroughs from independent evaluations. If a skill is behaviourally tested by an agent, keep the request, allowed actions, observed result, and tested-input identity.
- Use verified code/tests as examples when they exist. Do not invent representative code for unfinished features.

## Forbidden

- Suppressing findings, deleting review history, or claiming unrun checks passed.
- Treating an unaccepted proposal as a product requirement.

## Anchors

- `AGENTS.md`
- `.ai/INDEX.md`
- `docs/decisions/0001-feature-first-clean-architecture.md`
