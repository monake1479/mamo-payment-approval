"""Verify focused push-gate mappings for device authentication."""

from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tool"))
from test_scope import AUTHENTICATION_TESTS, select_scope


class DeviceAuthenticationScopeTest(unittest.TestCase):
    def test_adapter_change_selects_adapter_and_composition_tests(self):
        scope = select_scope(
            [
                "lib/common/data/device_authentication/"
                "local_auth_device_authenticator.dart",
            ],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted(set(AUTHENTICATION_TESTS)),
        )
        self.assertFalse(scope["hook_tests"])

    def test_failure_change_selects_adapter_and_approval_consumers(self):
        scope = select_scope(
            ["lib/common/error_handling/device_authentication_failure.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted(set(AUTHENTICATION_TESTS)),
        )
        self.assertFalse(scope["hook_tests"])


if __name__ == "__main__":
    unittest.main()
