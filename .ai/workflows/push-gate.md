# Local Push Gate and Test Exceptions

## Installation and normal pushes

The versioned `.githooks/pre-push` runs `tool/push_gate.py`. After `fvm use` and dependency setup, install it separately in each checkout/worktree:

```sh
sh tool/install_hooks.sh
```

This requires Git with worktree configuration support, Python 3 on macOS/Linux (standard library only), and FVM on PATH. The installer enables `extensions.worktreeConfig` in the local repository and sets `core.hooksPath=.githooks` only for the current worktree. It refuses to replace a different hook configuration. Git can copy worktree configuration when creating a new worktree; the relative path still selects that checkout's own hooks. Run the installer there to verify setup. Existing other worktrees are not reconfigured. Cloning does not activate hooks automatically; never set this path globally.

Push one checked-out branch, at its committed HEAD, to a configured remote name. The working tree and index must be clean, including untracked source files; ignored build output is allowed. The hook does not stash, stage, commit, or restore work. It rejects tags, deletions, multi-ref pushes, direct URLs, and direct `dev`/`main` updates. Repository bootstrap is a separate owner-reviewed action, not a test exception.

## Change-based check selection

The hook compares the commit being pushed with the destination's current revision supplied by Git, not just `HEAD~1`. On a first branch push it uses the merge base with the locally known `origin/dev` (or that remote's `dev`). It never fetches automatically. Missing/unavailable comparison history falls back to the full suite and prints the reason.

`tool/test_scope.py` is the explicit impact map:

- Documentation-only changes run no Flutter commands.
- Tool/hook changes run the hook regression suite, without Flutter unless app inputs also changed.
- A mapped source change runs its listed consumer tests; changed `*_test.dart` files run directly. Update the map and its tests with each slice, including indirect consumers.
- Shared/configuration changes, deletions, missing mapped tests, or unknown dependencies use the full Flutter suite. Do not guess that a matching filename proves complete dependency coverage.
- The selected base, paths, tests, and rationale are printed/recorded. No selected tests is `not_needed`, not a test pass or bypass.

For Flutter-relevant changes the gate runs, in order:

1. `fvm flutter pub get --enforce-lockfile`
2. `fvm flutter gen-l10n`
3. `fvm dart format --output=none --set-exit-if-changed` on changed existing Dart files (all files only when no comparison base is available)
4. `fvm flutter analyze`
5. `python3 -B -m unittest discover -s tool/tests -p 'test_*.py'` when tooling changed or no comparison base exists
6. `fvm flutter test` with the selected test paths, or the full suite for a documented fallback

Any failed command or changed tracked/untracked input blocks the push. Generated ignored files may change. The hook verifies the current branch/HEAD/destination again afterward. Do not edit the checkout while checks run. It does not automatically run Maestro, native builds, or manual reviews; their affected-slice requirements remain in the quality gate.

Child check commands run without Git's repository-local environment variables, so SDK managers can inspect their own Git caches. The gate's own repository/destination checks retain the original hook context; this isolation does not skip any check.

## Request, approve, consume

A test exception skips **only the selected Flutter tests**, never other selected checks. It is tied to the exact commit, branch, configured remote and push-URL hash, and target branch. No generic `SKIP_TESTS` flag is supported. A push with no selected Flutter tests needs no exception.

1. Record a request with a reason, observed previous test result (or honestly `not run`), risk, and concrete follow-up. This is not approval:

   ```sh
   python3 tool/push_gate.py request \
     --remote origin --target refs/heads/feature/example \
     --requested-by 'Requester name' \
     --reason 'Explain why a local test exception is necessary' \
     --test-result 'State the observed result and evidence location' \
     --risk 'Describe what remains unverified' \
     --follow-up 'Name the corrective action and responsible person'
   ```

2. Obtain explicit owner approval for that request and push. Permission to implement the hook, work on a branch, or push normally is not permission to skip tests. Only after approval, record the returned request ID, approver, and approval reference:

   ```sh
   python3 tool/push_gate.py approve REQUEST_ID \
     --approved-by 'Owner name' \
     --approval-reference 'Reference the explicit approval for this request'
   ```

3. If publication itself is authorized, pass the ID to one push command, not a persistent shell export:

   ```sh
   MAMO_PUSH_EXCEPTION=REQUEST_ID git push origin HEAD:refs/heads/feature/example
   ```

The journal records request, approval, attempt, consumption, check results, and gate allowed/blocked events. Consumption happens before mandatory checks; a failed/interrupted check or network transfer does not leave reusable approval. A retry needs a new request and approval. Concurrent attempts are serialized. Changing the commit, branch, or destination invalidates the exception. Pending requests are never treated as approved.

## Evidence and limits

Locate the worktree-local audit directory with:

```sh
git rev-parse --git-path mamo-push-audit
```

It holds `events.jsonl` and per-attempt command logs in Git metadata, outside tracked files and `flutter clean` output. Preserve failed attempts. Do not add credentials, private URLs, payment/authentication data, or copied private conversation text to explanations/logs. Use a concise approval reference. Only a hash of the configured URL is recorded automatically; local logs still require inspection before sharing.

When publication is authorized, attach the relevant sanitized record to PR evidence: request ID, exact source/destination, reason, prior test result, risk/follow-up, approval reference, attempt ID, skipped check, and actual results. Until then keep it local. A pre-push hook knows its gate outcome, **not whether the subsequent network transfer succeeded**; record confirmed publication separately. Skipped tests are not green tests or a completed quality gate.

This is a local safety guard and audit trail, not an authentication system or tamper-proof ledger. Approval identity is an attestation; a repository owner can edit the journal or bypass Git hooks. Agents must not fabricate approval, erase history, use `--no-verify`, or disable/change hook configuration to evade a gate. Corrupted journals fail closed and must be preserved for investigation.

CI always runs the full suite, without this exception mechanism. Branch protection/rulesets are separate server settings; do not claim they are configured. An exception never authorizes a merge or waives other required evidence.

See [ADR 0009](../../docs/decisions/0009-local-push-gate-and-exceptions.md), [quality gate](quality-gate.md), and [review loop](review-loop.md).
