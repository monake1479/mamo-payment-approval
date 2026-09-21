"""Verify focused push-gate mappings for the About (application information) slice."""

from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tool"))
from test_scope import select_scope

BOOTSTRAP_TEST = "test/app/bootstrap_test.dart"
CLIENT_TEST = "test/common/data/app_info/package_info_client_test.dart"
USE_CASE_TEST = "test/common/data/app_info/load_app_build_info_use_case_test.dart"
CUBIT_TEST = "test/features/settings/states/about/about_cubit_test.dart"
SECTION_TEST = "test/features/settings/widgets/about_section_test.dart"
SETTINGS_PAGE_TEST = "test/features/settings/pages/settings_page_test.dart"
APP_THEME_MODE_TEST = "test/app/app_theme_mode_test.dart"

APP_INFO_DATA_TESTS = [CLIENT_TEST, USE_CASE_TEST]
ABOUT_STATE_TESTS = [CUBIT_TEST, SECTION_TEST, SETTINGS_PAGE_TEST, APP_THEME_MODE_TEST]
ABOUT_UI_TESTS = [SECTION_TEST, SETTINGS_PAGE_TEST, APP_THEME_MODE_TEST]
# App-level tests that construct the router with the About cubit factory.
APP_SHELL_TESTS = [
    "test/app/app_test.dart",
    "test/app/app_theme_test.dart",
    "test/app/approval_flow_test.dart",
    APP_THEME_MODE_TEST,
]


class AboutScopeTest(unittest.TestCase):
    def test_data_source_change_selects_data_and_state_tests(self):
        scope = select_scope(
            ["lib/common/data/app_info/data_sources/package_info_client.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted([BOOTSTRAP_TEST, *APP_INFO_DATA_TESTS, *ABOUT_STATE_TESTS]),
        )
        self.assertFalse(scope["hook_tests"])

    def test_cubit_change_selects_state_and_app_consumers(self):
        scope = select_scope(
            ["lib/features/settings/states/about/about_cubit.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted(set([BOOTSTRAP_TEST, *ABOUT_STATE_TESTS, *APP_SHELL_TESTS])),
        )
        self.assertFalse(scope["hook_tests"])

    def test_generated_state_change_selects_state_consumers(self):
        scope = select_scope(
            ["lib/features/settings/states/about/about_state.freezed.dart"],
            ROOT,
        )

        self.assertEqual(scope["flutter_tests"], sorted(ABOUT_STATE_TESTS))
        self.assertFalse(scope["hook_tests"])

    def test_widget_change_selects_ui_consumers(self):
        scope = select_scope(
            ["lib/features/settings/widgets/about_details_card.dart"],
            ROOT,
        )

        self.assertEqual(scope["flutter_tests"], sorted(ABOUT_UI_TESTS))
        self.assertFalse(scope["hook_tests"])

    def test_test_support_change_selects_every_consumer(self):
        scope = select_scope(["test/support/app_info_test_support.dart"], ROOT)

        self.assertEqual(
            scope["flutter_tests"],
            sorted(set([*APP_INFO_DATA_TESTS, *ABOUT_STATE_TESTS, *APP_SHELL_TESTS])),
        )
        self.assertFalse(scope["hook_tests"])

    def test_module_change_selects_bootstrap(self):
        scope = select_scope(["lib/app/di/app_info_module.dart"], ROOT)

        self.assertEqual(scope["flutter_tests"], [BOOTSTRAP_TEST])
        self.assertFalse(scope["hook_tests"])


if __name__ == "__main__":
    unittest.main()
