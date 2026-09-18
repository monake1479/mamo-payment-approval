from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tool"))
from test_scope import AUTHENTICATION_TESTS, PAYMENTS_UI_TESTS, select_scope


def with_ui(*tests):
    return sorted({*tests, *PAYMENTS_UI_TESTS})


class PaymentsScopeTest(unittest.TestCase):
    def test_collection_cubit_change_selects_state_and_ui_consumers(self):
        scope = select_scope(
            ["lib/features/payments/states/payments/payments_cubit.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            sorted(
                {
                    "test/features/payments/states/payments/payments_cubit_test.dart",
                    *PAYMENTS_UI_TESTS,
                }
            ),
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

    def test_repository_change_selects_data_and_state_consumers(self):
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

    def test_approval_state_selects_approval_and_flow_consumers(self):
        scope = select_scope(
            ["lib/features/payments/states/approval/approval_state.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            [
                "test/app/approval_flow_test.dart",
                "test/features/payments/states/approval/approval_cubit_test.dart",
            ],
        )

    def test_authentication_contract_selects_adapter_and_approval_consumers(self):
        scope = select_scope(
            ["lib/common/data/device_authentication/device_authenticator.dart"],
            ROOT,
        )

        self.assertEqual(scope["flutter_tests"], sorted(set(AUTHENTICATION_TESTS)))

    def test_generated_approval_state_maps_to_authored_source(self):
        scope = select_scope(
            ["lib/features/payments/states/approval/approval_state.freezed.dart"],
            ROOT,
        )

        self.assertEqual(
            scope["flutter_tests"],
            [
                "test/app/approval_flow_test.dart",
                "test/features/payments/states/approval/approval_cubit_test.dart",
            ],
        )


if __name__ == "__main__":
    unittest.main()
