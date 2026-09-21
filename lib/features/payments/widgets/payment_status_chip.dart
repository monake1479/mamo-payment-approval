import 'package:flutter/material.dart';
import 'package:mamo_approval/app/theme/app_status_colors.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

enum PaymentStatusVisual { approved, pending, rejected }

class PaymentStatusChip extends StatelessWidget {
  const PaymentStatusChip({required this.status, super.key});

  final PaymentStatusVisual status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppStatusColors statusColors = Theme.of(context)
        .extension<AppStatusColors>()!;
    final (String, IconData, Color, Color) values = switch (status) {
      PaymentStatusVisual.approved => (
        l10n.paymentStatusApproved,
        Icons.check_circle_outline,
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      PaymentStatusVisual.pending => (
        l10n.paymentStatusPending,
        Icons.schedule_outlined,
        statusColors.pendingContainer,
        statusColors.onPendingContainer,
      ),
      PaymentStatusVisual.rejected => (
        l10n.paymentStatusRejected,
        Icons.cancel_outlined,
        colors.errorContainer,
        colors.onErrorContainer,
      ),
    };

    return Semantics(
      label: values.$1,
      excludeSemantics: true,
      child: Chip(
        avatar: Icon(values.$2, color: values.$4),
        label: Text(values.$1),
        backgroundColor: values.$3,
        labelStyle: TextStyle(color: values.$4),
        side: BorderSide.none,
      ),
    );
  }
}
