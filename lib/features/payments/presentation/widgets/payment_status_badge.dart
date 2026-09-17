import 'package:flutter/material.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({required this.status, super.key});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final (String, IconData, Color, Color) presentation = switch (status) {
      PaymentStatus.approved => (
        l10n.paymentStatusApproved,
        Icons.check_circle_outline,
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      PaymentStatus.rejected => (
        l10n.paymentStatusRejected,
        Icons.cancel_outlined,
        colors.errorContainer,
        colors.onErrorContainer,
      ),
      PaymentStatus.pending => (
        l10n.paymentStatusPending,
        Icons.schedule_outlined,
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
      ),
    };
    final (String label, IconData icon, Color background, Color foreground) =
        presentation;

    return Semantics(
      identifier: 'payment.status.${status.name}',
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppTheme.controlRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.itemGap,
            vertical: AppTheme.smallGap,
          ),
          child: Wrap(
            spacing: AppTheme.smallGap,
            runSpacing: AppTheme.smallGap,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Icon(icon, size: 18, color: foreground),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
