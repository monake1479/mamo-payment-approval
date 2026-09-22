// The device-authentication options are passed explicitly as a fixed security
// posture; they must not silently depend on the plugin's default values, which
// this file's argument redundancy lint would otherwise push us to drop.
// ignore_for_file: avoid_redundant_argument_values
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mamo_approval/common/data/device_authentication/error_handling/device_authentication_failure.dart';
import 'package:mamo_approval/common/data/device_authentication/models/device_authentication_cancellation_result.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:mamo_approval/common/result/models/unit.dart';

/// Device-authentication data source over the `local_auth` plugin.
///
/// This is the single concrete data source (like `PaymentsRemoteDataSource`). It
/// owns the SDK calls and translates plugin exceptions into typed results, so
/// the repository never handles raw plugin exceptions. The plugin is injected so
/// the mapping can be unit tested with a fake.
@lazySingleton
class LocalAuthClient {
  const LocalAuthClient(this._localAuthentication);

  final LocalAuthentication _localAuthentication;

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuthentication.isDeviceSupported();
    } on Exception {
      return false;
    }
  }

  Future<Result<DeviceAuthenticationFailure, Unit>> authenticate({
    required String localizedReason,
  }) async {
    try {
      // Pass the security-relevant options explicitly so the posture is fixed
      // regardless of the plugin's defaults: allow the OS credential
      // (biometricOnly false), mark the operation sensitive, and never persist
      // authentication across backgrounding. `local_auth_client_test` asserts
      // these forwarded values.
      final authenticated = await _localAuthentication.authenticate(
        localizedReason: localizedReason,
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: false,
      );
      return authenticated
          ? const Result<DeviceAuthenticationFailure, Unit>.success(unit)
          : const Result<DeviceAuthenticationFailure, Unit>.failure(
              DeviceAuthenticationFailure.failed(),
            );
    } on LocalAuthException catch (exception) {
      return Result<DeviceAuthenticationFailure, Unit>.failure(
        _mapExceptionCode(exception.code),
      );
    } on PlatformException {
      return const Result<DeviceAuthenticationFailure, Unit>.failure(
        DeviceAuthenticationFailure.failed(),
      );
    } on Exception {
      return const Result<DeviceAuthenticationFailure, Unit>.failure(
        DeviceAuthenticationFailure.failed(),
      );
    }
  }

  Future<DeviceAuthenticationCancellationResult> stopAuthentication() async {
    try {
      final stopped = await _localAuthentication.stopAuthentication();
      return stopped
          ? DeviceAuthenticationCancellationResult.promptStopped
          : DeviceAuthenticationCancellationResult.promptStopFailed;
    } on Exception {
      return DeviceAuthenticationCancellationResult.promptStopFailed;
    }
  }

  static DeviceAuthenticationFailure _mapExceptionCode(
    LocalAuthExceptionCode code,
  ) {
    switch (code) {
      case LocalAuthExceptionCode.userCanceled:
      case LocalAuthExceptionCode.systemCanceled:
      case LocalAuthExceptionCode.timeout:
        return const DeviceAuthenticationFailure.cancelled();
      case LocalAuthExceptionCode.noCredentialsSet:
      case LocalAuthExceptionCode.noBiometricsEnrolled:
      case LocalAuthExceptionCode.noBiometricHardware:
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
      case LocalAuthExceptionCode.uiUnavailable:
        return const DeviceAuthenticationFailure.unavailable();
      default:
        return const DeviceAuthenticationFailure.failed();
    }
  }
}
