"""Explicit local test impact rules; unknown inputs fall back to the full suite."""

from pathlib import Path


# Include every consumer test, not just a same-named unit test. Extend this map
# alongside each vertical slice; CI remains the full-suite safety net.
FLUTTER_TESTS = {
    "lib/app/di/configure_dependencies.dart": [
        "test/app/bootstrap_test.dart",
    ],
    "lib/app/di/configure_dependencies.config.dart": [
        "test/app/bootstrap_test.dart",
    ],
    "lib/app/di/mock_backend_module.dart": [
        "test/app/bootstrap_test.dart",
    ],
    "lib/common/data/payments/data_sources/payments_remote_data_source.dart": [
        "test/common/data/payments/payments_repository_test.dart",
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/mock_backend/payments/mock_payments_backend.dart": [
        "test/mock_backend/payments/mock_payments_backend_test.dart",
        "test/common/data/payments/payments_repository_test.dart",
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/mock_backend/payments/payments_backend_client.dart": [
        "test/app/bootstrap_test.dart",
        "test/mock_backend/payments/mock_payments_backend_test.dart",
        "test/common/data/payments/payments_repository_test.dart",
    ],
    "lib/mock_backend/payments/payments_backend_exception.dart": [
        "test/mock_backend/payments/mock_payments_backend_test.dart",
        "test/common/data/payments/payments_repository_test.dart",
    ],
    "lib/common/data/payments/dtos/payment_dto.dart": [
        "test/common/data/payments/models/payment_serialization_test.dart",
        "test/common/data/payments/payments_repository_test.dart",
    ],
    "lib/common/data/payments/converters/payment_amount_json_converter.dart": [
        "test/common/data/payments/models/payment_serialization_test.dart",
    ],
    "lib/common/converters/utc_datetime_json_converter.dart": [
        "test/common/data/payments/models/payment_serialization_test.dart",
    ],
    "lib/common/data/payments/models/payment.dart": [
        "test/common/data/payments/models/payment_serialization_test.dart",
        "test/common/data/payments/models/payment_test.dart",
        "test/common/data/payments/payments_repository_test.dart",
        "test/common/data/payments/models/payments_collection_test.dart",
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/common/data/payments/models/payments_collection.dart": [
        "test/common/data/payments/models/payments_collection_test.dart",
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/common/data/payments/models/payment_mutation.dart": [
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/common/data/payments/models/payment_summary.dart": [
        "test/common/data/payments/models/payments_collection_test.dart",
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/common/error_handling/payments_failure.dart": [
        "test/common/data/payments/models/payment_serialization_test.dart",
        "test/common/data/payments/models/payment_test.dart",
        "test/common/data/payments/payments_repository_test.dart",
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/common/result/models/result.dart": [
        "test/common/result/models/result_test.dart",
        "test/common/data/payments/models/payment_serialization_test.dart",
        "test/common/data/payments/payments_repository_test.dart",
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/common/result/models/unit.dart": [
        "test/common/result/models/result_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/common/data/payments/payments_repository.dart": [
        "test/common/data/payments/payments_repository_test.dart",
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/common/data/payments/use_cases/create_payment_request_use_case.dart": [
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/common/data/payments/use_cases/decide_payment_use_case.dart": [
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/common/data/payments/use_cases/load_payments_use_case.dart": [
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/common/data/payments/use_cases/refresh_payments_use_case.dart": [
        "test/app/bootstrap_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/features/payments/states/payments/payments_cubit.dart": [
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/features/payments/states/payments/payments_state.dart": [
        "test/features/payments/states/payments/payments_cubit_test.dart",
    ],
    "lib/features/payments/pages/foundation_page.dart": [
        "test/app/app_failure_view_test.dart",
        "test/app/app_test.dart",
        "test/app/app_theme_test.dart",
    ],
}

for generated, source in {
    "lib/common/data/payments/models/payment.freezed.dart":
        "lib/common/data/payments/models/payment.dart",
    "lib/common/data/payments/dtos/payment_dto.freezed.dart":
        "lib/common/data/payments/dtos/payment_dto.dart",
    "lib/common/data/payments/dtos/payment_dto.g.dart":
        "lib/common/data/payments/dtos/payment_dto.dart",
    "lib/common/data/payments/models/payment_mutation.freezed.dart":
        "lib/common/data/payments/models/payment_mutation.dart",
    "lib/common/data/payments/models/payment_summary.freezed.dart":
        "lib/common/data/payments/models/payment_summary.dart",
    "lib/common/data/payments/models/payments_collection.freezed.dart":
        "lib/common/data/payments/models/payments_collection.dart",
    "lib/common/error_handling/payments_failure.freezed.dart":
        "lib/common/error_handling/payments_failure.dart",
    "lib/common/result/models/result.freezed.dart":
        "lib/common/result/models/result.dart",
    "lib/common/result/models/unit.freezed.dart":
        "lib/common/result/models/unit.dart",
    "lib/features/payments/states/payments/payments_state.freezed.dart":
        "lib/features/payments/states/payments/payments_state.dart",
}.items():
    FLUTTER_TESTS[generated] = FLUTTER_TESTS[source]


def select_scope(changed, root=Path(".")):
    full = changed is None
    reasons = ["No trustworthy local comparison base; using the full suite."] if full else []
    targets = set()
    hook_tests = full
    format_paths = []
    for path in changed or []:
        if path.endswith(".dart") and (root / path).is_file():
            format_paths.append(path)
        if path.startswith(("tool/", ".githooks/")):
            hook_tests = True
        elif path.startswith(("docs/", ".ai/")) or path.endswith(".md"):
            continue
        elif path in (".gitignore", ".github/pull_request_template.md"):
            continue
        elif path in FLUTTER_TESTS and (root / path).is_file():
            mapped = FLUTTER_TESTS[path]
            if all((root / test).is_file() for test in mapped):
                targets.update(mapped)
            else:
                full = True
                reasons.append(f"Missing mapped test for {path}.")
        elif path.startswith("test/") and path.endswith("_test.dart") and (root / path).is_file():
            targets.add(path)
        else:
            full = True
            reasons.append(f"Shared configuration, deleted input, or unmapped dependency: {path}.")
    if not reasons:
        reasons.append("Tests selected from the explicit impact map and changed test files."
                       if targets else "No Flutter inputs changed; Flutter checks are not needed.")
    return {
        "flutter_tests": None if full else sorted(targets),
        "hook_tests": hook_tests,
        "format_paths": ["."] if changed is None else sorted(format_paths),
        "reasons": reasons,
    }
