import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_motion.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/device_authentication_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/formatters/payment_formatters.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/approval/approval_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/approval/approval_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/approval/approval_state.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

Route<void> createApprovalOverlayRoute({
  required BuildContext context,
  required BuildContext navigatorContext,
  required ApprovalCubit approvalCubit,
  required String semanticLabel,
}) {
  final bool expanded =
      MediaQuery.sizeOf(context).width >= AppTheme.expandedBreakpoint;
  final AnimationStyle animationStyle = AnimationStyle(
    duration: AppMotion.resolve(context, AppMotion.standard),
    reverseDuration: AppMotion.resolve(context, AppMotion.fast),
    curve: AppMotion.enterCurve,
    reverseCurve: AppMotion.exitCurve,
  );
  Widget buildOverlay(BuildContext context) =>
      BlocProvider<ApprovalCubit>.value(
        value: approvalCubit,
        child: PopScope(
          canPop: false,
          child: ApprovalOverlay(expanded: expanded),
        ),
      );

  if (expanded) {
    return DialogRoute<void>(
      context: navigatorContext,
      barrierDismissible: false,
      barrierLabel: semanticLabel,
      animationStyle: animationStyle,
      builder: (BuildContext context) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.contentWidth),
          child: buildOverlay(context),
        ),
      ),
    );
  }

  return ModalBottomSheetRoute<void>(
    builder: buildOverlay,
    barrierLabel: semanticLabel,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    useSafeArea: true,
    clipBehavior: Clip.antiAlias,
    constraints: const BoxConstraints(maxWidth: AppTheme.contentWidth),
    sheetAnimationStyle: animationStyle,
  );
}

class ApprovalOverlay extends StatelessWidget {
  const ApprovalOverlay({required this.expanded, super.key});

  final bool expanded;

  @override
  Widget build(BuildContext context) => _ApprovalPanel(expanded: expanded);
}

class _ApprovalPanel extends StatelessWidget {
  const _ApprovalPanel({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocBuilder<ApprovalCubit, ApprovalState>(
      builder: (BuildContext context, ApprovalState state) {
        final List<Widget> groups = <Widget>[
          const _ApprovalIntroduction(),
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
        final Widget content = expanded
            ? AppDialogStaggeredColumn(
                spacing: AppTheme.sectionGap,
                children: groups,
              )
            : AppBottomSheetStaggeredColumn(
                spacing: AppTheme.sectionGap,
                children: groups,
              );
        return Semantics(
          identifier: 'approval.overlay',
          container: true,
          namesRoute: true,
          label: l10n.approvalModalLabel,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.sectionGap),
            child: content,
          ),
        );
      },
    );
  }
}

class _ApprovalIntroduction extends StatelessWidget {
  const _ApprovalIntroduction();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
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
    );
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
        ? PaymentFormatters.formatMoney(request.currency, request.amount)
        : l10n.approvalMaskedAmount(request.currency);
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
              : l10n.approvalMaskedAmountSemantics(request.currency),
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ApprovalCubit cubit = context.read<ApprovalCubit>();
    final bool authenticating = state.phase == ApprovalPhase.authenticating;
    final bool submitting = state.phase == ApprovalPhase.submitting;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          identifier: 'approval.reveal',
          child: OutlinedButton.icon(
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
                child: OutlinedButton(
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
        reason: DeviceAuthenticationCancelledFailure(),
      ) =>
        l10n.approvalAuthenticationCancelled,
      ApprovalAuthenticationError(
        reason: DeviceAuthenticationUnavailableFailure(),
      ) =>
        l10n.approvalAuthenticationUnavailable,
      ApprovalAuthenticationError(
        reason: DeviceAuthenticationFailedFailure(),
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
