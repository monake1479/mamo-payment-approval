import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mamo_payment_approval_challenge/features/payments/data/authentication/local_auth_client.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/authentication/device_authenticator.dart';

final class LocalAuthDeviceAuthenticator implements DeviceAuthenticator {
  LocalAuthDeviceAuthenticator({LocalAuthClient? client})
    : _client = client ?? PluginLocalAuthClient();

  final LocalAuthClient _client;

  int _nextAttempt = 0;
  int? _inFlightAttempt;
  int? _activeAttempt;
  Future<DeviceAuthenticationCancellationResult>? _cancellationInProgress;

  @override
  Future<DeviceAuthenticationResult> authenticate({
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
      return const DeviceAuthenticationFailed();
    }

    final attempt = ++_nextAttempt;
    _inFlightAttempt = attempt;
    _activeAttempt = attempt;
    try {
      final supported = await _client.isDeviceSupported();
      if (!_isCurrent(attempt)) {
        return const DeviceAuthenticationCancelled();
      }
      if (!supported) {
        return const DeviceAuthenticationUnavailable();
      }

      final authenticated = await _client.authenticate(
        localizedReason: localizedReason,
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: false,
      );
      if (!_isCurrent(attempt)) {
        return const DeviceAuthenticationCancelled();
      }
      return authenticated
          ? const DeviceAuthenticationSucceeded()
          : const DeviceAuthenticationFailed();
    } on LocalAuthException catch (exception) {
      if (!_isCurrent(attempt)) {
        return const DeviceAuthenticationCancelled();
      }
      return _mapException(exception.code);
    } on PlatformException {
      if (!_isCurrent(attempt)) {
        return const DeviceAuthenticationCancelled();
      }
      return const DeviceAuthenticationFailed();
    } on Exception {
      if (!_isCurrent(attempt)) {
        return const DeviceAuthenticationCancelled();
      }
      return const DeviceAuthenticationFailed();
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

  DeviceAuthenticationResult _mapException(LocalAuthExceptionCode code) {
    switch (code) {
      case LocalAuthExceptionCode.userCanceled:
      case LocalAuthExceptionCode.systemCanceled:
      case LocalAuthExceptionCode.timeout:
        return const DeviceAuthenticationCancelled();
      case LocalAuthExceptionCode.noCredentialsSet:
      case LocalAuthExceptionCode.noBiometricsEnrolled:
      case LocalAuthExceptionCode.noBiometricHardware:
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
      case LocalAuthExceptionCode.uiUnavailable:
        return const DeviceAuthenticationUnavailable();
      default:
        return const DeviceAuthenticationFailed();
    }
  }
}
