import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/features/payments/states/approval/approval_failure.dart';

part 'approval_state.freezed.dart';

enum ApprovalPhase { ready, authenticating, submitting, completed }

@freezed
abstract class ApprovalState with _$ApprovalState {
  const ApprovalState._();

  const factory ApprovalState({
    required Payment request,
    required ApprovalPhase phase,
    required bool isRevealed,
    required ApprovalFailure? failure,
    required PaymentDecision? completedDecision,
  }) = _ApprovalState;

  factory ApprovalState.initial(Payment request) => ApprovalState(
    request: request,
    phase: ApprovalPhase.ready,
    isRevealed: false,
    failure: null,
    completedDecision: null,
  );

  bool get isBusy =>
      phase == ApprovalPhase.authenticating ||
      phase == ApprovalPhase.submitting;
  bool get canReveal => phase == ApprovalPhase.ready && !isRevealed;
  bool get canApprove => phase == ApprovalPhase.ready && isRevealed;
  bool get canReject => phase == ApprovalPhase.ready;
}
