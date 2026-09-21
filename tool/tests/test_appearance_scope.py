"""Verify focused push-gate mappings for the appearance (theme-mode) slice."""

from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tool"))
from test_scope import select_scope

BOOTSTRAP_TEST = "test/app/bootstrap_test.dart"
LOCAL_DS_TEST = (
    "test/common/data/appearance/theme_preference_local_data_source_test.dart"
)
USE_CASES_TEST = (
    "test/common/data/appearance/theme_preference_use_cases_test.dart"
)
CUBIT_TEST = "test/features/settings/states/theme_mode/theme_mode_cubit_test.dart"
SELECTOR_TEST = "test/features/settings/widgets/theme_mode_selector_test.dart"
SETTINGS_PAGE_TEST = "test/features/settings/pages/settings_page_test.dart"
APP_TEST = "test/app/app_theme_mode_test.dart"

APPEARANCE_TESTS = [
    LOCAL_DS_TEST,
    USE_CASES_TEST,
    CUBIT_TEST,
    SELECTOR_TEST,
    SETTINGS_PAGE_TEST,
    APP_TEST,
]


class AppearanceScopeTest(unittest.TestCase):
    def test_data_source_change_selects_the_full_slice(self):
        scope = select_scope(
            [
                "lib/common/data/appearance/data_sources/"
                "theme_preference_local_data_source.dart",
            ],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted([BOOTSTRAP_TEST, *APPEARANCE_TESTS]),
        )
        self.assertFalse(scope["hook_tests"])

    def test_cubit_change_selects_its_consumers(self):
        scope = select_scope(
            ["lib/features/settings/states/theme_mode/theme_mode_cubit.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted([BOOTSTRAP_TEST, CUBIT_TEST, SETTINGS_PAGE_TEST, APP_TEST]),
        )
        self.assertFalse(scope["hook_tests"])

    def test_failure_change_selects_data_and_state_tests(self):
        scope = select_scope(
            [
                "lib/common/data/appearance/error_handling/"
                "appearance_failure.dart",
            ],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted([LOCAL_DS_TEST, USE_CASES_TEST, CUBIT_TEST]),
        )
        self.assertFalse(scope["hook_tests"])

    def test_generated_state_change_selects_state_consumers(self):
        scope = select_scope(
            [
                "lib/features/settings/states/theme_mode/"
                "theme_mode_state.freezed.dart",
            ],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted([CUBIT_TEST, SETTINGS_PAGE_TEST, APP_TEST]),
        )
        self.assertFalse(scope["hook_tests"])

    def test_preferences_module_change_selects_bootstrap(self):
        scope = select_scope(
            ["lib/app/di/app_preferences_module.dart"],
            ROOT,
        )

        self.assertEqual(scope["flutter_tests"], [BOOTSTRAP_TEST])
        self.assertFalse(scope["hook_tests"])


if __name__ == "__main__":
    unittest.main()
