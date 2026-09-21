import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/app/theme/app_motion.dart';
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateTimeRange<DateTime>? initialRange = current == null
        ? null
        : DateTimeRange<DateTime>(
            start: formatters.accountDay(current.startUtc),
            end: formatters.accountDay(
              current.endUtc.subtract(const Duration(days: 1)),
            ),
          );
    // The stock picker route only fades in, which reads as an abrupt pop on
    // the full-screen compact layout; slide the whole picker up from the
    // bottom instead, on the root navigator above the Home/Payments pager.
    final DateTimeRange<DateTime>? picked =
        await showGeneralDialog<DateTimeRange<DateTime>>(
          context: context,
          barrierDismissible: true,
          barrierLabel: l10n.paymentsSearchDateFilterHelp,
          barrierColor: Theme.of(context).colorScheme.scrim
              .withValues(alpha: 0.4),
          transitionDuration: AppMotion.resolve(context, AppMotion.slow),
          transitionBuilder: _entrance,
          pageBuilder:
              (
                BuildContext context,
                Animation<double> _,
                Animation<double> _,
              ) => DateRangePickerDialog(
                firstDate: _firstSelectableDay,
                lastDate: lastSelectableDay,
                initialDateRange: initialRange,
                helpText: l10n.paymentsSearchDateFilterHelp,
              ),
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

  /// Full-height rise from the bottom edge on entry, the reverse on exit; the
  /// barrier fades underneath through the dialog route itself.
  static Widget _entrance(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: animation,
              curve: AppMotion.enterCurve,
              reverseCurve: AppMotion.exitCurve,
            ),
          ),
      child: child,
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
