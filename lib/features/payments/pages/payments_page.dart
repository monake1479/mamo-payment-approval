import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/app/di/configure_dependencies.dart';
import 'package:mamo_approval/app/theme/app_motion.dart';
import 'package:mamo_approval/features/payments/formatters/payment_formatters.dart';
import 'package:mamo_approval/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_approval/features/payments/states/payments/payments_state.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_bloc.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_event.dart';
import 'package:mamo_approval/features/payments/views/payments_history_view.dart';
import 'package:mamo_approval/features/payments/widgets/payment_page_scaffold.dart';
import 'package:mamo_approval/features/payments/widgets/payment_state_views.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// Decided payment history. Provides its own page-scoped [PaymentsSearchBloc]
/// and selects a view for each collection load state.
class PaymentsPage extends StatelessWidget {
  const PaymentsPage({required this.onOpenPayment, super.key});

  final ValueChanged<String> onOpenPayment;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocProvider<PaymentsSearchBloc>(
      create: (BuildContext _) => getIt<PaymentsSearchBloc>(),
      child: PaymentPageScaffold(
        title: l10n.paymentsTitle,
        semanticIdentifier: 'payments.page',
        // The search bloc reads the same authoritative backend, so a decision
        // that changes the canonical collection re-runs any active search here
        // instead of the bloc observing the cubit directly.
        child: BlocListener<PaymentsCubit, PaymentsState>(
          listenWhen: (PaymentsState previous, PaymentsState current) =>
              !identical(previous.payments, current.payments),
          listener: (BuildContext context, PaymentsState _) => context
              .read<PaymentsSearchBloc>()
              .add(const PaymentsSearchEvent.refreshRequested()),
          child: BlocBuilder<PaymentsCubit, PaymentsState>(
            builder: (BuildContext context, PaymentsState state) {
              final AppIndexedPageMotionScope? pageMotion =
                  AppIndexedPageMotionScope.maybeOf(context);
              return AppMotionSwitcher(
                child: switch (state.status) {
                  PaymentsLoadStatus.initial ||
                  PaymentsLoadStatus.loading => const PaymentsLoadingView(
                    key: ValueKey<PaymentsLoadStatus>(
                      PaymentsLoadStatus.loading,
                    ),
                  ),
                  PaymentsLoadStatus.failure => PaymentsErrorView(
                    key: const ValueKey<PaymentsLoadStatus>(
                      PaymentsLoadStatus.failure,
                    ),
                    failure: state.failure!,
                    onRetry: () =>
                        unawaited(context.read<PaymentsCubit>().load()),
                  ),
                  PaymentsLoadStatus.success => PaymentsHistoryView(
                    key: const ValueKey<PaymentsLoadStatus>(
                      PaymentsLoadStatus.success,
                    ),
                    payments: state.decidedPayments,
                    motionReplayKey: pageMotion?.activation,
                    startMotion: pageMotion?.startAnimation ?? true,
                    reportingTimeZone: state.reportingTimeZone,
                    // Decisions never lie in the future; the current account
                    // month is the widest window worth offering.
                    lastSelectableDay:
                        PaymentFormatters(
                          reportingTimeZone: state.reportingTimeZone,
                        ).accountDay(
                          state.reportingPeriodStartUtc.add(
                            const Duration(days: 31),
                          ),
                        ),
                    formatters: PaymentFormatters(
                      reportingTimeZone: state.reportingTimeZone,
                    ),
                    onOpenPayment: onOpenPayment,
                    onRefresh: () async {
                      await context.read<PaymentsCubit>().load();
                    },
                  ),
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
