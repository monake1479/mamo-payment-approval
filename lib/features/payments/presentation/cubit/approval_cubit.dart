import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/authentication/device_authenticator.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';

typedef ApprovalDecisionCallback = Future<PaymentsResult<Payment>> Function({
  required String paymentId,
  required PaymentDecision decision,
});

enum ApprovalPhase { ready, authenticating, submitting, completed }

enum ApprovalAuthenticationFailure { cancelled, unavailable, failed }

sealed class ApprovalFailure {
  const ApprovalFailure();
}

final class ApprovalAuthenticationError extends ApprovalFailure {
  const ApprovalAuthenticationError(this.reason);

  final ApprovalAuthenticationFailure reason;
}

final class ApprovalDecisionError extends ApprovalFailure {
  const ApprovalDecisionError(this.failure);

  final PaymentsFailure failure;
}

final class ApprovalState {
  const ApprovalState({
    required this.request,
    required this.phase,
    required this.isRevealed,
    required this.failure,
    required this.completedDecision,
  });

  factory ApprovalState.initial(Payment request) => ApprovalState(
    request: request,
    phase: ApprovalPhase.ready,
    isRevealed: false,
    failure: null,
    completedDecision: null,
  );

  final Payment request;
  final ApprovalPhase phase;
  final bool isRevealed;
  final ApprovalFailure? failure;
  final PaymentDecision? completedDecision;

  bool get isBusy =>
      phase == ApprovalPhase.authenticating ||
      phase == ApprovalPhase.submitting;
  bool get canReveal => phase == ApprovalPhase.ready && !isRevealed;
  bool get canApprove => phase == ApprovalPhase.ready && isRevealed;
  bool get canReject => phase == ApprovalPhase.ready;

  ApprovalState copyWith({
    ApprovalPhase? phase,
    bool? isRevealed,
    Object? failure = _unchanged,
    Object? completedDecision = _unchanged,
  }) => ApprovalState(
    request: request,
    phase: phase ?? this.phase,
    isRevealed: isRevealed ?? this.isRevealed,
    failure: identical(failure, _unchanged)
        ? this.failure
        : failure as ApprovalFailure?,
    completedDecision: identical(completedDecision, _unchanged)
        ? this.completedDecision
        : completedDecision as PaymentDecision?,
  );

  static const Object _unchanged = Object();
}

final class ApprovalCubit extends Cubit<ApprovalState> {
  factory ApprovalCubit({
    required Payment request,
    required DeviceAuthenticator authenticator,
    required ApprovalDecisionCallback decide,
  }) => ApprovalCubit._(request, authenticator, decide);

  ApprovalCubit._(Payment request, this._authenticator, this._decide)
    : super(ApprovalState.initial(request));

  final DeviceAuthenticator _authenticator;
  final ApprovalDecisionCallback _decide;
  int _authenticationGeneration = 0;
  int _decisionGeneration = 0;

  Future<void> reveal({required String localizedReason}) async {
    if (isClosed || !state.canReveal) {
      return;
    }
    final int generation = ++_authenticationGeneration;
    emit(state.copyWith(phase: ApprovalPhase.authenticating, failure: null));
    final DeviceAuthenticationResult result = await _authenticator.authenticate(
      localizedReason: localizedReason,
    );
    if (!_isCurrentAuthentication(generation)) {
      return;
    }
    switch (result) {
      case DeviceAuthenticationSucceeded():
        emit(
          state.copyWith(
            phase: ApprovalPhase.ready,
            isRevealed: true,
            failure: null,
          ),
        );
      case DeviceAuthenticationCancelled():
        _authenticationFailed(ApprovalAuthenticationFailure.cancelled);
      case DeviceAuthenticationUnavailable():
        _authenticationFailed(ApprovalAuthenticationFailure.unavailable);
      case DeviceAuthenticationFailed():
        _authenticationFailed(ApprovalAuthenticationFailure.failed);
    }
  }

  Future<void> approve() => _submit(PaymentDecision.approve);

  Future<void> reject() => _submit(PaymentDecision.reject);

  Future<void> backgrounded() async {
    if (isClosed || state.phase == ApprovalPhase.completed) {
      return;
    }
    final bool wasAuthenticating = state.phase == ApprovalPhase.authenticating;
    _authenticationGeneration += 1;
    emit(
      state.copyWith(
        phase: wasAuthenticating ? ApprovalPhase.ready : state.phase,
        isRevealed: false,
        failure: wasAuthenticating ? null : state.failure,
      ),
    );
    if (!wasAuthenticating) {
      return;
    }
    final DeviceAuthenticationCancellationResult cancellation =
        await _authenticator.cancel();
    if (isClosed || state.phase != ApprovalPhase.ready || state.isRevealed) {
      return;
    }
    switch (cancellation) {
      case DeviceAuthenticationCancellationResult.noActiveAttempt:
      case DeviceAuthenticationCancellationResult.promptStopped:
        return;
      case DeviceAuthenticationCancellationResult.promptStopFailed:
        emit(
          state.copyWith(
            failure: const ApprovalAuthenticationError(
              ApprovalAuthenticationFailure.failed,
            ),
          ),
        );
    }
  }

  Future<void> _submit(PaymentDecision decision) async {
    if (isClosed || state.phase != ApprovalPhase.ready) {
      return;
    }
    if (decision == PaymentDecision.approve && !state.isRevealed) {
      return;
    }
    final int generation = ++_decisionGeneration;
    emit(state.copyWith(phase: ApprovalPhase.submitting, failure: null));
    final PaymentsResult<Payment> result = await _decide(
      paymentId: state.request.id,
      decision: decision,
    );
    if (isClosed || generation != _decisionGeneration) {
      return;
    }
    switch (result) {
      case PaymentsSuccess<Payment>():
        emit(
          state.copyWith(
            phase: ApprovalPhase.completed,
            isRevealed: false,
            failure: null,
            completedDecision: decision,
          ),
        );
      case PaymentsError<Payment>(:final failure):
        emit(
          state.copyWith(
            phase: ApprovalPhase.ready,
            failure: ApprovalDecisionError(failure),
          ),
        );
    }
  }

  void _authenticationFailed(ApprovalAuthenticationFailure failure) {
    emit(
      state.copyWith(
        phase: ApprovalPhase.ready,
        isRevealed: false,
        failure: ApprovalAuthenticationError(failure),
      ),
    );
  }

  bool _isCurrentAuthentication(int generation) =>
      !isClosed &&
      generation == _authenticationGeneration &&
      state.phase == ApprovalPhase.authenticating;

  @override
  Future<void> close() async {
    _authenticationGeneration += 1;
    _decisionGeneration += 1;
    if (state.phase == ApprovalPhase.authenticating) {
      final DeviceAuthenticationCancellationResult cancellation =
          await _authenticator.cancel();
      switch (cancellation) {
        case DeviceAuthenticationCancellationResult.noActiveAttempt:
        case DeviceAuthenticationCancellationResult.promptStopped:
        case DeviceAuthenticationCancellationResult.promptStopFailed:
          break;
      }
    }
    return super.close();
  }
}
