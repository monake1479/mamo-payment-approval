"""Explicit local test impact rules; unknown inputs fall back to the full suite."""

from pathlib import Path


# Include every consumer test, not just a same-named unit test. Extend this map
# alongside each vertical slice; CI remains the full-suite safety net.
PAYMENTS_UI_TESTS = [
    "test/app/app_test.dart",
    "test/app/app_theme_test.dart",
    "test/app/bootstrap_test.dart",
    "test/app/payment_navigation_shell_test.dart",
    "test/features/payments/formatters/payment_formatters_test.dart",
    "test/features/payments/pages/home_page_test.dart",
    "test/features/payments/pages/payment_details_page_test.dart",
    "test/features/payments/pages/payments_page_test.dart",
    "test/features/payments/widgets/payment_row_test.dart",
    "test/features/payments/widgets/payment_state_views_test.dart",
]

DEVICE_AUTH_TESTS = [
    "test/common/data/device_authentication/local_auth_client_test.dart",
    "test/common/data/device_authentication/local_auth_repository_test.dart",
    "test/common/data/device_authentication/use_cases/is_local_auth_supported_use_case_test.dart",
    "test/common/data/device_authentication/use_cases/local_authentication_use_case_test.dart",
    "test/common/data/device_authentication/use_cases/stop_local_authentication_use_case_test.dart",
]

# The decided-history search slice: its event-driven bloc feeds the Payments
# page, and the router provides the bloc, so shell/app tests run as well.
SEARCH_TESTS = [
    "test/features/payments/states/search/payments_search_bloc_test.dart",
    "test/common/data/payments/use_cases/search_payments_use_case_test.dart",
]

# Search results cross the same data-source boundary as loads; changes to that
# boundary or to the search contract also run the data-source unit tests.
PAYMENTS_DATA_SOURCE_TESTS = [
    "test/common/data/payments/data_sources/payments_remote_data_source_test.dart",
    "test/common/data/payments/payments_repository_test.dart",
]

# The incoming-approval and draggable debug-action flow. These consume the
# accepted payments and device-authentication use cases; changes to the shared
# app shell or to those use cases also exercise the approval journey.
APPROVAL_TESTS = [
    "test/app/approval_flow_test.dart",
    "test/features/payments/states/approval/approval_cubit_test.dart",
]

