import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_bloc.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_event.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// Decided-status filter chips. Only approved and rejected are offered because
/// the history never contains the pending request.
class PaymentStatusFilterChips extends StatelessWidget {
  const PaymentStatusFilterChips({super.key});

  static const List<PaymentStatus> _filterableStatuses = <PaymentStatus>[
    PaymentStatus.approved,
    PaymentStatus.rejected,
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Set<PaymentStatus> selected = context.select(
      (PaymentsSearchBloc bloc) => bloc.state.statuses,
    );
    return Semantics(
      identifier: 'payments.search.filters',
      label: l10n.paymentsSearchFiltersLabel,
      container: true,
      explicitChildNodes: true,
      child: Wrap(
        spacing: AppTheme.smallGap,
        runSpacing: AppTheme.smallGap,
        children: <Widget>[
          for (final PaymentStatus status in _filterableStatuses)
            _StatusFilterChip(
              status: status,
              selected: selected.contains(status),
              onSelected: (bool isSelected) {
                final Set<PaymentStatus> next = <PaymentStatus>{...selected};
                if (isSelected) {
                  next.add(status);
                } else {
                  next.remove(status);
                }
                context.read<PaymentsSearchBloc>().add(
                  PaymentsSearchEvent.statusFilterChanged(next),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.status,
    required this.selected,
    required this.onSelected,
  });

  final PaymentStatus status;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final (String label, IconData icon) = switch (status) {
      PaymentStatus.approved => (
        l10n.paymentStatusApproved,
        Icons.check_circle_outline,
      ),
      PaymentStatus.rejected => (
        l10n.paymentStatusRejected,
        Icons.cancel_outlined,
      ),
      PaymentStatus.pending => (
        l10n.paymentStatusPending,
        Icons.schedule_outlined,
      ),
    };
    return Semantics(
      identifier: 'payments.search.filter.${status.name}',
      child: FilterChip(
        avatar: Icon(icon),
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: onSelected,
      ),
    );
  }
}
