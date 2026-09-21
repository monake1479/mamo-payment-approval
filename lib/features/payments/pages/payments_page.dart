import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_motion.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/formatters/payment_formatters.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_state.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/search/payments_search_bloc.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/search/payments_search_event.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/search/payments_search_state.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/payment_page_scaffold.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/payment_row.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/payment_state_views.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/payment_status_filter_chips.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/payments_search_field.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

/// Decided payment history. Requires a [PaymentsCubit] and a
/// [PaymentsSearchBloc] above it; app composition provides both.
class PaymentsPage extends StatelessWidget {
  const PaymentsPage({required this.onOpenPayment, super.key});

  final ValueChanged<String> onOpenPayment;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return PaymentPageScaffold(
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
                  key: ValueKey<PaymentsLoadStatus>(PaymentsLoadStatus.loading),
                ),
                PaymentsLoadStatus.failure => PaymentsErrorView(
                  key: const ValueKey<PaymentsLoadStatus>(
                    PaymentsLoadStatus.failure,
                  ),
                  failure: state.failure!,
                  onRetry: () =>
                      unawaited(context.read<PaymentsCubit>().load()),
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
        const _PaymentsSearchControls(),
        Expanded(
          child: BlocBuilder<PaymentsSearchBloc, PaymentsSearchState>(
            builder: (BuildContext context, PaymentsSearchState searchState) {
              return switch (searchState) {
                PaymentsSearchIdle() =>
                  payments.isEmpty
                      ? PaymentsEmptyView(
                          title: l10n.emptyPaymentsTitle,
                          description: l10n.emptyPaymentsDescription,
                        )
                      : _PaymentsList(
                          storageKey: 'payments.history',
                          payments: payments,
                          formatters: formatters,
                          onOpenPayment: onOpenPayment,
                        ),
                PaymentsSearchLoading() => PaymentsLoadingView(
                  identifier: 'payments.search.loading',
                  label: l10n.paymentsSearchLoadingLabel,
                ),
                PaymentsSearchResults(payments: final List<Payment> results) =>
                  _PaymentsSearchResults(
                    payments: results,
                    formatters: formatters,
                    onOpenPayment: onOpenPayment,
                  ),
                PaymentsSearchEmpty() => PaymentsEmptyView(
                  identifier: 'payments.search.empty',
                  title: l10n.paymentsSearchEmptyTitle,
                  description: l10n.paymentsSearchEmptyDescription,
                ),
                PaymentsSearchError(:final failure) => PaymentsErrorView(
                  identifier: 'payments.search.error',
                  failure: failure,
                  title: l10n.paymentsSearchErrorTitle,
                  description: failure.searchMessage(l10n),
                  onRetry: () => context.read<PaymentsSearchBloc>().add(
                    const PaymentsSearchEvent.refreshRequested(),
                  ),
                ),
              };
            },
          ),
        ),
      ],
    );
  }
}

class _PaymentsSearchControls extends StatelessWidget {
  const _PaymentsSearchControls();

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

class _PaymentsSearchResults extends StatelessWidget {
  const _PaymentsSearchResults({
    required this.payments,
    required this.formatters,
    required this.onOpenPayment,
  });

  final List<Payment> payments;
  final PaymentFormatters formatters;
  final ValueChanged<String> onOpenPayment;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          identifier: 'payments.search.results',
          liveRegion: true,
          child: Text(
            l10n.paymentsSearchResultCount(payments.length),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.smallGap),
        Expanded(
          child: _PaymentsList(
            storageKey: 'payments.search',
            payments: payments,
            formatters: formatters,
            onOpenPayment: onOpenPayment,
          ),
        ),
      ],
    );
  }
}

class _PaymentsList extends StatelessWidget {
  const _PaymentsList({
    required this.storageKey,
    required this.payments,
    required this.formatters,
    required this.onOpenPayment,
  });

  final String storageKey;
  final List<Payment> payments;
  final PaymentFormatters formatters;
  final ValueChanged<String> onOpenPayment;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: PageStorageKey<String>(storageKey),
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
  }
}
