import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_bloc.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_event.dart';
import 'package:mamo_approval/features/payments/widgets/payments_dropdown_chip.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// Decided-status filter as one dropdown chip: every status, approved only,
/// or rejected only. The history never contains the pending request, so it
/// is not offered.
class PaymentStatusFilterMenu extends StatelessWidget {
  const PaymentStatusFilterMenu({super.key});

  static String identifier(StatusFilterOption option) =>
      'payments.search.filter.status.${option.name}';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final StatusFilterOption current = context.select(
      (PaymentsSearchBloc bloc) =>
          StatusFilterOption.fromStatuses(bloc.state.criteria.statuses),
    );
    String label(StatusFilterOption option) => switch (option) {
      StatusFilterOption.all => l10n.paymentsSearchStatusAll,
      StatusFilterOption.approved => l10n.paymentStatusApproved,
      StatusFilterOption.rejected => l10n.paymentStatusRejected,
    };
    return Semantics(
      identifier: 'payments.search.filter.status',
      child: PaymentsDropdownChip<StatusFilterOption>(
        icon: switch (current) {
          StatusFilterOption.all => Icons.filter_list,
          StatusFilterOption.approved => Icons.check_circle_outline,
          StatusFilterOption.rejected => Icons.cancel_outlined,
        },
        label: label(current),
        selected: current != StatusFilterOption.all,
        tooltip: l10n.paymentsSearchFiltersLabel,
        options: <PaymentsDropdownOption<StatusFilterOption>>[
          for (final StatusFilterOption option in StatusFilterOption.values)
            PaymentsDropdownOption<StatusFilterOption>(
              value: option,
              label: label(option),
              identifier: identifier(option),
            ),
        ],
        onSelected: (StatusFilterOption option) => context
            .read<PaymentsSearchBloc>()
            .add(PaymentsSearchEvent.statusFilterChanged(option.statuses)),
      ),
    );
  }
}

/// Menu entries; each stands for one criteria value (empty means every
/// status).
enum StatusFilterOption {
  all(<PaymentStatus>{}),
  approved(<PaymentStatus>{PaymentStatus.approved}),
  rejected(<PaymentStatus>{PaymentStatus.rejected});

  const StatusFilterOption(this.statuses);

  final Set<PaymentStatus> statuses;

  static StatusFilterOption fromStatuses(Set<PaymentStatus> statuses) {
    if (statuses.length != 1) {
      return StatusFilterOption.all;
    }
    return switch (statuses.first) {
      PaymentStatus.approved => StatusFilterOption.approved,
      PaymentStatus.rejected => StatusFilterOption.rejected,
      PaymentStatus.pending => StatusFilterOption.all,
    };
  }
}