FLUTTER_TESTS = {
    "lib/common/data/device_authentication/data_sources/local_auth_client.dart": [
        "test/app/bootstrap_test.dart",
        *DEVICE_AUTH_TESTS,
    ],
    "test/support/device_authentication_test_support.dart": [
        "test/app/bootstrap_test.dart",
        *DEVICE_AUTH_TESTS,
    ],
    "lib/common/data/device_authentication/local_auth_repository.dart": [
        "test/app/bootstrap_test.dart",
        *DEVICE_AUTH_TESTS,
    ],
    "lib/common/data/device_authentication/use_cases/is_local_auth_supported_use_case.dart": [
        "test/app/bootstrap_test.dart",
        "test/common/data/device_authentication/use_cases/is_local_auth_supported_use_case_test.dart",
    ],
    "lib/common/data/device_authentication/use_cases/local_authentication_use_case.dart": [
        "test/app/bootstrap_test.dart",
        "test/common/data/device_authentication/use_cases/local_authentication_use_case_test.dart",
    ],
    "lib/common/data/device_authentication/use_cases/stop_local_authentication_use_case.dart": [
        "test/app/bootstrap_test.dart",
        "test/common/data/device_authentication/use_cases/stop_local_authentication_use_case_test.dart",
    ],
    "lib/common/data/device_authentication/models/device_authentication_cancellation_result.dart": [
        "test/common/data/device_authentication/local_auth_client_test.dart",
        "test/common/data/device_authentication/local_auth_repository_test.dart",
        "test/common/data/device_authentication/use_cases/stop_local_authentication_use_case_test.dart",
    ],
    "lib/common/data/device_authentication/error_handling/device_authentication_failure.dart": [
        "test/common/data/device_authentication/local_auth_client_test.dart",
        "test/common/data/device_authentication/local_auth_repository_test.dart",
        "test/common/data/device_authentication/use_cases/local_authentication_use_case_test.dart",
    ],
    "lib/app/di/device_authentication_module.dart": [
        "test/app/bootstrap_test.dart",
    ],
    "lib/app/di/mock_backend_module.dart": [
        "test/app/bootstrap_test.dart",
    ],
    "lib/common/data/payments/data_sources/payments_remote_data_source.dart": [
        *PAYMENTS_DATA_SOURCE_TESTS,
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *SEARCH_TESTS,
        *PAYMENTS_UI_TESTS,
    ],
    "lib/mock_backend/payments/mock_payments_backend.dart": [
        "test/mock_backend/payments/mock_payments_backend_test.dart",
        "test/common/data/payments/payments_repository_test.dart",
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/mock_backend/payments/payments_backend_client.dart": [
        "test/app/bootstrap_test.dart",
        "test/mock_backend/payments/mock_payments_backend_test.dart",
        *PAYMENTS_DATA_SOURCE_TESTS,
        *PAYMENTS_UI_TESTS,
    ],
    "lib/mock_backend/payments/payments_backend_exception.dart": [
        "test/mock_backend/payments/mock_payments_backend_test.dart",
        *PAYMENTS_DATA_SOURCE_TESTS,
        *PAYMENTS_UI_TESTS,
    ],
    "lib/common/data/payments/dtos/payment_dto.dart": [
        "test/common/data/payments/models/payment_serialization_test.dart",
        *PAYMENTS_DATA_SOURCE_TESTS,
        *PAYMENTS_UI_TESTS,
    ],
    "lib/common/data/payments/converters/payment_amount_json_converter.dart": [
        "test/common/data/payments/models/payment_serialization_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/common/converters/utc_datetime_json_converter.dart": [
        "test/common/data/payments/models/payment_serialization_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/common/data/payments/models/payment.dart": [
        "test/common/data/payments/models/payment_serialization_test.dart",
        "test/common/data/payments/models/payment_test.dart",
        *PAYMENTS_DATA_SOURCE_TESTS,
        "test/common/data/payments/models/payments_collection_test.dart",
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *SEARCH_TESTS,
        *PAYMENTS_UI_TESTS,
        *APPROVAL_TESTS,
    ],
            "lib/common/data/payments/models/payments_date_range.dart": [
        *PAYMENTS_DATA_SOURCE_TESTS,
        "test/features/payments/formatters/payment_formatters_test.dart",
        *SEARCH_TESTS,
        *PAYMENTS_UI_TESTS,
        *APPROVAL_TESTS,
    ],
    "lib/common/data/payments/models/payments_search_criteria.dart": [
        *PAYMENTS_DATA_SOURCE_TESTS,
        *SEARCH_TESTS,
        *PAYMENTS_UI_TESTS,
        *APPROVAL_TESTS,
    ],
    "lib/common/data/payments/models/payments_sort.dart": [
        *PAYMENTS_DATA_SOURCE_TESTS,
        "test/mock_backend/payments/mock_payments_backend_test.dart",
        *SEARCH_TESTS,
        *PAYMENTS_UI_TESTS,
        *APPROVAL_TESTS,
    ],
    "lib/common/data/payments/models/payments_collection.dart": [
        "test/common/data/payments/models/payments_collection_test.dart",
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/common/data/payments/models/payment_mutation.dart": [
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/common/data/payments/models/payment_summary.dart": [
        "test/common/data/payments/models/payments_collection_test.dart",
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/common/data/payments/error_handling/payments_failure.dart": [
        "test/common/data/payments/models/payment_serialization_test.dart",
        "test/common/data/payments/models/payment_test.dart",
        *PAYMENTS_DATA_SOURCE_TESTS,
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *SEARCH_TESTS,
        *PAYMENTS_UI_TESTS,
        *APPROVAL_TESTS,
    ],
    "lib/common/result/models/result.dart": [
        "test/common/result/models/result_test.dart",
        "test/common/data/payments/models/payment_serialization_test.dart",
        *PAYMENTS_DATA_SOURCE_TESTS,
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *SEARCH_TESTS,
        *PAYMENTS_UI_TESTS,
    ],
    "lib/common/result/models/unit.dart": [
        "test/common/result/models/result_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/common/data/payments/payments_repository.dart": [
        "test/common/data/payments/payments_repository_test.dart",
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *SEARCH_TESTS,
        *PAYMENTS_UI_TESTS,
        *APPROVAL_TESTS,
    ],
    "lib/common/data/payments/use_cases/search_payments_use_case.dart": [
        "test/app/bootstrap_test.dart",
        *SEARCH_TESTS,
        *PAYMENTS_UI_TESTS,
        *APPROVAL_TESTS,
    ],
    "lib/common/data/payments/use_cases/create_payment_request_use_case.dart": [
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/common/data/payments/use_cases/decide_payment_use_case.dart": [
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
        *APPROVAL_TESTS,
    ],
    "lib/common/data/payments/use_cases/load_payments_use_case.dart": [
        "test/common/data/payments/use_cases/payment_use_cases_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/common/data/payments/use_cases/refresh_payments_use_case.dart": [
        "test/app/bootstrap_test.dart",
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/features/payments/states/payments/payments_cubit.dart": [
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/features/payments/states/payments/payments_state.dart": [
        "test/features/payments/states/payments/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/features/payments/states/search/payments_search_bloc.dart": [
        "test/features/payments/states/search/payments_search_bloc_test.dart",
        *PAYMENTS_UI_TESTS,
        *APPROVAL_TESTS,
    ],
    "lib/features/payments/states/search/payments_search_event.dart": [
        "test/features/payments/states/search/payments_search_bloc_test.dart",
        *PAYMENTS_UI_TESTS,
        *APPROVAL_TESTS,
    ],
    "lib/features/payments/states/search/payments_search_state.dart": [
        "test/features/payments/states/search/payments_search_bloc_test.dart",
        *PAYMENTS_UI_TESTS,
        *APPROVAL_TESTS,
    ],
        "lib/features/payments/widgets/payments_search_field.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
    "lib/features/payments/widgets/payment_status_filter_menu.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
        "lib/features/payments/widgets/payments_search_controls.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
    "lib/features/payments/widgets/payments_date_filter_chip.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
    "lib/features/payments/widgets/payments_sort_menu.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
    "lib/features/payments/widgets/payments_list.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
    "lib/features/payments/views/payments_history_view.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
    "lib/features/payments/views/payments_search_results_view.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
    "lib/features/payments/views/payments_search_empty_view.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
    "lib/features/payments/views/payments_search_error_view.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
    "lib/features/payments/views/payments_search_loading_view.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
    "lib/features/payments/states/approval/approval_cubit.dart": APPROVAL_TESTS,
    "lib/features/payments/states/approval/approval_state.dart": APPROVAL_TESTS,
    "lib/features/payments/states/approval/approval_failure.dart": APPROVAL_TESTS,
    "lib/features/payments/states/debug_action/debug_action_cubit.dart": APPROVAL_TESTS,
    "lib/features/payments/states/debug_action/debug_action_state.dart": APPROVAL_TESTS,
    "lib/app/payment_flow_layer.dart": APPROVAL_TESTS,
    "lib/features/payments/widgets/approval_overlay.dart": APPROVAL_TESTS,
    "lib/features/payments/widgets/debug_payment_action.dart": APPROVAL_TESTS,
    "lib/app/app.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
    "lib/app/bootstrap.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
    "lib/app/di/configure_dependencies.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
    "lib/app/di/configure_dependencies.config.dart": [
        "test/app/bootstrap_test.dart",
    ],
    "lib/app/navigation/app_router.dart": [*PAYMENTS_UI_TESTS, *APPROVAL_TESTS],
    "lib/app/navigation/payment_navigation_shell.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/payment_status_presentation.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/formatters/payment_formatters.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/pages/home_page.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/pages/payment_details_page.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/pages/payments_page.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/widgets/monthly_summary_card.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/widgets/payment_detail_field.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/widgets/payment_page_scaffold.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/widgets/payment_row.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/widgets/payment_state_views.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/widgets/payment_status_chip.dart": [
        *PAYMENTS_UI_TESTS,
        "test/features/payments/widgets/payment_status_chip_test.dart",
    ],
    "lib/features/payments/widgets/recent_payments_section.dart": PAYMENTS_UI_TESTS,
}

for generated, source in {
    "lib/common/data/device_authentication/error_handling/device_authentication_failure.freezed.dart":
        "lib/common/data/device_authentication/error_handling/device_authentication_failure.dart",
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
    "lib/common/data/payments/error_handling/payments_failure.freezed.dart":
        "lib/common/data/payments/error_handling/payments_failure.dart",
    "lib/common/result/models/result.freezed.dart":
        "lib/common/result/models/result.dart",
    "lib/common/result/models/unit.freezed.dart":
        "lib/common/result/models/unit.dart",
    "lib/features/payments/states/payments/payments_state.freezed.dart":
        "lib/features/payments/states/payments/payments_state.dart",
    "lib/features/payments/states/search/payments_search_state.freezed.dart":
        "lib/features/payments/states/search/payments_search_state.dart",
        "lib/features/payments/states/search/payments_search_event.freezed.dart":
        "lib/features/payments/states/search/payments_search_event.dart",
        "lib/common/data/payments/models/payments_sort.freezed.dart":
        "lib/common/data/payments/models/payments_sort.dart",
    "lib/common/data/payments/models/payments_date_range.freezed.dart":
        "lib/common/data/payments/models/payments_date_range.dart",
    "lib/common/data/payments/models/payments_search_criteria.freezed.dart":
        "lib/common/data/payments/models/payments_search_criteria.dart",
    "lib/features/payments/states/approval/approval_state.freezed.dart":
        "lib/features/payments/states/approval/approval_state.dart",
    "lib/features/payments/states/approval/approval_failure.freezed.dart":
        "lib/features/payments/states/approval/approval_failure.dart",
    "lib/features/payments/states/debug_action/debug_action_state.freezed.dart":
        "lib/features/payments/states/debug_action/debug_action_state.dart",
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
