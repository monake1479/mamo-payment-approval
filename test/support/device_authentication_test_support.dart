import 'dart:async';

import 'package:local_auth/local_auth.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/data_sources/local_auth_client.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/error_handling/device_authentication_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/models/device_authentication_cancellation_result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/unit.dart';

/// Fakes the `local_auth` plugin so `LocalAuthClient`'s SDK-exception mapping can
/// be unit tested. Drive it to return values or throw plugin exceptions.
final class FakeLocalAuthentication implements LocalAuthentication {
  FakeLocalAuthentication({
    this.isSupported = true,
    this.authenticateResult = true,
    this.stopResult = true,
    this.isSupportedError,
    this.authenticateError,
    this.stopError,
  });

  final bool isSupported;
  final bool authenticateResult;
  final bool stopResult;
  final Object? isSupportedError;
  final Object? authenticateError;
  final Object? stopError;

  String? localizedReason;
  bool? biometricOnly;
  bool? sensitiveTransaction;
  bool? persistAcrossBackgrounding;

  @override
  Future<bool> isDeviceSupported() async {
    if (isSupportedError case final error?) {
      throw error;
    }
    return isSupported;
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<AuthMessages> authMessages = const <AuthMessages>[],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async {
    this.localizedReason = localizedReason;
    this.biometricOnly = biometricOnly;
    this.sensitiveTransaction = sensitiveTransaction;
    this.persistAcrossBackgrounding = persistAcrossBackgrounding;
    if (authenticateError case final error?) {
      throw error;
    }
    return authenticateResult;
  }

  @override
  Future<bool> stopAuthentication() async {
    if (stopError case final error?) {
      throw error;
    }
    return stopResult;
  }

  @override
  Future<bool> get canCheckBiometrics => throw UnimplementedError();

  @override
  Future<List<BiometricType>> getAvailableBiometrics() =>
      throw UnimplementedError();
}

/// Fakes the device-authentication data source at the typed boundary so
/// `LocalAuthRepository`'s state machine can be tested without the plugin. It
/// returns already-mapped results and can defer them with completers.
final class FakeLocalAuthClient extends LocalAuthClient {
  FakeLocalAuthClient({
    this.isSupported = true,
    Result<DeviceAuthenticationFailure, Unit>? authenticateResult,
    this.authenticateCompletion,
    this.stopResult = DeviceAuthenticationCancellationResult.promptStopped,
    this.stopCompletion,
  }) : authenticateResult =
           authenticateResult ??
           const Result<DeviceAuthenticationFailure, Unit>.success(unit),
       super(FakeLocalAuthentication());

  bool isSupported;
  Result<DeviceAuthenticationFailure, Unit> authenticateResult;
  Completer<Result<DeviceAuthenticationFailure, Unit>>? authenticateCompletion;
  DeviceAuthenticationCancellationResult stopResult;
  Completer<DeviceAuthenticationCancellationResult>? stopCompletion;

  int isDeviceSupportedCallCount = 0;
  int authenticateCallCount = 0;
  int stopAuthenticationCallCount = 0;
  String? localizedReason;
  final Completer<void> authenticationStartedCompleter = Completer<void>();
  final Completer<void> stopStartedCompleter = Completer<void>();

  Future<void> get authenticationStarted =>
      authenticationStartedCompleter.future;
  Future<void> get stopStarted => stopStartedCompleter.future;

  @override
  Future<bool> isDeviceSupported() async {
    isDeviceSupportedCallCount++;
    return isSupported;
  }

  @override
  Future<Result<DeviceAuthenticationFailure, Unit>> authenticate({
    required String localizedReason,
  }) async {
    authenticateCallCount++;
    this.localizedReason = localizedReason;
    if (!authenticationStartedCompleter.isCompleted) {
      authenticationStartedCompleter.complete();
    }
    if (authenticateCompletion case final completion?) {
      return completion.future;
    }
    return authenticateResult;
  }

  @override
  Future<DeviceAuthenticationCancellationResult> stopAuthentication() async {
    stopAuthenticationCallCount++;
    if (!stopStartedCompleter.isCompleted) {
      stopStartedCompleter.complete();
    }
    if (stopCompletion case final completion?) {
      return completion.future;
    }
    return stopResult;
  }
}
