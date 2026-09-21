import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/common/data/payments/models/payments_date_range.dart';
import 'package:mamo_approval/features/payments/formatters/payment_formatters.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_bloc.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_event.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// Decision-date window filter. Picks calendar days, which the formatter
/// turns into the account zone's UTC window before the bloc sees them.
class PaymentsDateFilterChip extends StatelessWidget {
  const PaymentsDateFilterChip({
    required this.formatters,
    required this.lastSelectableDay,
    super.key,
  });

  final PaymentFormatters formatters;

  /// Latest day offered by the picker (decisions never lie in the future).
  final DateTime lastSelectableDay;

  static final DateTime _firstSelectableDay = DateTime(2020);

  Future<void> _pick(BuildContext context, PaymentsDateRange? current) async {
    final PaymentsSearchBloc bloc = context.read<PaymentsSearchBloc>();
    final DateTimeRange<DateTime>? picked = await showDateRangePicker(
      context: context,
      firstDate: _firstSelectableDay,
      lastDate: lastSelectableDay,
      initialDateRange: current == null
          ? null
          : DateTimeRange<DateTime>(
              start: formatters.accountDay(current.startUtc),
              end: formatters.accountDay(
                current.endUtc.subtract(const Duration(days: 1)),
              ),
            ),
      helpText: AppLocalizations.of(context).paymentsSearchDateFilterHelp,
    );
    if (picked == null || bloc.isClosed) {
      return;
    }
    bloc.add(
      PaymentsSearchEvent.dateRangeChanged(
        formatters.accountDays(picked.start, picked.end),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final PaymentsDateRange? selected = context.select(
      (PaymentsSearchBloc bloc) => bloc.state.criteria.dateRange,
    );
    return Semantics(
      identifier: 'payments.search.filter.date',
      child: FilterChip(
        avatar: const Icon(Icons.date_range_outlined),
        label: Text(
          selected == null
              ? l10n.paymentsSearchDateFilterLabel
              : formatters.dateRange(selected),
        ),
        selected: selected != null,
        showCheckmark: false,
        onSelected: (bool _) => unawaited(_pick(context, selected)),
        deleteIcon: const Icon(Icons.close),
        deleteButtonTooltipMessage: l10n.paymentsSearchDateFilterClearLabel,
        onDeleted: selected == null
            ? null
            : () => context.read<PaymentsSearchBloc>().add(
                const PaymentsSearchEvent.dateRangeChanged(null),
              ),
      ),
    );
  }
}
