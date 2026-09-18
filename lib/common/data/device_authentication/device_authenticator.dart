import 'package:mamo_payment_approval_challenge/common/data/device_authentication/models/device_authentication_cancellation_result.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/device_authentication_failure.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/unit.dart';

abstract interface class DeviceAuthenticator {
  Future<Result<DeviceAuthenticationFailure, Unit>> authenticate({
    required String localizedReason,
  });

  Future<DeviceAuthenticationCancellationResult> cancel();
}
