import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/formatters/payment_formatters.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/widgets/payment_detail_field.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/widgets/payment_state_views.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/widgets/payment_status_badge.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

class PaymentDetailsPage extends StatelessWidget {
  const PaymentDetailsPage({required this.paymentId, super.key});

  final String paymentId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          identifier: 'payment.details.back',
          child: IconButton(
            tooltip: l10n.paymentDetailsBackLabel,
            onPressed: () => unawaited(Navigator.of(context).maybePop()),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        title: Text(l10n.paymentDetailsTitle),
      ),
      body: SafeArea(
        child: BlocBuilder<PaymentsCubit, PaymentsState>(
          builder: (BuildContext context, PaymentsState state) {
            return switch (state.status) {
              PaymentsLoadStatus.initial ||
              PaymentsLoadStatus.loading => const PaymentsLoadingView(),
              PaymentsLoadStatus.failure => PaymentsErrorView(
                failure: state.failure!,
                onRetry: () => unawaited(context.read<PaymentsCubit>().load()),
              ),
              PaymentsLoadStatus.success => _PaymentDetailsContent(
                payment: _decidedPayment(state),
                formatters: PaymentFormatters(
                  reportingTimeZone: state.reportingTimeZone,
                ),
              ),
            };
          },
        ),
      ),
    );
  }

  Payment? _decidedPayment(PaymentsState state) {
    final Payment? payment = state.paymentById(paymentId);
    return payment?.status == PaymentStatus.pending ? null : payment;
  }
}

class _PaymentDetailsContent extends StatelessWidget {
  const _PaymentDetailsContent({
    required this.payment,
    required this.formatters,
  });

  final Payment? payment;
  final PaymentFormatters formatters;

  @override
  Widget build(BuildContext context) {
    if (payment == null) {
      return const _PaymentNotFoundView();
    }
    final Payment resolvedPayment = payment!;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double horizontalPadding =
            constraints.maxWidth >= AppTheme.expandedBreakpoint
            ? AppTheme.pagePadding
            : AppTheme.compactPadding;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTheme.expandedContentWidth,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppTheme.sectionGap,
                horizontalPadding,
                AppTheme.sectionGap,
              ),
              child: Semantics(
                identifier: 'payment.details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      l10n.statusLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTheme.smallGap),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: PaymentStatusBadge(status: resolvedPayment.status),
                    ),
                    const SizedBox(height: AppTheme.itemGap),
                    Semantics(
                      identifier: 'payment.details.amount',
                      child: Text(
                        formatters.aed(resolvedPayment.amount),
                        style: theme.textTheme.headlineLarge,
                      ),
                    ),
                    const SizedBox(height: AppTheme.sectionGap),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.compactPadding),
                        child: Column(
                          children: <Widget>[
                            PaymentDetailField(
                              icon: Icons.business_outlined,
                              label: l10n.counterpartyLabel,
                              value: resolvedPayment.counterparty,
                              semanticIdentifier:
                                  'payment.details.counterparty',
                            ),
                            const SizedBox(height: AppTheme.sectionGap),
                            PaymentDetailField(
                              icon: Icons.tag_outlined,
                              label: l10n.referenceLabel,
                              value: resolvedPayment.reference,
                              semanticIdentifier: 'payment.details.reference',
                            ),
                            const SizedBox(height: AppTheme.sectionGap),
                            PaymentDetailField(
                              icon: Icons.schedule_outlined,
                              label: l10n.requestedAtLabel,
                              value: formatters.dateTime(
                                resolvedPayment.createdAt,
                              ),
                              semanticIdentifier: 'payment.details.requested',
                            ),
                            const SizedBox(height: AppTheme.sectionGap),
                            PaymentDetailField(
                              icon: Icons.event_available_outlined,
                              label: l10n.decidedAtLabel,
                              value: formatters.dateTime(
                                resolvedPayment.decidedAt!,
                              ),
                              semanticIdentifier: 'payment.details.decided',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PaymentNotFoundView extends StatelessWidget {
  const _PaymentNotFoundView();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.sectionGap),
        child: Semantics(
          identifier: 'payment.details.notFound',
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.search_off_outlined,
                size: AppTheme.minimumTouchTarget,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppTheme.itemGap),
              Text(
                l10n.paymentNotFoundTitle,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.smallGap),
              Text(
                l10n.paymentNotFoundDescription,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
