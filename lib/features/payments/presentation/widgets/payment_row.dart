import 'package:flutter/material.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/formatters/payment_formatters.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/widgets/payment_status_chip.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

class PaymentRow extends StatelessWidget {
  const PaymentRow({
    required this.payment,
    required this.formatters,
    required this.onTap,
    super.key,
  });

  final Payment payment;
  final PaymentFormatters formatters;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final DateTime decidedAt = payment.decidedAt!;
    final String amount = formatters.aed(payment.amount);
    final String date = formatters.dateTime(decidedAt);
    final String status = switch (payment.status) {
      PaymentStatus.approved => l10n.paymentStatusApproved,
      PaymentStatus.rejected => l10n.paymentStatusRejected,
      PaymentStatus.pending => l10n.paymentStatusPending,
    };

    return Semantics(
      identifier: 'payment.row.${payment.id}',
      button: true,
      onTap: onTap,
      label: l10n.paymentRowAccessibilityLabel(
        payment.counterparty,
        amount,
        status,
        date,
      ),
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.compactPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(payment.counterparty, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppTheme.smallGap),
                Text(amount, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppTheme.itemGap),
                Wrap(
                  spacing: AppTheme.itemGap,
                  runSpacing: AppTheme.smallGap,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    PaymentStatusChip(status: payment.status),
                    Text(
                      date,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
