import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/device_authenticator.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/local_auth_client.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/models/device_authentication_cancellation_result.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/device_authentication_failure.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/unit.dart';

@LazySingleton(as: DeviceAuthenticator)
final class LocalAuthDeviceAuthenticator implements DeviceAuthenticator {
  LocalAuthDeviceAuthenticator({@ignoreParam LocalAuthClient? client})
    : _client = client ?? PluginLocalAuthClient();

  final LocalAuthClient _client;

  int _nextAttempt = 0;
  int? _inFlightAttempt;
  int? _activeAttempt;
  Future<DeviceAuthenticationCancellationResult>? _cancellationInProgress;

  @override
  Future<Result<DeviceAuthenticationFailure, Unit>> authenticate({
    required String localizedReason,
  }) async {
    if (localizedReason.trim().isEmpty) {
      throw ArgumentError.value(
        localizedReason,
        'localizedReason',
        'The device authentication prompt reason must not be empty.',
      );
    }
    if (_inFlightAttempt != null || _cancellationInProgress != null) {
      return const Result<DeviceAuthenticationFailure, Unit>.failure(
        DeviceAuthenticationFailure.failed(),
      );
    }

    final attempt = ++_nextAttempt;
    _inFlightAttempt = attempt;
    _activeAttempt = attempt;
    try {
      final supported = await _client.isDeviceSupported();
      if (!_isCurrent(attempt)) {
        return const Result<DeviceAuthenticationFailure, Unit>.failure(
          DeviceAuthenticationFailure.cancelled(),
        );
      }
      if (!supported) {
        return const Result<DeviceAuthenticationFailure, Unit>.failure(
          DeviceAuthenticationFailure.unavailable(),
        );
      }

      final authenticated = await _client.authenticate(
        localizedReason: localizedReason,
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: false,
      );
      if (!_isCurrent(attempt)) {
        return const Result<DeviceAuthenticationFailure, Unit>.failure(
          DeviceAuthenticationFailure.cancelled(),
        );
      }
      return authenticated
          ? const Result<DeviceAuthenticationFailure, Unit>.success(unit)
          : const Result<DeviceAuthenticationFailure, Unit>.failure(
              DeviceAuthenticationFailure.failed(),
            );
    } on LocalAuthException catch (exception) {
      if (!_isCurrent(attempt)) {
        return const Result<DeviceAuthenticationFailure, Unit>.failure(
          DeviceAuthenticationFailure.cancelled(),
        );
      }
      return _mapException(exception.code);
    } on PlatformException {
      if (!_isCurrent(attempt)) {
        return const Result<DeviceAuthenticationFailure, Unit>.failure(
          DeviceAuthenticationFailure.cancelled(),
        );
      }
      return const Result<DeviceAuthenticationFailure, Unit>.failure(
        DeviceAuthenticationFailure.failed(),
      );
    } on Exception {
      if (!_isCurrent(attempt)) {
        return const Result<DeviceAuthenticationFailure, Unit>.failure(
          DeviceAuthenticationFailure.cancelled(),
        );
      }
      return const Result<DeviceAuthenticationFailure, Unit>.failure(
        DeviceAuthenticationFailure.failed(),
      );
    } finally {
      if (_isCurrent(attempt)) {
        _activeAttempt = null;
      }
      if (_inFlightAttempt == attempt) {
        _inFlightAttempt = null;
      }
    }
  }

  @override
  Future<DeviceAuthenticationCancellationResult> cancel() async {
    if (_cancellationInProgress case final cancellation?) {
      return cancellation;
    }
    if (_activeAttempt == null) {
      return DeviceAuthenticationCancellationResult.noActiveAttempt;
    }

    // Invalidate first: stopping the native prompt is best effort, while a late
    // completion must never become a successful disclosure authorization.
    _activeAttempt = null;
    _nextAttempt++;
    final cancellation = _stopAuthentication();
    _cancellationInProgress = cancellation;
    try {
      return await cancellation;
    } finally {
      if (identical(_cancellationInProgress, cancellation)) {
        _cancellationInProgress = null;
      }
    }
  }

  bool _isCurrent(int attempt) => _activeAttempt == attempt;

  Future<DeviceAuthenticationCancellationResult> _stopAuthentication() async {
    try {
      final stopped = await _client.stopAuthentication();
      return stopped
          ? DeviceAuthenticationCancellationResult.promptStopped
          : DeviceAuthenticationCancellationResult.promptStopFailed;
    } on LocalAuthException {
      return DeviceAuthenticationCancellationResult.promptStopFailed;
    } on PlatformException {
      return DeviceAuthenticationCancellationResult.promptStopFailed;
    } on Exception {
      return DeviceAuthenticationCancellationResult.promptStopFailed;
    }
  }

  Result<DeviceAuthenticationFailure, Unit> _mapException(
    LocalAuthExceptionCode code,
  ) {
    switch (code) {
      case LocalAuthExceptionCode.userCanceled:
      case LocalAuthExceptionCode.systemCanceled:
      case LocalAuthExceptionCode.timeout:
        return const Result<DeviceAuthenticationFailure, Unit>.failure(
          DeviceAuthenticationFailure.cancelled(),
        );
      case LocalAuthExceptionCode.noCredentialsSet:
      case LocalAuthExceptionCode.noBiometricsEnrolled:
      case LocalAuthExceptionCode.noBiometricHardware:
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
      case LocalAuthExceptionCode.uiUnavailable:
        return const Result<DeviceAuthenticationFailure, Unit>.failure(
          DeviceAuthenticationFailure.unavailable(),
        );
      default:
        return const Result<DeviceAuthenticationFailure, Unit>.failure(
          DeviceAuthenticationFailure.failed(),
        );
    }
  }
}
