import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/device_authentication_failure.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/payments_failure.dart';

part 'approval_failure.freezed.dart';

@freezed
sealed class ApprovalFailure with _$ApprovalFailure {
  const factory ApprovalFailure.authentication(
    DeviceAuthenticationFailure reason,
  ) = ApprovalAuthenticationError;

  const factory ApprovalFailure.decision(PaymentsFailure failure) =
      ApprovalDecisionError;
}
