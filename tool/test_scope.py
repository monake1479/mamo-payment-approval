"""Explicit local test impact rules; unknown inputs fall back to the full suite."""

from pathlib import Path


# Include every consumer test, not just a same-named unit test. Extend this map
# alongside each vertical slice; CI remains the full-suite safety net.
PAYMENTS_UI_TESTS = [
    "test/app/app_test.dart",
    "test/app/app_theme_test.dart",
    "test/app/bootstrap_test.dart",
    "test/app/payment_navigation_shell_test.dart",
    "test/features/payments/presentation/formatters/payment_formatters_test.dart",
    "test/features/payments/presentation/pages/home_page_test.dart",
    "test/features/payments/presentation/pages/payment_details_page_test.dart",
    "test/features/payments/presentation/pages/payments_page_test.dart",
    "test/features/payments/presentation/widgets/payment_row_test.dart",
    "test/features/payments/presentation/widgets/payment_state_views_test.dart",
]

FLUTTER_TESTS = {
    "lib/app/app.dart": PAYMENTS_UI_TESTS,
    "lib/app/bootstrap.dart": PAYMENTS_UI_TESTS,
    "lib/app/di/configure_dependencies.dart": PAYMENTS_UI_TESTS,
    "lib/app/navigation/app_router.dart": PAYMENTS_UI_TESTS,
    "lib/app/navigation/payment_navigation_shell.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/data/in_memory_payments_repository.dart": [
        "test/features/payments/data/in_memory_payments_repository_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/features/payments/data/payment_record_codec.dart": [
        "test/features/payments/data/in_memory_payments_repository_test.dart",
        "test/features/payments/data/payment_record_codec_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/features/payments/domain/payment.dart": [
        "test/features/payments/data/in_memory_payments_repository_test.dart",
        "test/features/payments/data/payment_record_codec_test.dart",
        "test/features/payments/domain/payment_test.dart",
        "test/features/payments/domain/payment_operations_test.dart",
        "test/features/payments/presentation/cubit/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/features/payments/domain/payment_money.dart": [
        "test/features/payments/data/in_memory_payments_repository_test.dart",
        "test/features/payments/data/payment_record_codec_test.dart",
        "test/features/payments/domain/payment_money_test.dart",
        "test/features/payments/domain/payment_operations_test.dart",
        "test/features/payments/domain/payment_test.dart",
        "test/features/payments/presentation/cubit/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/features/payments/domain/payment_operations.dart": [
        "test/features/payments/domain/payment_operations_test.dart",
        "test/features/payments/presentation/cubit/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/features/payments/domain/payments_failure.dart": [
        "test/features/payments/data/in_memory_payments_repository_test.dart",
        "test/features/payments/data/payment_record_codec_test.dart",
        "test/features/payments/domain/payment_money_test.dart",
        "test/features/payments/domain/payment_operations_test.dart",
        "test/features/payments/domain/payment_test.dart",
        "test/features/payments/presentation/cubit/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/features/payments/domain/payments_repository.dart": [
        "test/features/payments/data/in_memory_payments_repository_test.dart",
        "test/features/payments/presentation/cubit/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/features/payments/domain/payments_result.dart": [
        "test/features/payments/data/in_memory_payments_repository_test.dart",
        "test/features/payments/data/payment_record_codec_test.dart",
        "test/features/payments/domain/payment_money_test.dart",
        "test/features/payments/domain/payment_operations_test.dart",
        "test/features/payments/presentation/cubit/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/features/payments/presentation/cubit/payments_cubit.dart": [
        "test/features/payments/presentation/cubit/payments_cubit_test.dart",
        *PAYMENTS_UI_TESTS,
    ],
    "lib/features/payments/presentation/formatters/payment_formatters.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/presentation/pages/home_page.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/presentation/pages/payment_details_page.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/presentation/pages/payments_page.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/presentation/widgets/monthly_summary_card.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/presentation/widgets/payment_detail_field.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/presentation/widgets/payment_page_scaffold.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/presentation/widgets/payment_row.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/presentation/widgets/payment_state_views.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/presentation/widgets/payment_status_badge.dart": PAYMENTS_UI_TESTS,
    "lib/features/payments/presentation/widgets/recent_payments_section.dart": PAYMENTS_UI_TESTS,
}


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
