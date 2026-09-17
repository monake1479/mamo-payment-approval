---
name: mamo-review-round
description: Review local project changes or inspect PR feedback, and repair verified findings when requested. Use for pre-commit review, branch review, or a PR review round; reviewing alone never authorizes fixes, publication, or merging.
---

# Mamo Review Round

Read the [router](../../INDEX.md), [review loop](../../workflows/review-loop.md), selected diff, affected requirements, and triggered rules. A skill invocation does not broaden the user's permission.

## Establish mode and provenance

- **Inspect locally:** review the selected local changes and report findings. No PR or GitHub access is required.
- **Inspect PR feedback:** collect and assess feedback for an existing PR without posting or editing.
- **Repair locally:** edit verified in-scope findings and run checks, without posting or publishing.
- **Publish an authorized round:** include only the explicitly requested GitHub actions. Permission to create/update a PR does not authorize merging it.

Choose local review unless the user requests PR work. A review request permits relevant non-mutating diagnostics, not implementation edits. Preserve local work and report exactly which inputs were reviewed.

## Local review

1. Read `git status --short`, staged and unstaged diffs, and untracked files in scope. For branch review, inspect committed changes against the agreed base as well. Do not stage, reset, commit, or fetch merely to establish review inputs.
2. Record the base revision, HEAD, changed-path inventory, and local input identity using the [evidence template](../../../docs/testing/evidence-template.md). If using a cached remote-tracking base without fetching, report its freshness as unverified.
3. Review affected behaviour and adjacent consumers for correctness, explicit failures, state ownership, lifecycle, security, test coverage, unnecessary complexity, and documentation drift. Use [mamo-verify](../mamo-verify/SKILL.md) for relevant checks; report checks not run.
4. Give each actionable finding a stable local ID, severity, file/line, evidence or reproduction, impact, and recommended fix. Distinguish confirmed defects, questions, and optional improvements. Return the report in the response unless writing a report file was requested.
5. Before finishing, recheck the local inputs. Changed inputs invalidate affected conclusions. If there are no findings, say what was inspected and which risks remain unverified.

Local review does not create a PR or require remote feedback. A passing local gate is not independent approval or current-head CI.

## PR feedback review

Resolve the PR from the named number or current branch only for PR mode. Read the repository identity, base/head branches, source SHA, checks, and review state before acting. If local changes differ from the reviewed source, label that difference rather than claiming the current PR contains a local fix.

Collect inline review threads (including replies and resolution state), review bodies, and issue comments with pagination. Read complete bodies, not only previews or a recent-time window; older unresolved findings still matter. An API error, truncation, rate limit, or pending review is not a clean verdict.

Retain a review-input inventory: repository/PR identity, collection time, head SHA, channel item counts, pagination completion, and any errors. Identify feedback by stable URL or ID, author, original/reviewed SHA where available, path/line, replies, and resolved/outdated state. Record unavailable fields rather than inventing them. Account for each item as a finding, linked duplicate, or informational input; grouped findings retain every source ID so no thread disappears in the summary.

Only wait for reviewers actually configured/requested for this PR. Do not invoke a bot, install an integration, or impose additional reviewer requirements without authorization. An independent agent report is not a GitHub approval.

## Judge and repair

1. For each finding, inspect current code and applicable requirements/ADRs. Record the issue, evidence, risk, and whether it is valid, already fixed, disputed, or awaiting an owner decision.
2. Reproduce meaningful defects where practical. When repair is authorized, fix the cause and inspect directly related occurrences within scope. Do not expand into unrelated cleanup or replace existing user work.
3. Use [mamo-verify](../mamo-verify/SKILL.md) for the updated inputs. Document a proposed improvement separately from a blocking correctness or agreed-contract issue.
4. For local findings, retain their IDs and report fixes and retest results. In PR mode, reply in the original thread only if posting is authorized, with the published fix SHA and verification or an evidence-backed explanation. Otherwise return a draft response.
5. Preserve PR comments. Resolve a finding only after the fix is verified or the reviewer/owner accepts the explanation, as defined in the review loop. Outdated is not resolved; a follow-up cannot silently replace a blocker.

## Finish the round

Report remaining blockers, disputed points, checks, and unpublished fixes for the identified inputs. Link dispositions to local finding IDs or PR feedback IDs, depending on mode. In PR mode, re-read the PR head and check for new/changed feedback before a current-state conclusion. An offline export supports only an as-of conclusion, with current remote status unverified. One round ends after findings have a disposition and scope completeness is established; continuous monitoring requires a separate request.

If publishing is authorized, complete the local gate before committing/pushing, then verify the new head's CI and requested reviews. During local batching, stop before commit/push. Never merge or enable auto-merge without the owner's explicit authorization for that specific merge, even after passing checks and accepted review.
