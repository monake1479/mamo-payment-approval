import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_state.dart';
import 'package:mamo_payment_approval_challenge/features/payments/formatters/payment_formatters.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/monthly_summary_card.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/payment_page_scaffold.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/payment_state_views.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/recent_payments_section.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.onOpenPayment,
    required this.onViewAll,
    super.key,
  });

  final ValueChanged<String> onOpenPayment;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return PaymentPageScaffold(
      title: l10n.homeTitle,
      semanticIdentifier: 'home.page',
      child: BlocBuilder<PaymentsCubit, PaymentsState>(
        builder: (BuildContext context, PaymentsState state) {
          return switch (state.status) {
            PaymentsLoadStatus.initial ||
            PaymentsLoadStatus.loading => const PaymentsLoadingView(),
            PaymentsLoadStatus.failure => PaymentsErrorView(
              failure: state.failure!,
              onRetry: () => unawaited(context.read<PaymentsCubit>().load()),
            ),
            PaymentsLoadStatus.success => _HomeContent(
              state: state,
              onOpenPayment: onOpenPayment,
              onViewAll: onViewAll,
            ),
          };
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.state,
    required this.onOpenPayment,
    required this.onViewAll,
  });

  final PaymentsState state;
  final ValueChanged<String> onOpenPayment;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final PaymentFormatters formatters = PaymentFormatters(
      reportingTimeZone: state.reportingTimeZone,
    );
    final List<Payment> recent = state.decidedPayments
        .take(5)
        .toList(growable: false);
    return ListView(
      key: const PageStorageKey<String>('home.content'),
      padding: const EdgeInsets.only(bottom: AppTheme.sectionGap),
      children: <Widget>[
        MonthlySummaryCard(
          amount: formatters.money(
            state.summary.approvedAmount,
            state.reportingCurrency,
          ),
          approvedCount: state.summary.approvedCount,
          month: formatters.month(state.reportingPeriodStartUtc),
          reportingTimeZone: state.reportingTimeZone,
        ),
        const SizedBox(height: AppTheme.sectionGap),
        RecentPaymentsSection(
          payments: recent,
          formatters: formatters,
          onOpenPayment: onOpenPayment,
          onViewAll: onViewAll,
        ),
      ],
    );
  }
}
