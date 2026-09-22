import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/app/theme/app_motion.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/features/payments/formatters/payment_formatters.dart';
import 'package:mamo_approval/features/payments/states/approval/approval_cubit.dart';
import 'package:mamo_approval/features/payments/states/approval/approval_failure.dart';
import 'package:mamo_approval/features/payments/states/approval/approval_state.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

Route<void> createApprovalOverlayRoute({
  required BuildContext context,
  required ApprovalCubit approvalCubit,
  required String semanticLabel,
}) {
  final Color barrierColor = Theme.of(context).colorScheme.scrim
      .withValues(alpha: 0.54);
  final bool expanded =
      MediaQuery.sizeOf(context).width >= AppTheme.expandedBreakpoint;
  Widget content(ApprovalOverlaySurface surface) =>
      BlocProvider<ApprovalCubit>.value(
        value: approvalCubit,
        child: PopScope(
          canPop: false,
          child: ApprovalOverlay(surface: surface),
        ),
      );

  if (expanded) {
    return DialogRoute<void>(
      context: context,
      barrierColor: barrierColor,
      barrierDismissible: false,
      barrierLabel: semanticLabel,
      builder: (BuildContext context) => content(ApprovalOverlaySurface.dialog),
    );
  }
  return ModalBottomSheetRoute<void>(
    builder: (BuildContext context) =>
        content(ApprovalOverlaySurface.bottomSheet),
    barrierLabel: semanticLabel,
    modalBarrierColor: barrierColor,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    useSafeArea: true,
    clipBehavior: Clip.antiAlias,
  );
}

enum ApprovalOverlaySurface { bottomSheet, dialog }

class ApprovalOverlay extends StatelessWidget {
  const ApprovalOverlay({required this.surface, super.key});

  final ApprovalOverlaySurface surface;

  @override
  Widget build(BuildContext context) {
    final Widget content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppTheme.contentWidth),
      child: _ApprovalPanel(surface: surface),
    );
    return switch (surface) {
      ApprovalOverlaySurface.bottomSheet => content,
      ApprovalOverlaySurface.dialog => Dialog(
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    };
  }
}

class _ApprovalPanel extends StatelessWidget {
  const _ApprovalPanel({required this.surface});

  final ApprovalOverlaySurface surface;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocBuilder<ApprovalCubit, ApprovalState>(
      builder: (BuildContext context, ApprovalState state) {
        return Semantics(
          identifier: 'approval.overlay',
          container: true,
          namesRoute: true,
          label: l10n.approvalModalLabel,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.sectionGap),
            child: _ApprovalStaggeredContent(surface: surface, state: state),
          ),
        );
      },
    );
  }
}

class _ApprovalStaggeredContent extends StatelessWidget {
  const _ApprovalStaggeredContent({required this.surface, required this.state});

  final ApprovalOverlaySurface surface;
  final ApprovalState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Widget> groups = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(l10n.approvalTitle, style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppTheme.smallGap),
          Text(
            l10n.approvalDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SensitiveRequestDetails(state: state),
          const SizedBox(height: AppTheme.itemGap),
          _ReferenceField(reference: state.request.reference),
          if (state.failure case final failure?) ...<Widget>[
            const SizedBox(height: AppTheme.itemGap),
            _ApprovalError(failure: failure),
          ],
        ],
      ),
      _ApprovalActions(state: state),
    ];
    return switch (surface) {
      ApprovalOverlaySurface.bottomSheet => AppBottomSheetStaggeredColumn(
        spacing: AppTheme.sectionGap,
        replayKey: state.request.id,
        children: groups,
      ),
      ApprovalOverlaySurface.dialog => AppDialogStaggeredColumn(
        spacing: AppTheme.sectionGap,
        replayKey: state.request.id,
        children: groups,
      ),
    };
  }
}

class _SensitiveRequestDetails extends StatelessWidget {
  const _SensitiveRequestDetails({required this.state});

