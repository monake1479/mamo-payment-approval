"""Verify focused push-gate mappings for the payments data slice."""

from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tool"))
from test_scope import PAYMENTS_UI_TESTS, select_scope


def with_ui(*tests):
    return sorted({*tests, *PAYMENTS_UI_TESTS})


class PaymentsScopeTest(unittest.TestCase):
    def test_cubit_change_selects_its_state_tests(self):
        scope = select_scope(
            ["lib/features/payments/states/payments/payments_cubit.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            with_ui("test/features/payments/states/payments/payments_cubit_test.dart"),
        )
        self.assertFalse(scope["hook_tests"])

    def test_state_change_selects_cubit_tests(self):
        scope = select_scope(
            ["lib/features/payments/states/payments/payments_state.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            with_ui("test/features/payments/states/payments/payments_cubit_test.dart"),
        )
        self.assertFalse(scope["hook_tests"])

    def test_dto_change_selects_boundary_consumers(self):
        scope = select_scope(
            ["lib/common/data/payments/dtos/payment_dto.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            with_ui(
                "test/common/data/payments/models/payment_serialization_test.dart",
                "test/common/data/payments/payments_repository_test.dart",
            ),
        )
        self.assertFalse(scope["hook_tests"])

    def test_repository_contract_selects_data_and_state_consumers(self):
        scope = select_scope(
            ["lib/common/data/payments/payments_repository.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            with_ui(
                "test/common/data/payments/payments_repository_test.dart",
                "test/common/data/payments/use_cases/payment_use_cases_test.dart",
                "test/features/payments/states/payments/payments_cubit_test.dart",
            ),
        )

    def test_summary_change_selects_projection_consumers(self):
        scope = select_scope(
            ["lib/common/data/payments/models/payment_summary.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            with_ui(
                "test/common/data/payments/models/payments_collection_test.dart",
                "test/common/data/payments/use_cases/payment_use_cases_test.dart",
                "test/features/payments/states/payments/payments_cubit_test.dart",
            ),
        )

    def test_mock_backend_change_selects_contract_consumers(self):
        scope = select_scope(
            ["lib/mock_backend/payments/mock_payments_backend.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            with_ui(
                "test/common/data/payments/payments_repository_test.dart",
                "test/common/data/payments/use_cases/payment_use_cases_test.dart",
                "test/features/payments/states/payments/payments_cubit_test.dart",
                "test/mock_backend/payments/mock_payments_backend_test.dart",
            ),
        )

    def test_payment_row_change_selects_all_screen_consumers(self):
        scope = select_scope(
            ["lib/features/payments/widgets/payment_row.dart"],
            ROOT,
        )

        self.assertEqual(scope["flutter_tests"], sorted(PAYMENTS_UI_TESTS))
        self.assertFalse(scope["hook_tests"])


if __name__ == "__main__":
    unittest.main()
