"""Scanner wrapper tests without downloads, real credentials, or external Git."""

import contextlib
import io
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from scan_secrets import scan


class SecretScanTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        (self.root / "source.txt").write_text("safe fixture")
        self.commands = []
        self.scanner_exit = 0
        self.version = "8.30.1"

    def run_command(self, command, **kwargs):
        self.commands.append(command)
        if command[1] == "version":
            return subprocess.CompletedProcess(command, 0, stdout=self.version)
        if command[0] == "git":
            return subprocess.CompletedProcess(command, 0, stdout=b"source.txt\0deleted.txt\0")
        self.assertIn("--redact=100", command)
        self.assertIn("--ignore-gitleaks-allow", command)
        if command[1] == "dir":
            snapshot = Path(command[2])
            self.assertEqual((snapshot / "source.txt").read_text(), "safe fixture")
            self.assertFalse((snapshot / "deleted.txt").exists())
            self.assertFalse((snapshot / "ignored.txt").exists())
        return subprocess.CompletedProcess(command, self.scanner_exit, stdout=b"PRIVATE CONTEXT")

    def invoke(self):
        output = io.StringIO()
        with patch("scan_secrets.subprocess.run", side_effect=self.run_command), contextlib.redirect_stdout(output):
            result = scan(self.root, "fixture-gitleaks")
        self.assertNotIn("PRIVATE CONTEXT", output.getvalue())
        return result, output.getvalue()

    def test_scans_snapshot_and_history_without_ignored_files(self):
        (self.root / "ignored.txt").write_text("not publishable")
        result, output = self.invoke()
        self.assertEqual(result, 0)
        self.assertEqual(output.count("passed"), 2)
        self.assertIn("--log-opts=--all", self.commands[-1])

    def test_findings_and_tool_errors_fail_closed_without_context(self):
        for code in (1, 2):
            with self.subTest(code=code):
                self.scanner_exit = code
                result, output = self.invoke()
                self.assertEqual(result, 1)
                self.assertNotIn("passed", output)

    def test_wrong_version_is_rejected(self):
        self.version = "0.0.0"
        with self.assertRaises(ValueError):
            self.invoke()
        self.assertEqual(len(self.commands), 1)

    def test_symlinks_are_not_followed(self):
        (self.root / "source.txt").unlink()
        (self.root / "source.txt").symlink_to(self.root / "elsewhere.txt")
        with self.assertRaises(ValueError):
            self.invoke()
        self.assertEqual(len(self.commands), 2)
