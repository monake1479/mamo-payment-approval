"""Verify focused push-gate mappings for device authentication."""

from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tool"))
from test_scope import select_scope

CLIENT_TEST = (
    "test/common/data/device_authentication/local_auth_client_test.dart"
)
REPO_TEST = (
    "test/common/data/device_authentication/local_auth_repository_test.dart"
)
AUTH_USE_CASE_TEST = (
    "test/common/data/device_authentication/use_cases/"
    "local_authentication_use_case_test.dart"
)
IS_SUPPORTED_USE_CASE_TEST = (
    "test/common/data/device_authentication/use_cases/"
    "is_local_auth_supported_use_case_test.dart"
)
STOP_USE_CASE_TEST = (
    "test/common/data/device_authentication/use_cases/"
    "stop_local_authentication_use_case_test.dart"
)
BOOTSTRAP_TEST = "test/app/bootstrap_test.dart"
# The About section reads device-authentication availability through the
# repository, so repository changes also exercise its state and surfaces.
ABOUT_STATE_TESTS = [
    "test/features/settings/states/about/about_cubit_test.dart",
    "test/features/settings/widgets/about_section_test.dart",
    "test/features/settings/pages/settings_page_test.dart",
    "test/app/app_theme_mode_test.dart",
]


class DeviceAuthenticationScopeTest(unittest.TestCase):
    def test_repository_change_selects_repository_and_use_case_tests(self):
        scope = select_scope(
            [
                "lib/common/data/device_authentication/"
                "local_auth_repository.dart",
            ],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted(
                [
                    BOOTSTRAP_TEST,
                    CLIENT_TEST,
                    REPO_TEST,
                    IS_SUPPORTED_USE_CASE_TEST,
                    AUTH_USE_CASE_TEST,
                    STOP_USE_CASE_TEST,
                    *ABOUT_STATE_TESTS,
                ]
            ),
        )
        self.assertFalse(scope["hook_tests"])

    def test_use_case_change_selects_its_own_test(self):
        scope = select_scope(
            [
                "lib/common/data/device_authentication/use_cases/"
                "stop_local_authentication_use_case.dart",
            ],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted([BOOTSTRAP_TEST, STOP_USE_CASE_TEST]),
        )
        self.assertFalse(scope["hook_tests"])

    def test_failure_change_selects_repository_and_auth_tests(self):
        scope = select_scope(
            [
                "lib/common/data/device_authentication/error_handling/"
                "device_authentication_failure.dart",
            ],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted([CLIENT_TEST, REPO_TEST, AUTH_USE_CASE_TEST]),
        )
        self.assertFalse(scope["hook_tests"])

    def test_generated_failure_change_selects_repository_and_auth_tests(self):
        scope = select_scope(
            [
                "lib/common/data/device_authentication/error_handling/"
                "device_authentication_failure.freezed.dart",
            ],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted([CLIENT_TEST, REPO_TEST, AUTH_USE_CASE_TEST]),
        )
        self.assertFalse(scope["hook_tests"])


if __name__ == "__main__":
    unittest.main()
