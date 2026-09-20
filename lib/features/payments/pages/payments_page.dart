import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_motion.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/formatters/payment_formatters.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_state.dart';
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
          final AppIndexedPageMotionScope? pageMotion =
              AppIndexedPageMotionScope.maybeOf(context);
          return AppMotionSwitcher(
            child: switch (state.status) {
              PaymentsLoadStatus.initial ||
              PaymentsLoadStatus.loading => const PaymentsLoadingView(
                key: ValueKey<PaymentsLoadStatus>(PaymentsLoadStatus.loading),
              ),
              PaymentsLoadStatus.failure => PaymentsErrorView(
                key: const ValueKey<PaymentsLoadStatus>(
                  PaymentsLoadStatus.failure,
                ),
                failure: state.failure!,
                onRetry: () => unawaited(context.read<PaymentsCubit>().load()),
              ),
              PaymentsLoadStatus.success => _PaymentsHistory(
                key: const ValueKey<PaymentsLoadStatus>(
                  PaymentsLoadStatus.success,
                ),
                payments: state.decidedPayments,
                motionReplayKey: pageMotion?.activation,
                startMotion: pageMotion?.startAnimation ?? true,
                reportingTimeZone: state.reportingTimeZone,
                formatters: PaymentFormatters(
                  reportingTimeZone: state.reportingTimeZone,
                ),
                onOpenPayment: onOpenPayment,
              ),
            },
          );
        },
      ),
    );
  }
}

class _PaymentsHistory extends StatelessWidget {
  const _PaymentsHistory({
    required this.payments,
    required this.motionReplayKey,
    required this.startMotion,
    required this.reportingTimeZone,
    required this.formatters,
    required this.onOpenPayment,
    super.key,
  });

  final List<Payment> payments;
  final Object? motionReplayKey;
  final bool startMotion;
  final String reportingTimeZone;
  final PaymentFormatters formatters;
  final ValueChanged<String> onOpenPayment;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final Widget history = payments.isEmpty
        ? PaymentsEmptyView(
            title: l10n.emptyPaymentsTitle,
            description: l10n.emptyPaymentsDescription,
          )
        : ListView.separated(
            key: const PageStorageKey<String>('payments.history'),
            padding: const EdgeInsets.only(bottom: AppTheme.sectionGap),
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
          );

    return AppStaggeredColumn(
      spacing: AppTheme.itemGap,
      replayKey: motionReplayKey,
      startAnimation: startMotion,
      startDelay: AppMotion.fast,
      children: <Widget>[
        Semantics(
          identifier: 'payments.reportingTimeZone',
          child: Text(
            l10n.paymentsReportingTimeZone(reportingTimeZone),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: history),
      ],
    );
  }
}
