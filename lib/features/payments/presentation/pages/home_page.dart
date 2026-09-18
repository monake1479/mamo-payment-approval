import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_motion.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/formatters/payment_formatters.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/widgets/monthly_summary_card.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/widgets/payment_page_scaffold.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/widgets/payment_state_views.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/widgets/recent_payments_section.dart';
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
          final Widget content = switch (state.status) {
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
          return AppMotionSwitcher(
            child: KeyedSubtree(
              key: ValueKey<PaymentsLoadStatus>(state.status),
              child: content,
            ),
          );
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
        AppStaggeredColumn(
          spacing: AppTheme.sectionGap,
          children: <Widget>[
            MonthlySummaryCard(
              amount: formatters.aed(state.summary.approvedAmount),
              approvedCount: state.summary.approvedCount,
              month: formatters.month(state.reportingPeriodStartUtc),
              reportingTimeZone: state.reportingTimeZone,
            ),
            RecentPaymentsSection(
              payments: recent,
              formatters: formatters,
              onOpenPayment: onOpenPayment,
              onViewAll: onViewAll,
            ),
          ],
        ),
      ],
    );
  }
}
