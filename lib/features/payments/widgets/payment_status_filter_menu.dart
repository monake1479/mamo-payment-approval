import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_bloc.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_event.dart';
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
      child: PopupMenuButton<StatusFilterOption>(
        tooltip: l10n.paymentsSearchFiltersLabel,
        // The menu route must not land in the Home/Payments branch navigator,
        // which lives inside the horizontal pager and would scroll to it.
        useRootNavigator: true,
        initialValue: current,
        onSelected: (StatusFilterOption option) => context
            .read<PaymentsSearchBloc>()
            .add(PaymentsSearchEvent.statusFilterChanged(option.statuses)),
        itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<StatusFilterOption>>[
              for (final StatusFilterOption option in StatusFilterOption.values)
                PopupMenuItem<StatusFilterOption>(
                  value: option,
                  child: Semantics(
                    identifier: identifier(option),
                    child: Text(label(option)),
                  ),
                ),
            ],
        child: _DropdownChip(
          icon: switch (current) {
            StatusFilterOption.all => Icons.filter_list,
            StatusFilterOption.approved => Icons.check_circle_outline,
            StatusFilterOption.rejected => Icons.cancel_outlined,
          },
          label: label(current),
          selected: current != StatusFilterOption.all,
        ),
      ),
    );
  }
}

/// Menu entries. A non-null value is required because a popup menu reports a
/// `null` selection as a dismissal.
enum StatusFilterOption {
  all(<PaymentStatus>{}),
  approved(<PaymentStatus>{PaymentStatus.approved}),
  rejected(<PaymentStatus>{PaymentStatus.rejected});

  const StatusFilterOption(this.statuses);

  /// The criteria value the option stands for; empty means every status.
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

/// A chip that looks selectable and shows it opens a menu.
class _DropdownChip extends StatelessWidget {
  const _DropdownChip({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(icon),
      label: Text(label),
      // The trailing arrow only signals the menu; the chip itself opens it.
      deleteIcon: const Icon(Icons.arrow_drop_down),
      backgroundColor: selected ? colors.primaryContainer : null,
    );
  }
}
