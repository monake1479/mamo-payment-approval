import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_bloc.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_event.dart';
import 'package:mamo_approval/features/payments/widgets/payment_state_views.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// A typed search failure with a retry that re-runs the current criteria.
class PaymentsSearchErrorView extends StatelessWidget {
  const PaymentsSearchErrorView({required this.failure, super.key});

  final PaymentsFailure failure;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return PaymentsErrorView(
      identifier: 'payments.search.error',
      failure: failure,
      title: l10n.paymentsSearchErrorTitle,
      description: failure.searchMessage(l10n),
      scrollable: false,
      onRetry: () => context.read<PaymentsSearchBloc>().add(
        const PaymentsSearchEvent.refreshRequested(),
      ),
    );
  }
}
