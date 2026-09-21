import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/common/data/payments/models/payments_sort.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_bloc.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_event.dart';
import 'package:mamo_approval/features/payments/widgets/payments_dropdown_chip.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// Picks the order the backend returns decided payments in.
class PaymentsSortMenu extends StatelessWidget {
  const PaymentsSortMenu({super.key});

  static const List<PaymentsSort> _options = <PaymentsSort>[
    PaymentsSort.decidedAtNewestFirst,
    PaymentsSort(
      field: PaymentsSortField.decidedAt,
      direction: SortDirection.ascending,
    ),
    PaymentsSort(
      field: PaymentsSortField.amount,
      direction: SortDirection.descending,
    ),
    PaymentsSort(
      field: PaymentsSortField.amount,
      direction: SortDirection.ascending,
    ),
    PaymentsSort(
      field: PaymentsSortField.counterparty,
      direction: SortDirection.ascending,
    ),
  ];

  static String label(PaymentsSort sort, AppLocalizations l10n) {
    return switch ((sort.field, sort.direction)) {
      (PaymentsSortField.decidedAt, SortDirection.descending) =>
        l10n.paymentsSortNewestFirst,
      (PaymentsSortField.decidedAt, SortDirection.ascending) =>
        l10n.paymentsSortOldestFirst,
      (PaymentsSortField.amount, SortDirection.descending) =>
        l10n.paymentsSortHighestAmount,
      (PaymentsSortField.amount, SortDirection.ascending) =>
        l10n.paymentsSortLowestAmount,
      (PaymentsSortField.counterparty, _) => l10n.paymentsSortCounterparty,
      (PaymentsSortField.createdAt, _) => l10n.paymentsSortNewestFirst,
    };
  }

  static String identifier(PaymentsSort sort) =>
      'payments.search.sort.${sort.field.name}.${sort.direction.name}';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final PaymentsSort selected = context.select(
      (PaymentsSearchBloc bloc) => bloc.state.criteria.sort,
    );
    return Semantics(
      identifier: 'payments.search.sort',
      child: PaymentsDropdownChip<PaymentsSort>(
        icon: Icons.sort,
        label: label(selected, l10n),
        selected: selected != PaymentsSort.decidedAtNewestFirst,
        tooltip: l10n.paymentsSearchSortLabel,
        options: <PaymentsDropdownOption<PaymentsSort>>[
          for (final PaymentsSort option in _options)
            PaymentsDropdownOption<PaymentsSort>(
              value: option,
              label: label(option, l10n),
              identifier: identifier(option),
            ),
        ],
        onSelected: (PaymentsSort sort) => context
            .read<PaymentsSearchBloc>()
            .add(PaymentsSearchEvent.sortChanged(sort)),
      ),
    );
  }
}
