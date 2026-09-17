#!/usr/bin/env python3
"""Local push checks and auditable, single-attempt Flutter-test exceptions.

Approval fields are attestations, not identity authentication. This local tool
cannot prevent a repository owner from disabling hooks or editing its journal.
"""

import argparse
from contextlib import contextmanager
from datetime import datetime, timezone
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import uuid

from test_scope import select_scope


class GateError(Exception):
    """An actionable failure that must block the push."""


def git(*args):
    result = subprocess.run(
        ["git", *args], capture_output=True, text=True, check=False
    )
    if result.returncode:
        # Do not echo Git stderr: it can contain a credential-bearing remote URL.
        raise GateError(f"Git {args[0]} failed; check the repository configuration.")
    return result.stdout.strip()


def clean_head():
    if git("status", "--porcelain", "--untracked-files=all"):
        raise GateError("Commit or set aside local changes explicitly before pushing.")
    return git("rev-parse", "HEAD"), git("symbolic-ref", "--short", "HEAD")


def destination(remote, target):
    if remote not in git("remote").splitlines():
        raise GateError("Use a configured remote name, not a direct URL.")
    if not target.startswith("refs/heads/"):
        raise GateError("This gate supports a single branch update, not tags/deletions.")
    git("check-ref-format", target)
    if target in ("refs/heads/dev", "refs/heads/main"):
        raise GateError("Use a PR for dev/main; direct pushes are not permitted.")
    urls = git("remote", "get-url", "--push", "--all", remote).splitlines()
    if len(urls) != 1:
        raise GateError("Configure exactly one push URL for this remote.")
    return {
        "remote": remote,
        "remote_url_sha256": hashlib.sha256(urls[0].encode()).hexdigest(),
        "target": target,
    }


def context(remote, target):
    head, branch = clean_head()
    return {"head": head, "branch": branch, **destination(remote, target)}


@contextmanager
def journal():
    directory = Path(git("rev-parse", "--git-path", "mamo-push-audit")).resolve()
    directory.mkdir(parents=True, exist_ok=True)
    with (directory / ".lock").open("a") as lock:
        # Serialize approval consumption, including concurrent push attempts.
        fcntl.flock(lock, fcntl.LOCK_EX)
        yield directory


def append_event(directory, event, **fields):
    record = {
        "event": event,
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        **fields,
    }
    with (directory / "events.jsonl").open("a", encoding="utf-8") as stream:
        stream.write(json.dumps(record, sort_keys=True) + "\n")
        stream.flush()
        os.fsync(stream.fileno())


def events(directory):
    path = directory / "events.jsonl"
    if not path.exists():
        return []
    try:
        records = [json.loads(line) for line in path.read_text().splitlines()]
        if any(not isinstance(r, dict) or not isinstance(r.get("event"), str) for r in records):
            raise ValueError("Invalid event structure")
        return records
    except (ValueError, TypeError) as error:
        raise GateError("The audit journal is invalid; preserve it and investigate.") from error


def request_record(directory, request_id):
    if not re.fullmatch(r"[0-9a-f]{32}", request_id):
        raise GateError("Invalid exception ID.")
    records = [r for r in events(directory) if r.get("request_id") == request_id]
    requests = [r for r in records if r.get("event") == "requested"]
    if len(requests) != 1:
        raise GateError("Exception request not found or duplicated.")
    return requests[0], records


def require_matching_context(request):
    if any(key not in request for key in ("remote", "target", "head", "branch", "remote_url_sha256")):
        raise GateError("The request is incomplete; preserve the journal and investigate.")
    current = context(request["remote"], request["target"])
    if any(current[key] != request[key] for key in current):
        raise GateError("The commit, branch, or destination changed; request a new exception.")


def request_exception(args):
    current = context(args.remote, args.target)
    request_id = uuid.uuid4().hex
    with journal() as directory:
        events(directory)
        append_event(
            directory, "requested", request_id=request_id, **current,
            requested_by=args.requested_by, reason=args.reason,
            previous_test_result=args.test_result, risk=args.risk,
            follow_up=args.follow_up, skipped_check="fvm flutter test",
        )
    print(request_id)


def approve_exception(args):
    with journal() as directory:
        request, history = request_record(directory, args.request_id)
        if any(r["event"] in ("approved", "consumed") for r in history):
            raise GateError("This request is already approved or consumed.")
        require_matching_context(request)
        append_event(
            directory, "approved", request_id=args.request_id,
            approved_by=args.approved_by, approval_reference=args.approval_reference,
        )
    print("Approval recorded. Only one matching pre-push attempt may skip Flutter tests.")


def run_check(directory, attempt_id, label, command, results):
    log_name = f"{attempt_id}-{label}.log"
    print(f"Push gate: {label}", flush=True)
    with (directory / log_name).open("w", encoding="utf-8") as log:
        result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, check=False)
    results.append({"check": label, "exit_code": result.returncode, "log": log_name})
    if result.returncode:
        raise GateError(f"{label} failed. Inspect {directory / log_name}.")


def test_scope(remote, remote_sha, head):
    base = remote_sha
    if not base.strip("0"):
        # First push: compare with the locally known integration branch. Never
        # fetch implicitly or use HEAD's parent (which would miss earlier work).
        try:
            base = git("merge-base", head, f"refs/remotes/{remote}/dev")
        except GateError:
            return {"base": None, "changed_paths": None, **select_scope(None)}
    try:
        changed = git("diff", "--name-only", "--no-renames", "-z", base, head, "--").split("\0")
    except GateError:
        return {"base": None, "changed_paths": None, **select_scope(None)}
    changed = sorted(path for path in changed if path)
    return {"base": base, "changed_paths": changed, **select_scope(changed)}


