# Verification Record Template

Use this structure for a slice, local review round, or PR evidence. Scale the detail to the change; mark irrelevant sections with a reason. Store generated logs/screenshots under ignored `build/` or outside the repository, not next to this template. A concise authored summary may be kept in docs; publish artifacts only when authorized.

## Scope and provenance

- Task and affected acceptance criteria:
- Review mode and permitted actions:
- Review scope (local or PR), branch, selected base, base freshness, source HEAD; PR identity only when applicable:
- Local changed/untracked inputs and snapshot identifier/checksum (if dirty):
- App binary/build mode/checksum (native runs only):
- Flutter/Dart/FVM/Maestro versions actually used; compare the SDK with `.fvmrc`:
- Device/model, OS, logical size, orientation, text scale, locale, clock/seed setup:

Capture input identity before running checks and verify it again afterward. A reproducible local record can use a sorted manifest of relevant input paths and SHA-256 hashes, including untracked sources/tests/flows and configuration that affects the check. Do not include secrets, generated output, or unrelated files. The base SHA plus this manifest identifies local inputs without committing them. Keep the manifest with the run artifacts; relevant input changes invalidate the corresponding result.

Attach the manifest and reconcile it against the full authored diff and local changed/untracked-file inventory. Expand untracked directories; record deletions and renames explicitly, not only hashes of files that still exist. Every changed path must be included or have a reviewable exclusion reason. Check that inventory again after execution so newly added paths cannot escape verification. Unclassified paths leave the affected check incomplete.

| Changed/untracked path and change kind | Manifest entry or explicit exclusion reason | Affected checks |
|---|---|---|

## Criteria and results

| Criterion or risk | Test/flow/manual scenario | Exact command or procedure | Status | Evidence |
|---|---|---|---|---|

Use `passed`, `failed`, `blocked`, or `not applicable`. Explain missing checks and not-applicable entries. Distinguish manual observations from automated assertions, and simulated authentication from physical-device verification. Include command exit statuses and retained failure attempts. A test plan is not a test result.

## Review and reruns

For local review, identify the staged, unstaged, untracked, and committed changes included. Use stable local finding IDs with severity, file/line, impact, evidence, recommendation, and disposition. No PR or GitHub feedback inventory is required; mark remote-only checks not applicable.

For PR feedback, retain repository/PR identity, collection time and head SHA, channel counts (inline threads, reviews, issue comments), pagination completion and errors. Identify each item by stable URL/ID, author, original/reviewed SHA if available, location, replies and resolved/outdated state. Account for all collected items, including informational comments and duplicates; a grouped finding retains all source identities. An offline export supports only an as-of assessment.

| Finding/input URL or ID and location | Evidence and disposition | Fix or decision | Reverification |
|---|---|---|---|

Identify self-review versus independent review and the exact inputs each reviewer saw. Disputed findings remain visible; accepted follow-ups name their scope and rationale. Reusing an older result requires explaining why the changed inputs cannot affect it.

## Local push exceptions, if any

- Request ID, exact commit/branch/destination, reason, previous test result, risk, and follow-up:
- Explicit owner approval reference and approving person:
- Attempt ID, selected checks, consumed/not consumed, gate outcome, actual skipped checks, and logs:
- Transfer outcome confirmed separately (pre-push does not observe network success):
- Sanitized record attached when publication is authorized; otherwise local journal location:

Mark this section not applicable if no exception was requested or used. Selection-based `not_needed` is different from an approved skip. Neither means tests passed. Preserve failed attempts and do not treat local approval metadata as authenticated identity.

## Handoff

- Implemented and verified criteria:
- Open decisions, failures, and missing evidence:
- CI run/source head and artifact links, if published:
- Artifact access and retention limits:
- Owner/delegated acceptance, if obtained:
- Explicit owner authorization for a specific merge, if obtained (review acceptance alone is insufficient):
- Next authorized action; commits/pushes/merges performed or explicitly not performed:

Do not report the whole change as green when a required check is blocked. A local result is not current-head CI, an artifact path is not reviewer access, and an agent review is not owner approval.
