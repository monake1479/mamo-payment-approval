"""Exercise the real hook using isolated Git repositories and a fake FVM binary."""

from concurrent.futures import ThreadPoolExecutor
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(SOURCE / "tool"))
from test_scope import select_scope
BRANCH = "refs/heads/feature/test"


class PushGateTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="mamo-push-gate-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name).resolve()
        self.repo = self.root / "checkout"
        self.repo.mkdir()
        self.remote = self.root / "remote.git"
        self.calls = self.root / "fvm-calls.txt"
        self.env = {
            key: value for key, value in os.environ.items()
            if not key.startswith(("GIT_", "MAMO_PUSH_", "FIXTURE_"))
        }
        self.env.update(
            GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL=os.devnull,
            PYTHONDONTWRITEBYTECODE="1", FIXTURE_CALLS=str(self.calls),
        )
        self.git("init", "--initial-branch=feature/test")
        self.git("config", "user.name", "Fixture")
        self.git("config", "user.email", "fixture@example.invalid")
        self.git("config", "commit.gpgsign", "false")
        for relative in (".githooks/pre-push", "tool/push_gate.py", "tool/test_scope.py", "tool/install_hooks.sh"):
            destination = self.repo / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(SOURCE / relative, destination)
        (self.repo / ".githooks/pre-push").chmod(0o755)
        tests = self.repo / "tool/tests"
        tests.mkdir()
        # The fixture gate verifies this small suite, not this integration suite
        # recursively. Real pushes execute the full checked-out tool/tests suite.
        (tests / "test_fixture.py").write_text(
            "import unittest\nclass Fixture(unittest.TestCase):\n"
            "    def test_fixture(self):\n        self.assertTrue(True)\n"
        )
        (self.repo / "source.txt").write_text("initial\n")
        self.commit()
        self.git("init", "--bare", str(self.remote))
        self.git("remote", "add", "origin", str(self.remote))
        binary = self.root / "bin"
        binary.mkdir()
        fake_fvm = binary / "fvm"
        fake_fvm.write_text(
            f"#!{sys.executable}\n"
            "import os, pathlib, sys\n"
            "command = ' '.join(sys.argv[1:])\n"
            "with open(os.environ['FIXTURE_CALLS'], 'a') as stream:\n"
            "    stream.write(command + '\\n')\n"
            "if os.environ.get('FIXTURE_MUTATE') == command:\n"
            "    pathlib.Path('source.txt').write_text('changed during checks')\n"
            "sys.exit(1 if os.environ.get('FIXTURE_FAIL') == command else 0)\n"
        )
        fake_fvm.chmod(0o755)
        self.env["PATH"] = str(binary) + os.pathsep + self.env["PATH"]
        installed = self.command("sh", "tool/install_hooks.sh")
        self.assertEqual(installed.returncode, 0, installed.stderr)

    def command(self, *args, input=None, extra=None):
        return subprocess.run(
            args, cwd=self.repo, env={**self.env, **(extra or {})},
            input=input, text=True, capture_output=True, check=False,
        )

    def git(self, *args):
        result = self.command("git", *args)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip()

    def commit(self):
        self.git("add", ".")
        self.git("commit", "-m", "Fixture snapshot")

    def gate(self, exception=None, target=BRANCH, payload=None, extra=None, remote="origin", url=None):
        if payload is None:
            payload = f"{BRANCH} {self.git('rev-parse', 'HEAD')} {target} {'0' * 40}\n"
        return self.command(
            str(self.repo / ".githooks/pre-push"), remote, url or str(self.remote),
            input=payload,
            extra={**(extra or {}), **({"MAMO_PUSH_EXCEPTION": exception} if exception else {})},
        )

    def request(self):
        result = self.command(
            sys.executable, "tool/push_gate.py", "request",
            "--remote", "origin", "--target", BRANCH,
            "--requested-by", "Fixture requester", "--reason", "Fixture exception",
            "--test-result", "Failed fixture", "--risk", "Unverified fixture",
            "--follow-up", "Rerun after fixture repair",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip()

    def approve(self, request_id):
        return self.command(
            sys.executable, "tool/push_gate.py", "approve", request_id,
            "--approved-by", "Fixture owner", "--approval-reference", "Fixture permission",
        )

    def approved_request(self):
        request_id = self.request()
        result = self.approve(request_id)
        self.assertEqual(result.returncode, 0, result.stderr)
        return request_id

    def audit_path(self):
        return (self.repo / self.git("rev-parse", "--git-path", "mamo-push-audit")) / "events.jsonl"

    def records(self):
        return [json.loads(line) for line in self.audit_path().read_text().splitlines()]

    def commands(self):
        return self.calls.read_text().splitlines() if self.calls.exists() else []

    def assert_blocked(self, result):
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertNotIn("Traceback", result.stderr)

    def test_normal_gate_runs_all_checks_and_records_results(self):
        result = self.gate()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.commands(), [
            "flutter pub get --enforce-lockfile", "flutter gen-l10n",
            "dart format --output=none --set-exit-if-changed .", "flutter analyze", "flutter test",
        ])
        record = self.records()[-1]
        self.assertEqual(record["event"], "gate_allowed")
        self.assertEqual(record["tests"], "passed")
        self.assertEqual(record["transfer"], "not_observed_by_pre_push")
        self.assertEqual(len(record["checks"]), 6)
        for check in record["checks"]:
            self.assertTrue((self.audit_path().parent / check["log"]).is_file())

    def test_actual_local_push_is_blocked_on_failed_tests_then_succeeds(self):
        failed = self.command("git", "push", "origin", BRANCH, extra={"FIXTURE_FAIL": "flutter test"})
        self.assert_blocked(failed)
        self.assertNotEqual(self.command("git", "--git-dir", str(self.remote), "rev-parse", "--verify", BRANCH).returncode, 0)
        passed = self.command("git", "push", "origin", "HEAD:" + BRANCH)
        self.assertEqual(passed.returncode, 0, passed.stderr)
        self.assertEqual(self.git("--git-dir", str(self.remote), "rev-parse", BRANCH), self.git("rev-parse", "HEAD"))

    def test_each_fvm_failure_blocks_without_exception(self):
        for command in (
            "flutter pub get --enforce-lockfile", "flutter gen-l10n",
            "dart format --output=none --set-exit-if-changed .", "flutter analyze", "flutter test",
        ):
            with self.subTest(command=command):
                self.assert_blocked(self.gate(extra={"FIXTURE_FAIL": command}))
                self.assertEqual(self.records()[-1]["event"], "gate_blocked")

    def test_valid_exception_skips_only_flutter_tests_and_cannot_be_reused(self):
        request_id = self.approved_request()
        result = self.gate(request_id, extra={"FIXTURE_FAIL": "flutter test"})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("flutter test", self.commands())
        self.assertEqual(len(self.commands()), 4)
        self.assertEqual([r["event"] for r in self.records()], [
            "requested", "approved", "attempt_started", "checks_selected", "consumed", "gate_allowed",
        ])
        self.assertEqual(self.records()[-1]["checks"][-2]["check"], "hook-tests")
        self.assertEqual(self.records()[-1]["checks"][-1]["status"], "skipped")
        self.assert_blocked(self.gate(request_id))

    def test_no_approval_no_exception(self):
        request_id = self.request()
        self.assert_blocked(self.gate(request_id))
        self.assertEqual(self.commands(), [])
        self.assertNotIn("consumed", [r["event"] for r in self.records()])
        self.assert_blocked(self.gate("invalid"))
        self.assert_blocked(self.gate("0" * 32))

    def test_failed_mandatory_check_consumes_exception(self):
        for command in ("flutter analyze", "dart format --output=none --set-exit-if-changed ."):
            with self.subTest(command=command):
                request_id = self.approved_request()
                self.assert_blocked(self.gate(request_id, extra={"FIXTURE_FAIL": command}))
                self.assert_blocked(self.gate(request_id))
                self.assertEqual(sum(r["event"] == "consumed" and r.get("request_id") == request_id for r in self.records()), 1)

    def test_hook_tests_cannot_be_skipped(self):
        (self.repo / "tool/tests/test_fixture.py").write_text(
            "import unittest\nclass Fixture(unittest.TestCase):\n"
            "    def test_failure(self):\n        self.fail('Fixture failure')\n"
        )
        self.commit()
        self.assert_blocked(self.gate(self.approved_request()))
        self.assertEqual(self.records()[-1]["checks"][-1]["check"], "hook-tests")

    def test_dirty_untracked_and_staged_changes_block_before_checks(self):
        source = self.repo / "source.txt"
        source.write_text("changed")
        self.assert_blocked(self.gate())
        self.git("add", "source.txt")
        self.assert_blocked(self.gate())
        self.commit()
        (self.repo / "untracked.txt").write_text("untracked")
        self.assert_blocked(self.gate())
        self.assertEqual(self.commands(), [])

    def test_unsupported_pushes_are_rejected(self):
        sha = self.git("rev-parse", "HEAD")
        valid = f"{BRANCH} {sha} {BRANCH} {'0' * 40}\n"
        payloads = [
            "malformed\n", valid + valid,
            f"(delete) {'0' * 40} {BRANCH} {sha}\n",
            f"refs/heads/other {sha} {BRANCH} {'0' * 40}\n",
            f"{BRANCH} {'1' * 40} {BRANCH} {'0' * 40}\n",
            f"{BRANCH} {sha} {BRANCH} invalid\n",
        ]
        for payload in payloads:
            with self.subTest(payload=payload):
                self.assert_blocked(self.gate(payload=payload))
        for target in ("refs/heads/main", "refs/heads/dev", "refs/tags/v1"):
            self.assert_blocked(self.gate(target=target))
        self.assert_blocked(self.gate(remote=str(self.remote)))
        self.assert_blocked(self.gate(url="https://secret@example.invalid/repository"))
        self.assertNotIn("secret", self.audit_path().read_text())
        self.assertEqual(self.commands(), [])

    def test_changed_commit_invalidates_request_and_approval(self):
        pending = self.request()
        approved = self.approved_request()
        (self.repo / "source.txt").write_text("new revision")
        self.commit()
        self.assert_blocked(self.approve(pending))
        self.assert_blocked(self.gate(approved))

    def test_changed_destination_and_branch_invalidate_approval(self):
        request_id = self.approved_request()
        self.assert_blocked(self.gate(request_id, target="refs/heads/other"))
        self.git("remote", "set-url", "origin", str(self.root / "other.git"))
        self.assert_blocked(self.gate(request_id, url=str(self.root / "other.git")))
        self.git("remote", "set-url", "origin", str(self.remote))
        self.git("branch", "-m", "feature/renamed")
        payload = f"refs/heads/feature/renamed {self.git('rev-parse', 'HEAD')} {BRANCH} {'0' * 40}\n"
        self.assert_blocked(self.gate(request_id, payload=payload))

    def test_concurrent_attempts_can_consume_approval_only_once(self):
        request_id = self.approved_request()
        with ThreadPoolExecutor(max_workers=2) as pool:
            results = list(pool.map(lambda _: self.gate(request_id), range(2)))
        self.assertEqual(sorted(r.returncode for r in results), [0, 1])
        self.assertEqual(sum(r["event"] == "consumed" for r in self.records()), 1)

    def test_changes_during_checks_block_push(self):
        self.assert_blocked(self.gate(extra={"FIXTURE_MUTATE": "flutter analyze"}))

    def test_empty_push_does_not_run_checks(self):
        result = self.gate(payload="")
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self.commands(), [])

    def test_invalid_journal_blocks_without_traceback(self):
        self.request()
        for value in ("not-json", "null", '"text"', "{}"):
            with self.subTest(value=value):
                self.audit_path().write_text(value + "\n")
                self.assert_blocked(self.gate())

    def test_incomplete_request_and_duplicate_approval_are_rejected(self):
        request_id = self.approved_request()
        self.assert_blocked(self.approve(request_id))
        records = self.records()
        del records[0]["head"]
        self.audit_path().write_text("\n".join(json.dumps(r) for r in records[:1]) + "\n")
        self.assert_blocked(self.approve(request_id))

    def test_required_explanation_is_not_optional(self):
        result = self.command(sys.executable, "tool/push_gate.py", "request", "--reason", " ")
        self.assert_blocked(result)

    def test_missing_fvm_fails_closed(self):
        (self.root / "bin/fvm").unlink()
        # Keep Python available without falling back to the developer's FVM.
        isolated = self.root / "isolated-bin"
        isolated.mkdir()
        for command in ("git", "python3", "dirname"):
            (isolated / command).symlink_to(shutil.which(command))
        self.assert_blocked(self.gate(extra={"PATH": str(isolated) + ":/usr/bin:/bin"}))

    def test_installation_is_worktree_local_and_idempotent(self):
        expected = ".githooks"
        self.assertEqual(self.git("config", "--worktree", "--get", "core.hooksPath"), expected)
        self.assertNotEqual(self.command("git", "config", "--local", "--get", "core.hooksPath").returncode, 0)
        self.assertEqual(self.command("sh", "tool/install_hooks.sh").returncode, 0)
        other = self.root / "other-worktree"
        self.git("worktree", "add", "-b", "feature/other", str(other))
        # Git may copy worktree config on add. A relative path safely resolves
        # to that checkout's hook, never a script in the original checkout.
        self.assertEqual(self.git("-C", str(other), "config", "--get", "core.hooksPath"), expected)
        self.git("config", "--worktree", "core.hooksPath", "custom-hooks")
        self.assertEqual(self.git("-C", str(other), "config", "--get", "core.hooksPath"), expected)

    def test_installer_preserves_existing_hooks(self):
        self.git("config", "--worktree", "core.hooksPath", str(self.root / "custom"))
        self.assert_blocked(self.command("sh", "tool/install_hooks.sh"))
        self.git("config", "--worktree", "--unset", "core.hooksPath")
        active_hook = self.repo / ".git/hooks/pre-push"
        active_hook.write_text("#!/bin/sh\nexit 1\n")
        active_hook.chmod(0o755)
        self.assert_blocked(self.command("sh", "tool/install_hooks.sh"))

    def test_documentation_only_push_runs_no_flutter_checks(self):
        self.git("update-ref", "refs/remotes/origin/dev", "HEAD")
        (self.repo / "README.md").write_text("Documentation only")
        self.commit()
        result = self.gate()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.commands(), [])
        self.assertEqual(self.records()[-1]["tests"], "not_needed")

    def test_existing_remote_tip_limits_scope_to_unpushed_changes(self):
        base = self.git("rev-parse", "HEAD")
        tests = self.repo / "test/app"
        tests.mkdir(parents=True)
        (tests / "app_test.dart").write_text("fixture")
        self.commit()
        payload = f"{BRANCH} {self.git('rev-parse', 'HEAD')} {BRANCH} {base}\n"
        result = self.gate(payload=payload)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.commands()[-1], "flutter test test/app/app_test.dart")
        self.assertEqual(self.records()[1]["base"], base)

    def test_tool_only_push_runs_hook_tests_without_flutter(self):
        self.git("update-ref", "refs/remotes/origin/dev", "HEAD")
        (self.repo / "tool/note.txt").write_text("Fixture tool input")
        self.commit()
        result = self.gate()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.commands(), [])
        self.assertEqual([c["check"] for c in self.records()[-1]["checks"]], ["hook-tests"])

    def test_new_branch_scope_includes_all_unpushed_commits(self):
        self.git("update-ref", "refs/remotes/origin/dev", "HEAD")
        tests = self.repo / "test/app"
        tests.mkdir(parents=True)
        (tests / "app_test.dart").write_text("fixture")
        (tests / "app_failure_view_test.dart").write_text("fixture")
        source = self.repo / "lib/features/payments/presentation/pages/foundation_page.dart"
        source.parent.mkdir(parents=True)
        source.write_text("fixture")
        self.commit()
        (self.repo / "README.md").write_text("Later documentation change")
        self.commit()
        result = self.gate()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.commands()[-1], "flutter test test/app/app_failure_view_test.dart test/app/app_test.dart")

    def test_unavailable_remote_history_falls_back_to_full_suite(self):
        payload = f"{BRANCH} {self.git('rev-parse', 'HEAD')} {BRANCH} {'1' * 40}\n"
        result = self.gate(payload=payload)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.commands()[-1], "flutter test")
        self.assertIsNone(self.records()[1]["base"])


