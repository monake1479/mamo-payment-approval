import 'package:flutter/material.dart';
import 'package:mamo_approval/features/payments/widgets/payment_state_views.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// No decided payment matches the current query and status filters.
class PaymentsSearchEmptyView extends StatelessWidget {
  const PaymentsSearchEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return PaymentsEmptyView(
      identifier: 'payments.search.empty',
      title: l10n.paymentsSearchEmptyTitle,
      description: l10n.paymentsSearchEmptyDescription,
    );
  }
}
