import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_money.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/approval_cubit.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

class ApprovalOverlayRoute extends PopupRoute<void> {
  ApprovalOverlayRoute({
    required this.approvalCubit,
    required this.semanticLabel,
  });

  final ApprovalCubit approvalCubit;
  final String semanticLabel;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black54;

  @override
  String get barrierLabel => semanticLabel;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 180);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => BlocProvider<ApprovalCubit>.value(
    value: approvalCubit,
    child: const PopScope(canPop: false, child: ApprovalOverlay()),
  );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => MediaQuery.disableAnimationsOf(context)
      ? child
      : FadeTransition(opacity: animation, child: child);
}

class ApprovalOverlay extends StatelessWidget {
  const ApprovalOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool expanded =
                constraints.maxWidth >= AppTheme.expandedBreakpoint;
            final Widget panel = ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTheme.contentWidth,
              ),
              child: const _ApprovalPanel(),
            );
            return Align(
              alignment: expanded ? Alignment.center : Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(
                  expanded ? AppTheme.pagePadding : AppTheme.compactPadding,
                ),
                child: panel,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ApprovalPanel extends StatelessWidget {
  const _ApprovalPanel();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: BlocBuilder<ApprovalCubit, ApprovalState>(
        builder: (BuildContext context, ApprovalState state) {
          return Semantics(
            identifier: 'approval.overlay',
            container: true,
            namesRoute: true,
            label: l10n.approvalModalLabel,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.sectionGap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    l10n.approvalTitle,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppTheme.smallGap),
                  Text(
                    l10n.approvalDescription,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppTheme.sectionGap),
                  _SensitiveRequestDetails(state: state),
                  const SizedBox(height: AppTheme.itemGap),
                  _ReferenceField(reference: state.request.reference),
                  if (state.failure case final failure?) ...<Widget>[
                    const SizedBox(height: AppTheme.itemGap),
                    _ApprovalError(failure: failure),
                  ],
                  const SizedBox(height: AppTheme.sectionGap),
                  _ApprovalActions(state: state),
                ],
              ),
            ),
          );
        },
      ),
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
        ? PaymentMoney.formatAed(request.amount)
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
