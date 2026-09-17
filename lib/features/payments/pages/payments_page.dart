import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_state.dart';
import 'package:mamo_payment_approval_challenge/features/payments/formatters/payment_formatters.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/payment_page_scaffold.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/payment_row.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/payment_state_views.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({required this.onOpenPayment, super.key});

  final ValueChanged<String> onOpenPayment;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return PaymentPageScaffold(
      title: l10n.paymentsTitle,
      semanticIdentifier: 'payments.page',
      child: BlocBuilder<PaymentsCubit, PaymentsState>(
        builder: (BuildContext context, PaymentsState state) {
          return switch (state.status) {
            PaymentsLoadStatus.initial ||
            PaymentsLoadStatus.loading => const PaymentsLoadingView(),
            PaymentsLoadStatus.failure => PaymentsErrorView(
              failure: state.failure!,
              onRetry: () => unawaited(context.read<PaymentsCubit>().load()),
            ),
            PaymentsLoadStatus.success => _PaymentsHistory(
              payments: state.decidedPayments,
              reportingTimeZone: state.reportingTimeZone,
              formatters: PaymentFormatters(
                reportingTimeZone: state.reportingTimeZone,
              ),
              onOpenPayment: onOpenPayment,
            ),
          };
        },
      ),
    );
  }
}

class _PaymentsHistory extends StatelessWidget {
  const _PaymentsHistory({
    required this.payments,
    required this.reportingTimeZone,
    required this.formatters,
    required this.onOpenPayment,
  });

  final List<Payment> payments;
  final String reportingTimeZone;
  final PaymentFormatters formatters;
  final ValueChanged<String> onOpenPayment;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (payments.isEmpty) {
      return PaymentsEmptyView(
        title: l10n.emptyPaymentsTitle,
        description: l10n.emptyPaymentsDescription,
      );
    }

    return ListView.separated(
      key: const PageStorageKey<String>('payments.history'),
      padding: const EdgeInsets.only(bottom: AppTheme.sectionGap),
      itemCount: payments.length + 1,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: AppTheme.itemGap),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Text(
            l10n.reportingTimeZoneContext(reportingTimeZone),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        }
        final Payment payment = payments[index - 1];
        return PaymentRow(
          payment: payment,
          formatters: formatters,
          onTap: () => onOpenPayment(payment.id),
        );
      },
    );
  }
}
