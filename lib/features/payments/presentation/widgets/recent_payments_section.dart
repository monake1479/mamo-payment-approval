import 'package:flutter/material.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/formatters/payment_formatters.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/widgets/payment_row.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/widgets/payment_state_views.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

class RecentPaymentsSection extends StatelessWidget {
  const RecentPaymentsSection({
    required this.payments,
    required this.formatters,
    required this.onOpenPayment,
    required this.onViewAll,
    super.key,
  });

  final List<Payment> payments;
  final PaymentFormatters formatters;
  final ValueChanged<String> onOpenPayment;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppTheme.itemGap,
          runSpacing: AppTheme.smallGap,
          children: <Widget>[
            Text(
              l10n.recentPaymentsTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Semantics(
              identifier: 'home.viewAllPayments',
              child: TextButton(
                onPressed: onViewAll,
                child: Text(l10n.viewAllPayments),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.itemGap),
        if (payments.isEmpty)
          PaymentsEmptyView(
            title: l10n.emptyPaymentsTitle,
            description: l10n.emptyRecentPaymentsDescription,
            identifier: 'home.recent.empty',
            scrollable: false,
          )
        else
          for (final (int index, Payment payment)
              in payments.indexed) ...<Widget>[
            PaymentRow(
              payment: payment,
              formatters: formatters,
              onTap: () => onOpenPayment(payment.id),
            ),
            if (index < payments.length - 1)
              const SizedBox(height: AppTheme.itemGap),
          ],
      ],
    );
  }
}
