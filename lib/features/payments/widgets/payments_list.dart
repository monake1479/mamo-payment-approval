import 'package:flutter/material.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/features/payments/formatters/payment_formatters.dart';
import 'package:mamo_approval/features/payments/widgets/payment_row.dart';

/// Sliver of decided payment rows shared by the full history and the search
/// results; the enclosing scroll view owns scrolling and pull-to-refresh.
class PaymentsList extends StatelessWidget {
  const PaymentsList({
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
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: AppTheme.sectionGap),
      sliver: SliverList.separated(
        itemCount: payments.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: AppTheme.itemGap),
        itemBuilder: (BuildContext context, int index) {
          final Payment payment = payments[index];
          return PaymentRow(
            payment: payment,
            formatters: formatters,
            onTap: () => onOpenPayment(payment.id),
          );
        },
      ),
    );
  }
}
