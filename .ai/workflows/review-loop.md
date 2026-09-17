# Branches, Review, and Evidence

## Rule

Deliver small increments through PRs into `dev`, then promote verified increments through a separate PR from `dev` into `main`.

## Branch flow

Agents must not merge or enable auto-merge without the owner's explicit authorization for that specific merge. Passing checks, review acceptance (including delegated review), and permission to commit, push, or create a PR do not grant that authorization.

- Bootstrap `dev` once from the existing `main` foundation; this creates a reference without a code change.
- Start subsequent feature/fix/docs branches from current `origin/dev` and target `dev`. Open a PR only when the owner authorizes publication of the local work.
- No direct implementation pushes to `dev` or `main`, and no feature PR directly into `main`.
- Keep `main` as the stable default branch. Promotions must originate from this repository's `dev`.
- Squash feature PRs when useful. Merge promotions with a merge commit to preserve `dev` ancestry; do not squash promotions and repeatedly replay changes.
- Use English titles, commits, explanations, and evidence. Never commit signing material or build output.

## Quality loop

Use the project skills through `.ai/INDEX.md`: feature scoping -> UI work when applicable -> verification -> local review -> PR review when publication is authorized. These are task procedures, not automatic permission to move into the next phase. Keep changes local when the owner requests batching; commit and publish only at the agreed checkpoint.

Local review covers staged, unstaged, untracked, and relevant committed branch changes against an identified base. It needs no PR, remote access, or commit. Report findings and evidence in the response unless a report file was requested. Review alone does not authorize fixes. Use `mamo-review-round` for either local or PR mode.

1. Identify acceptance criteria, decisions, risks, and selected tests.
2. Implement one runnable slice with tests and truthful documentation.
3. Run the local quality gate. Review the diff for correctness, complexity, scope, lifecycle, privacy, dead code, and unexplained dependencies. Auth/payment disclosure changes require a focused security pass.
4. When publication is authorized, push and open a PR with evidence. CI uploads logs for the tested commit. Wait for the current head's checks and configured reviewers.
5. Verify each finding in current code. Fix valid findings with regression tests where practical; explain invalid or inapplicable findings with code/test evidence.
6. Push fixes, rerun affected checks, and update evidence. Reply in the original thread with the fix commit and verification. Resolve only after the fix is verified or the reviewer/owner accepts the explanation.
7. Report merge readiness when current CI is green, blocking findings are addressed, evidence is complete, and the owner or an explicitly delegated reviewer has accepted the change. Self-review is not independent approval. Stop before merging unless the owner explicitly authorizes that specific merge.
8. Promote through a separate `dev` to `main` PR linking included feature PRs and release evidence. Merging the promotion needs its own explicit owner authorization.

## Comment handling

- Never delete review comments to obtain a clean PR; resolved threads are the audit trail.
- Verify outdated threads rather than assuming the finding disappeared.
- Record accepted nonblocking follow-ups with scope and rationale. Do not move a blocker to the backlog to merge faster.
- In source, remove stale comments, commented-out code, and narration; retain explanations of non-obvious decisions and safeguards.

## Enforcement limits

CI checks PR direction and quality. It cannot enforce manual evidence or stop direct pushes by itself. GitHub branch protection/rulesets and reviewer integrations require separate configuration; never claim they exist without inspection. No named bot is mandatory until installed and adopted by the owner.

Install the [local pre-push guard](push-gate.md) in each worktree. It selects tests from the pushed diff and records any explicitly approved single-attempt Flutter-test exception. Include the sanitized request/approval/use record in authorized PR evidence; omitted tests remain unverified. Local hooks are bypassable and do not replace full-suite CI or server protection.

Server-enforced merge restrictions are not configured. Verify their availability and obtain owner authorization before changing repository settings; keep the repository private.

## Anchors

- `docs/decisions/0004-pr-based-delivery-and-quality-evidence.md`
- `.github/workflows/ci.yml`
- `.github/pull_request_template.md`
- `.ai/workflows/quality-gate.md`
