import 'package:flutter/material.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

class PaymentsLoadingView extends StatelessWidget {
  const PaymentsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Center(
      child: Semantics(
        identifier: 'payments.loading',
        label: l10n.paymentsLoadingLabel,
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
      child: scrollable ? SingleChildScrollView(child: content) : content,
    );
  }
}

class PaymentsErrorView extends StatelessWidget {
  const PaymentsErrorView({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final PaymentsFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.sectionGap),
        child: Semantics(
          identifier: 'payments.error',
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
                l10n.paymentsLoadErrorTitle,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.smallGap),
              Text(
                failure.message(l10n),
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
      ),
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
    StorageFailure() => l10n.paymentsLoadErrorDescription,
  };
}
