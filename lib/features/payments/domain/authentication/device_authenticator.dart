sealed class DeviceAuthenticationResult {
  const DeviceAuthenticationResult();
}

final class DeviceAuthenticationSucceeded extends DeviceAuthenticationResult {
  const DeviceAuthenticationSucceeded();
}

final class DeviceAuthenticationCancelled extends DeviceAuthenticationResult {
  const DeviceAuthenticationCancelled();
}

final class DeviceAuthenticationUnavailable extends DeviceAuthenticationResult {
  const DeviceAuthenticationUnavailable();
}

final class DeviceAuthenticationFailed extends DeviceAuthenticationResult {
  const DeviceAuthenticationFailed();
}

enum DeviceAuthenticationCancellationResult {
  noActiveAttempt,
  promptStopped,
  promptStopFailed,
}

abstract interface class DeviceAuthenticator {
  Future<DeviceAuthenticationResult> authenticate({
    required String localizedReason,
  });

  Future<DeviceAuthenticationCancellationResult> cancel();
}
