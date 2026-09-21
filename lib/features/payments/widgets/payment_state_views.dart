import 'package:flutter/material.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

class PaymentsLoadingView extends StatelessWidget {
  const PaymentsLoadingView({
    this.identifier = 'payments.loading',
    this.label,
    super.key,
  });

  final String identifier;

  /// Accessible progress label; defaults to the history loading label.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Center(
      child: Semantics(
        identifier: identifier,
        label: label ?? l10n.paymentsLoadingLabel,
        liveRegion: true,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class PaymentsEmptyView extends StatelessWidget {
  const PaymentsEmptyView({
    required this.title,
    required this.description,
    this.identifier = 'payments.empty',
    this.scrollable = true,
    super.key,
  });

  final String title;
  final String description;
  final String identifier;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget content = Padding(
      padding: const EdgeInsets.all(AppTheme.sectionGap),
      child: Semantics(
        identifier: identifier,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.receipt_long_outlined,
              size: AppTheme.minimumTouchTarget,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppTheme.itemGap),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.smallGap),
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
    return Center(
      child: scrollable
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: content,
            )
          : content,
    );
  }
}

class PaymentsErrorView extends StatelessWidget {
  const PaymentsErrorView({
    required this.failure,
    required this.onRetry,
    this.identifier = 'payments.error',
    this.title,
    this.description,
    this.scrollable = true,
    super.key,
  });

  final PaymentsFailure failure;
  final VoidCallback onRetry;
  final String identifier;

  /// False when an enclosing scroll view already owns scrolling.
  final bool scrollable;

  /// Heading; defaults to the history load error title.
  final String? title;

  /// Explanation; defaults to the history load mapping of [failure].
  final String? description;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final Widget content = Padding(
      padding: const EdgeInsets.all(AppTheme.sectionGap),
      child: Semantics(
        identifier: identifier,
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: AppTheme.minimumTouchTarget,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppTheme.itemGap),
            Text(
              title ?? l10n.paymentsLoadErrorTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.smallGap),
            Text(
              description ?? failure.message(l10n),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.sectionGap),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryAction),
            ),
          ],
        ),
      ),
    );
    return Center(
      child: scrollable
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: content,
            )
          : content,
    );
  }
}

extension PaymentsFailureMessage on PaymentsFailure {
  String message(AppLocalizations l10n) => switch (this) {
    InvalidPaymentFailure() => l10n.paymentsInvalidDataDescription,
    DuplicateRequestFailure() ||
    PaymentNotFoundFailure() ||
    PaymentAlreadyDecidedFailure() ||
    PaymentBusyFailure() ||
    OperationCancelledFailure() ||
    PaymentsUnavailableFailure() => l10n.paymentsLoadErrorDescription,
  };

  String searchMessage(AppLocalizations l10n) => switch (this) {
    InvalidPaymentFailure() => l10n.paymentsInvalidDataDescription,
    DuplicateRequestFailure() ||
    PaymentNotFoundFailure() ||
    PaymentAlreadyDecidedFailure() ||
    PaymentBusyFailure() ||
    OperationCancelledFailure() ||
    PaymentsUnavailableFailure() => l10n.paymentsSearchErrorDescription,
  };
}
