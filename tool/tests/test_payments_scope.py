"""Verify focused push-gate mappings for the payments data slice."""

from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tool"))
from test_scope import PAYMENTS_UI_TESTS, select_scope


class PaymentsScopeTest(unittest.TestCase):
    def test_cubit_change_selects_its_state_tests(self):
        scope = select_scope(
            ["lib/features/payments/presentation/cubit/payments_cubit.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted(
                {
                    "test/features/payments/presentation/cubit/payments_cubit_test.dart",
                    *PAYMENTS_UI_TESTS,
                }
            ),
        )
        self.assertFalse(scope["hook_tests"])

    def test_money_change_selects_all_current_consumers(self):
        scope = select_scope(
            ["lib/features/payments/domain/payment_money.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted(
                {
                    "test/features/payments/data/in_memory_payments_repository_test.dart",
                    "test/features/payments/data/payment_record_codec_test.dart",
                    "test/features/payments/domain/payment_money_test.dart",
                    "test/features/payments/domain/payment_operations_test.dart",
                    "test/features/payments/domain/payment_test.dart",
                    "test/features/payments/presentation/cubit/payments_cubit_test.dart",
                    *PAYMENTS_UI_TESTS,
                }
            ),
        )
        self.assertFalse(scope["hook_tests"])

    def test_repository_contract_selects_data_and_state_consumers(self):
        scope = select_scope(
            ["lib/features/payments/domain/payments_repository.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted(
                {
                    "test/features/payments/data/in_memory_payments_repository_test.dart",
                    "test/features/payments/presentation/cubit/payments_cubit_test.dart",
                    *PAYMENTS_UI_TESTS,
                }
            ),
        )

    def test_payment_row_change_selects_all_screen_consumers(self):
        scope = select_scope(
            ["lib/features/payments/presentation/widgets/payment_row.dart"],
            ROOT,
        )

        self.assertEqual(scope["flutter_tests"], sorted(PAYMENTS_UI_TESTS))
        self.assertFalse(scope["hook_tests"])


if __name__ == "__main__":
    unittest.main()
