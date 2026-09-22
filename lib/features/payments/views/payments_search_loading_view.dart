import 'package:flutter/material.dart';
import 'package:mamo_approval/features/payments/widgets/payment_state_views.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// Labelled progress while a history search is running.
class PaymentsSearchLoadingView extends StatelessWidget {
  const PaymentsSearchLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return PaymentsLoadingView(
      identifier: 'payments.search.loading',
      label: AppLocalizations.of(context).paymentsSearchLoadingLabel,
    );
  }
}
