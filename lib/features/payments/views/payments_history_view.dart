import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/app/theme/app_motion.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/features/payments/formatters/payment_formatters.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_bloc.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_state.dart';
import 'package:mamo_approval/features/payments/views/payments_search_empty_view.dart';
import 'package:mamo_approval/features/payments/views/payments_search_error_view.dart';
import 'package:mamo_approval/features/payments/views/payments_search_loading_view.dart';
import 'package:mamo_approval/features/payments/views/payments_search_results_view.dart';
import 'package:mamo_approval/features/payments/widgets/payment_state_views.dart';
import 'package:mamo_approval/features/payments/widgets/payments_list.dart';
import 'package:mamo_approval/features/payments/widgets/payments_search_controls.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// Loaded decided history: reporting-zone context, search controls, and the
/// list area, which follows the search state (idle shows the full history).
class PaymentsHistoryView extends StatelessWidget {
  const PaymentsHistoryView({
    required this.payments,
    required this.motionReplayKey,
    required this.startMotion,
    required this.reportingTimeZone,
    required this.lastSelectableDay,
    required this.formatters,
    required this.onOpenPayment,
    required this.onRefresh,
    super.key,
  });

  final List<Payment> payments;
  final Object? motionReplayKey;
  final bool startMotion;
  final String reportingTimeZone;

  /// Latest calendar day the date filter offers.
  final DateTime lastSelectableDay;
  final PaymentFormatters formatters;
  final ValueChanged<String> onOpenPayment;

  /// Pull-to-refresh reloads the authoritative collection; an active search
  /// re-runs through the page's collection listener.
  final Future<void> Function() onRefresh;

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
        PaymentsSearchControls(
          formatters: formatters,
          lastSelectableDay: lastSelectableDay,
        ),
        Expanded(
          child: BlocBuilder<PaymentsSearchBloc, PaymentsSearchState>(
            builder: (BuildContext context, PaymentsSearchState searchState) {
              return Semantics(
                identifier: 'payments.refresh',
                label: l10n.paymentsRefreshLabel,
                child: RefreshIndicator(
                  onRefresh: onRefresh,
                  child: switch (searchState) {
                    PaymentsSearchIdle() =>
                      payments.isEmpty
                          ? PaymentsEmptyView(
                              title: l10n.emptyPaymentsTitle,
                              description: l10n.emptyPaymentsDescription,
                            )
                          : PaymentsList(
                              storageKey: 'payments.history',
                              payments: payments,
                              formatters: formatters,
                              onOpenPayment: onOpenPayment,
                            ),
                    PaymentsSearchLoading() =>
                      const PaymentsSearchLoadingView(),
                    PaymentsSearchResults(
                      payments: final List<Payment> results,
                    ) =>
                      PaymentsSearchResultsView(
                        payments: results,
                        formatters: formatters,
                        onOpenPayment: onOpenPayment,
                      ),
                    PaymentsSearchEmpty() => const PaymentsSearchEmptyView(),
                    PaymentsSearchError(:final failure) =>
                      PaymentsSearchErrorView(failure: failure),
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