  final ApprovalState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Payment request = state.request;
    final String counterparty = state.isRevealed
        ? request.counterparty
        : _maskCounterparty(request.counterparty);
    final String amount = state.isRevealed
        ? PaymentFormatters(reportingTimeZone: 'Asia/Dubai')
              .money(request.amount, request.currency)
        : l10n.approvalMaskedAmount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ApprovalValue(
          identifier: 'approval.counterparty',
          label: l10n.approvalCounterpartyLabel,
          value: counterparty,
          semanticValue: state.isRevealed
              ? l10n.approvalRevealedCounterpartySemantics(counterparty)
              : l10n.approvalMaskedCounterpartySemantics(counterparty),
        ),
        const SizedBox(height: AppTheme.itemGap),
        _ApprovalValue(
          identifier: 'approval.amount',
          label: l10n.approvalAmountLabel,
          value: amount,
          semanticValue: state.isRevealed
              ? l10n.approvalRevealedAmountSemantics(amount)
              : l10n.approvalMaskedAmountSemantics,
          prominent: true,
        ),
      ],
    );
  }
}

class _ReferenceField extends StatelessWidget {
  const _ReferenceField({required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) => _ApprovalValue(
    identifier: 'approval.reference',
    label: AppLocalizations.of(context).approvalReferenceLabel,
    value: reference,
    semanticValue: AppLocalizations.of(context)
        .approvalReferenceSemantics(reference),
  );
}

class _ApprovalValue extends StatelessWidget {
  const _ApprovalValue({
    required this.identifier,
    required this.label,
    required this.value,
    required this.semanticValue,
    this.prominent = false,
  });

  final String identifier;
  final String label;
  final String value;
  final String semanticValue;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      identifier: identifier,
      label: semanticValue,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTheme.smallGap),
          Text(
            value,
            style: prominent
                ? theme.textTheme.headlineMedium
                : theme.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _ApprovalActions extends StatelessWidget {
  const _ApprovalActions({required this.state});

  final ApprovalState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ApprovalCubit cubit = context.read<ApprovalCubit>();
    final bool authenticating = state.phase == ApprovalPhase.authenticating;
    final bool submitting = state.phase == ApprovalPhase.submitting;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          identifier: 'approval.reveal',
          // Solid tonal button: the preparatory reveal step reads as a filled
          // secondary action, distinct from the primary Approve confirmation.
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colors.secondaryContainer,
              foregroundColor: colors.onSecondaryContainer,
            ),
            onPressed: state.canReveal
                ? () => unawaited(
                    cubit.reveal(localizedReason: l10n.approvalAuthReason),
                  )
                : null,
            icon: authenticating
                ? const _ButtonProgress()
                : const Icon(Icons.visibility_outlined),
            label: Text(
              authenticating
                  ? l10n.approvalAuthenticatingAction
                  : state.isRevealed
                  ? l10n.approvalDetailsRevealedAction
                  : l10n.approvalRevealAction,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.itemGap),
        if (submitting) ...<Widget>[
          Semantics(
            label: l10n.approvalSubmittingDecision,
            liveRegion: true,
            child: const LinearProgressIndicator(),
          ),
          const SizedBox(height: AppTheme.itemGap),
        ],
        Row(
          children: <Widget>[
            Expanded(
              child: Semantics(
                identifier: 'approval.reject',
                // Destructive action: solid error colours signal that reject
                // discards the incoming request.
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: colors.onError,
                  ),
                  onPressed: state.canReject
                      ? () => unawaited(cubit.reject())
                      : null,
                  child: Text(l10n.approvalRejectAction),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.itemGap),
            Expanded(
              child: Semantics(
                identifier: 'approval.approve',
                child: FilledButton(
                  onPressed: state.canApprove
                      ? () => unawaited(cubit.approve())
                      : null,
                  child: Text(l10n.approvalApproveAction),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ButtonProgress extends StatelessWidget {
  const _ButtonProgress();

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}

class _ApprovalError extends StatelessWidget {
  const _ApprovalError({required this.failure});

  final ApprovalFailure failure;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final String message = switch (failure) {
      ApprovalAuthenticationError(
        reason: ApprovalAuthenticationFailure.cancelled,
      ) =>
        l10n.approvalAuthenticationCancelled,
      ApprovalAuthenticationError(
        reason: ApprovalAuthenticationFailure.unavailable,
      ) =>
        l10n.approvalAuthenticationUnavailable,
      ApprovalAuthenticationError(
        reason: ApprovalAuthenticationFailure.failed,
      ) =>
        l10n.approvalAuthenticationFailed,
      ApprovalDecisionError() => l10n.approvalDecisionFailed,
    };
    return Semantics(
      identifier: 'approval.error',
      liveRegion: true,
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

String _maskCounterparty(String counterparty) {
  if (counterparty.isEmpty) {
    return '••••';
  }
  return '${counterparty.characters.first}••••';
}