class TestScopeTest(unittest.TestCase):
    def test_existing_foundation_mapping(self):
        scope = select_scope(["lib/features/payments/presentation/pages/foundation_page.dart"], SOURCE)
        self.assertEqual(scope["flutter_tests"], ["test/app/app_failure_view_test.dart", "test/app/app_test.dart"])

    def test_unknown_shared_deleted_and_missing_inputs_fall_back(self):
        for path in ("lib/new.dart", "lib/core/shared.dart", "pubspec.lock", "lib/main.dart", "test/deleted_test.dart"):
            with self.subTest(path=path):
                self.assertIsNone(select_scope([path], SOURCE)["flutter_tests"])
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "lib/features/payments/presentation/pages/foundation_page.dart"
            source.parent.mkdir(parents=True)
            source.write_text("fixture")
            self.assertIsNone(select_scope([str(source.relative_to(root))], root)["flutter_tests"])

    def test_mixed_documentation_and_test_change_preserves_test_selection(self):
        scope = select_scope(["README.md", "docs/testing/strategy.md", "test/app/app_test.dart"], SOURCE)
        self.assertEqual(scope["flutter_tests"], ["test/app/app_test.dart"])

    def test_missing_base_is_full_suite(self):
        scope = select_scope(None, SOURCE)
        self.assertIsNone(scope["flutter_tests"])
        self.assertTrue(scope["hook_tests"])


if __name__ == "__main__":
    unittest.main()
