import 'package:flutter/material.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/features/payments/widgets/payment_status_filter_chips.dart';
import 'package:mamo_approval/features/payments/widgets/payments_search_field.dart';

/// The search field with its status chips, laid out as one entrance group.
class PaymentsSearchControls extends StatelessWidget {
  const PaymentsSearchControls({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PaymentsSearchField(),
        SizedBox(height: AppTheme.smallGap),
        PaymentStatusFilterChips(),
      ],
    );
  }
}
