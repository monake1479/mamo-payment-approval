import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/common/data/payments/models/payments_sort.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_bloc.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_event.dart';
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
      child: PopupMenuButton<PaymentsSort>(
        tooltip: l10n.paymentsSearchSortLabel,
        // The menu route must not land in the Home/Payments branch navigator,
        // which lives inside the horizontal pager and would scroll to it.
        useRootNavigator: true,
        initialValue: selected,
        onSelected: (PaymentsSort sort) => context
            .read<PaymentsSearchBloc>()
            .add(PaymentsSearchEvent.sortChanged(sort)),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<PaymentsSort>>[
          for (final PaymentsSort option in _options)
            PopupMenuItem<PaymentsSort>(
              value: option,
              child: Semantics(
                identifier: identifier(option),
                child: Text(label(option, l10n)),
              ),
            ),
        ],
        child: Chip(
          avatar: const Icon(Icons.sort),
          label: Text(label(selected, l10n)),
        ),
      ),
    );
  }
}
