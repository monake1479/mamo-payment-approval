import 'package:flutter/material.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/features/payments/formatters/payment_formatters.dart';
import 'package:mamo_approval/features/payments/widgets/payments_list.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// Matching decided payments with an announced result count, as slivers of
/// the history scroll view.
class PaymentsSearchResultsView extends StatelessWidget {
  const PaymentsSearchResultsView({
    required this.payments,
    required this.formatters,
    required this.onOpenPayment,
    super.key,
  });

  final List<Payment> payments;
  final PaymentFormatters formatters;
  final ValueChanged<String> onOpenPayment;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.smallGap),
            child: Semantics(
              identifier: 'payments.search.results',
              liveRegion: true,
              child: Text(
                l10n.paymentsSearchResultCount(payments.length),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        PaymentsList(
          payments: payments,
          formatters: formatters,
          onOpenPayment: onOpenPayment,
        ),
      ],
    );
  }
}
