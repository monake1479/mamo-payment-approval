import 'package:local_auth/local_auth.dart';

abstract interface class LocalAuthClient {
  Future<bool> isDeviceSupported();

  Future<bool> authenticate({
    required String localizedReason,
    required bool biometricOnly,
    required bool sensitiveTransaction,
    required bool persistAcrossBackgrounding,
  });

  Future<bool> stopAuthentication();
}

final class PluginLocalAuthClient implements LocalAuthClient {
  PluginLocalAuthClient({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  @override
  Future<bool> isDeviceSupported() => _localAuthentication.isDeviceSupported();

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required bool biometricOnly,
    required bool sensitiveTransaction,
    required bool persistAcrossBackgrounding,
  }) => _localAuthentication.authenticate(
    localizedReason: localizedReason,
    biometricOnly: biometricOnly,
    sensitiveTransaction: sensitiveTransaction,
    persistAcrossBackgrounding: persistAcrossBackgrounding,
  );

  @override
  Future<bool> stopAuthentication() =>
      _localAuthentication.stopAuthentication();
}
