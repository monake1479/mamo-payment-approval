import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/features/payments/formatters/payment_formatters.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_bloc.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_event.dart';
import 'package:mamo_approval/features/payments/widgets/payment_status_filter_menu.dart';
import 'package:mamo_approval/features/payments/widgets/payments_date_filter_chip.dart';
import 'package:mamo_approval/features/payments/widgets/payments_search_field.dart';
import 'package:mamo_approval/features/payments/widgets/payments_sort_menu.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// The search field, then the status, date, and sort controls in a wrapping
/// row, followed by a clear action whenever a filter or a non-default order is
/// set (the search text has its own clear icon).
class PaymentsSearchControls extends StatelessWidget {
  const PaymentsSearchControls({
    required this.formatters,
    required this.lastSelectableDay,
    super.key,
  });

  final PaymentFormatters formatters;
  final DateTime lastSelectableDay;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool hasFilters = context.select(
      (PaymentsSearchBloc bloc) => bloc.state.criteria.hasFilters,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const PaymentsSearchField(),
        const SizedBox(height: AppTheme.smallGap),
        Wrap(
          spacing: AppTheme.smallGap,
          runSpacing: AppTheme.smallGap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            const PaymentStatusFilterMenu(),
            PaymentsDateFilterChip(
              formatters: formatters,
              lastSelectableDay: lastSelectableDay,
            ),
            const PaymentsSortMenu(),
            if (hasFilters)
              Semantics(
                identifier: 'payments.search.clear',
                child: TextButton.icon(
                  onPressed: () => context.read<PaymentsSearchBloc>().add(
                    const PaymentsSearchEvent.filtersCleared(),
                  ),
                  icon: const Icon(Icons.clear),
                  label: Text(l10n.paymentsSearchClearFiltersLabel),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
