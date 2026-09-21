import 'package:flutter/material.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/features/payments/formatters/payment_formatters.dart';
import 'package:mamo_approval/features/payments/widgets/payment_status_filter_chips.dart';
import 'package:mamo_approval/features/payments/widgets/payments_date_filter_chip.dart';
import 'package:mamo_approval/features/payments/widgets/payments_search_field.dart';
import 'package:mamo_approval/features/payments/widgets/payments_sort_menu.dart';

/// The search field with its status, date, and sort controls, laid out as one
/// entrance group.
class PaymentsSearchControls extends StatelessWidget {
  const PaymentsSearchControls({
    required this.formatters,
    required this.lastSelectableDay,
    super.key,
  });

  final PaymentFormatters formatters;
  final DateTime lastSelectableDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const PaymentsSearchField(),
        const SizedBox(height: AppTheme.smallGap),
        // One scrolling row keeps the controls' height bounded at large text
        // sizes; the list below keeps the remaining space.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: AppTheme.smallGap,
            children: <Widget>[
              const PaymentStatusFilterChips(),
              PaymentsDateFilterChip(
                formatters: formatters,
                lastSelectableDay: lastSelectableDay,
              ),
              const PaymentsSortMenu(),
            ],
          ),
        ),
      ],
    );
  }
}
