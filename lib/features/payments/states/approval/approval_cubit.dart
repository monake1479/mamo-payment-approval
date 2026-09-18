import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/device_authenticator.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/models/device_authentication_cancellation_result.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/device_authentication_failure.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/unit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/approval/approval_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/approval/approval_state.dart';

typedef ApprovalDecisionCallback =
    Future<Result<PaymentsFailure, Payment>> Function({
      required String paymentId,
      required PaymentDecision decision,
    });

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
    final Result<DeviceAuthenticationFailure, Unit> result =
        await _authenticator.authenticate(localizedReason: localizedReason);
    if (!_isCurrentAuthentication(generation)) {
      return;
    }
    switch (result) {
      case Success<DeviceAuthenticationFailure, Unit>():
        emit(
          state.copyWith(
            phase: ApprovalPhase.ready,
            isRevealed: true,
            failure: null,
          ),
        );
      case Failure<DeviceAuthenticationFailure, Unit>(:final failure):
        _authenticationFailed(failure);
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
              DeviceAuthenticationFailure.failed(),
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
    final Result<PaymentsFailure, Payment> result = await _decide(
      paymentId: state.request.id,
      decision: decision,
    );
    if (isClosed || generation != _decisionGeneration) {
      return;
    }
    switch (result) {
      case Success<PaymentsFailure, Payment>():
        emit(
          state.copyWith(
            phase: ApprovalPhase.completed,
            isRevealed: false,
            failure: null,
            completedDecision: decision,
          ),
        );
      case Failure<PaymentsFailure, Payment>(:final failure):
        emit(
          state.copyWith(
            phase: ApprovalPhase.ready,
            failure: ApprovalDecisionError(failure),
          ),
        );
    }
  }

  void _authenticationFailed(DeviceAuthenticationFailure failure) {
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
