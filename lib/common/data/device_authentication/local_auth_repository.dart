import 'package:injectable/injectable.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/data_sources/local_auth_client.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/error_handling/device_authentication_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/models/device_authentication_cancellation_result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/unit.dart';

/// Coordinates native device authentication over the [LocalAuthClient] data
/// source.
///
/// The data source owns SDK calls and exception translation; this repository
/// owns only the cross-call occupancy/cancellation state machine and caches the
/// device-support capability. That state machine guarantees a late completion
/// can never be reported as a successful disclosure after invalidation, and a
/// new attempt is rejected while a prior one is still settling.
///
/// The in-flight/stale-completion coordination lives here as an interim owner
/// because this slice has no UI; it will move to the approval state owner (a
/// Cubit) once that exists. Authentication results are never cached.
@lazySingleton
class LocalAuthRepository {
  LocalAuthRepository(this._client);

  final LocalAuthClient _client;

  int _nextAttempt = 0;
  int? _inFlightAttempt;
  int? _activeAttempt;
  Future<DeviceAuthenticationCancellationResult>? _cancellationInProgress;
  bool? _isSupportedCache;

  Future<bool> isSupported() => _cachedSupport();

  Future<Result<DeviceAuthenticationFailure, Unit>> authenticate({
    required String localizedReason,
  }) async {
    if (_inFlightAttempt != null || _cancellationInProgress != null) {
      return const Result<DeviceAuthenticationFailure, Unit>.failure(
        DeviceAuthenticationFailure.failed(),
      );
    }

    final attempt = ++_nextAttempt;
    _inFlightAttempt = attempt;
    _activeAttempt = attempt;
    try {
      final supported = await _cachedSupport();
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

      final result = await _client.authenticate(
        localizedReason: localizedReason,
      );
      if (!_isCurrent(attempt)) {
        return const Result<DeviceAuthenticationFailure, Unit>.failure(
          DeviceAuthenticationFailure.cancelled(),
        );
      }
      return result;
    } finally {
      if (_isCurrent(attempt)) {
        _activeAttempt = null;
      }
      if (_inFlightAttempt == attempt) {
        _inFlightAttempt = null;
      }
    }
  }

  Future<DeviceAuthenticationCancellationResult> stop() async {
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
    final cancellation = _client.stopAuthentication();
    _cancellationInProgress = cancellation;
    try {
      return await cancellation;
    } finally {
      if (identical(_cancellationInProgress, cancellation)) {
        _cancellationInProgress = null;
      }
    }
  }

  Future<bool> _cachedSupport() async {
    if (_isSupportedCache case final cached?) {
      return cached;
    }
    final supported = await _client.isDeviceSupported();
    // Cache only a confirmed positive: support is stable once present, while a
    // negative or failed probe must be re-checked so a transient probe failure
    // cannot strand the capability and a later credential enrolment is seen.
    if (supported) {
      _isSupportedCache = true;
    }
    return supported;
  }

  bool _isCurrent(int attempt) => _activeAttempt == attempt;
}