def run_gate(args):
    updates = [line.split() for line in sys.stdin.read().splitlines() if line.strip()]
    if not updates:
        return  # An up-to-date push has no new code to verify.
    attempt_id = uuid.uuid4().hex
    request_id = os.environ.get("MAMO_PUSH_EXCEPTION")
    results = []
    with journal() as directory:
        try:
            events(directory)
            if len(updates) != 1 or len(updates[0]) != 4:
                raise GateError("Push one checked-out branch at a time.")
            local_ref, local_sha, target, remote_sha = updates[0]
            current = context(args.remote, target)
            allowed_refs = ("HEAD", current["branch"], "refs/heads/" + current["branch"])
            if local_ref not in allowed_refs or local_sha != current["head"]:
                raise GateError("The pushed branch must be the checked-out HEAD.")
            if not re.fullmatch(r"[0-9a-f]{40}|[0-9a-f]{64}", remote_sha):
                raise GateError("Invalid remote revision in the pre-push input.")
            url_hash = hashlib.sha256(args.remote_url.encode()).hexdigest()
            if url_hash != current["remote_url_sha256"]:
                raise GateError("The push URL does not match the configured destination.")
            append_event(directory, "attempt_started", attempt_id=attempt_id, **current)
            scope = test_scope(args.remote, remote_sha, current["head"])
            selected = scope["flutter_tests"]
            needs_flutter = selected is None or bool(selected)
            append_event(directory, "checks_selected", attempt_id=attempt_id, **scope)
            print("Push scope: " + "; ".join(scope["reasons"]), flush=True)
            print("Flutter tests: " + ("full suite" if selected is None else ", ".join(selected) or "none"), flush=True)
            if request_id:
                if not needs_flutter:
                    raise GateError("This push needs no Flutter tests; remove the exception ID.")
                request, history = request_record(directory, request_id)
                if any(request.get(key) != value for key, value in current.items()):
                    raise GateError("Exception does not match this commit, branch, and destination.")
                if sum(r["event"] == "approved" for r in history) != 1:
                    raise GateError("The exception has not been approved.")
                if any(r["event"] == "consumed" for r in history):
                    raise GateError("The exception was already used; request a new one.")
                # Consume before checks: a failure, interruption, or failed network
                # transfer must not leave reusable authority for another attempt.
                append_event(directory, "consumed", request_id=request_id, attempt_id=attempt_id)

            checks = []
            if needs_flutter:
                checks.extend([
                    ("dependencies", ["fvm", "flutter", "pub", "get", "--enforce-lockfile"]),
                    ("localizations", ["fvm", "flutter", "gen-l10n"]),
                ])
                if scope["format_paths"]:
                    checks.append(("format", ["fvm", "dart", "format", "--output=none", "--set-exit-if-changed", *scope["format_paths"]]))
                checks.append(("analyze", ["fvm", "flutter", "analyze"]))
            if scope["hook_tests"]:
                checks.append(("hook-tests", [sys.executable, "-B", "-m", "unittest", "discover", "-s", "tool/tests", "-p", "test_*.py"]))
            for label, command in checks:
                run_check(directory, attempt_id, label, command, results)
            if request_id:
                results.append({"check": "flutter-tests", "status": "skipped", "request_id": request_id})
            elif needs_flutter:
                run_check(directory, attempt_id, "flutter-tests", ["fvm", "flutter", "test", *(selected or [])], results)
            if context(args.remote, target) != current:
                raise GateError("Repository state changed during checks; push was blocked.")
            append_event(
                directory, "gate_allowed", attempt_id=attempt_id,
                request_id=request_id, checks=results,
                tests="skipped" if request_id else "passed" if needs_flutter else "not_needed",
                transfer="not_observed_by_pre_push",
            )
        except (GateError, OSError, KeyboardInterrupt) as error:
            append_event(
                directory, "gate_blocked", attempt_id=attempt_id,
                request_id=request_id, checks=results, reason=str(error),
            )
            raise
    print("Push gate passed." if not request_id else "Push allowed with an audited Flutter-test exception; tests are NOT verified.")


def nonempty(value):
    if not value.strip():
        raise argparse.ArgumentTypeError("A non-empty explanation is required.")
    return value.strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    request = commands.add_parser("request", help="Record a request; does not approve it.")
    for name in ("remote", "target", "requested-by", "reason", "test-result", "risk", "follow-up"):
        request.add_argument("--" + name, required=True, type=nonempty)
    request.set_defaults(action=request_exception)
    approve = commands.add_parser("approve", help="Record explicit owner approval already obtained.")
    approve.add_argument("request_id")
    approve.add_argument("--approved-by", required=True, type=nonempty)
    approve.add_argument("--approval-reference", required=True, type=nonempty)
    approve.set_defaults(action=approve_exception)
    run = commands.add_parser("run", help="Called by Git pre-push; reads updates from stdin.")
    run.add_argument("remote")
    run.add_argument("remote_url")
    run.set_defaults(action=run_gate)
    args = parser.parse_args()
    try:
        os.chdir(git("rev-parse", "--show-toplevel"))
        args.action(args)
    except (GateError, OSError, KeyboardInterrupt) as error:
        print(f"Push gate blocked: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
