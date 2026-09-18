import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/local_auth_client.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/local_auth_device_authenticator.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/models/device_authentication_cancellation_result.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/device_authentication_failure.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/unit.dart';

const Result<DeviceAuthenticationFailure, Unit> _succeeded =
    Result<DeviceAuthenticationFailure, Unit>.success(unit);
const Result<DeviceAuthenticationFailure, Unit> _cancelled =
    Result<DeviceAuthenticationFailure, Unit>.failure(
      DeviceAuthenticationFailure.cancelled(),
    );
const Result<DeviceAuthenticationFailure, Unit> _unavailable =
    Result<DeviceAuthenticationFailure, Unit>.failure(
      DeviceAuthenticationFailure.unavailable(),
    );
const Result<DeviceAuthenticationFailure, Unit> _failed =
    Result<DeviceAuthenticationFailure, Unit>.failure(
      DeviceAuthenticationFailure.failed(),
    );

void main() {
  test('device authentication failures expose stable safe codes', () {
    expect(
      const DeviceAuthenticationFailure.cancelled().code,
      'authentication.cancelled',
    );
    expect(
      const DeviceAuthenticationFailure.unavailable().code,
      'authentication.unavailable',
    );
    expect(
      const DeviceAuthenticationFailure.failed().code,
      'authentication.failed',
    );
  });

  group('LocalAuthDeviceAuthenticator', () {
    test(
      'allows biometrics or device credentials with a localized prompt',
      () async {
        final client = _FakeLocalAuthClient();
        final authenticator = LocalAuthDeviceAuthenticator(client: client);

        final result = await authenticator.authenticate(
          localizedReason: 'Authenticate to reveal payment details.',
        );

        expect(result, _succeeded);
        expect(client.authenticateCallCount, 1);
        expect(
          client.localizedReason,
          'Authenticate to reveal payment details.',
        );
        expect(client.biometricOnly, isFalse);
        expect(client.sensitiveTransaction, isTrue);
        expect(client.persistAcrossBackgrounding, isFalse);
      },
    );

    test(
      'returns unavailable without showing a prompt on an unsupported device',
      () async {
        final client = _FakeLocalAuthClient(isSupported: false);
        final authenticator = LocalAuthDeviceAuthenticator(client: client);

        final result = await authenticator.authenticate(
          localizedReason: 'Localized reason',
        );

        expect(result, _unavailable);
        expect(client.authenticateCallCount, 0);
      },
    );

    test('maps a false native result to failed', () async {
      final authenticator = LocalAuthDeviceAuthenticator(
        client: _FakeLocalAuthClient(authenticateResult: false),
      );

      final result = await authenticator.authenticate(
        localizedReason: 'Localized reason',
      );

      expect(result, _failed);
    });

    for (final code in <LocalAuthExceptionCode>[
      LocalAuthExceptionCode.userCanceled,
      LocalAuthExceptionCode.systemCanceled,
      LocalAuthExceptionCode.timeout,
    ]) {
      test('maps ${code.name} to cancelled', () async {
        final authenticator = LocalAuthDeviceAuthenticator(
          client: _FakeLocalAuthClient(exceptionCode: code),
        );

        final result = await authenticator.authenticate(
          localizedReason: 'Localized reason',
        );

        expect(result, _cancelled);
      });
    }

    for (final code in <LocalAuthExceptionCode>[
      LocalAuthExceptionCode.noCredentialsSet,
      LocalAuthExceptionCode.noBiometricsEnrolled,
      LocalAuthExceptionCode.noBiometricHardware,
      LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable,
      LocalAuthExceptionCode.uiUnavailable,
    ]) {
      test('maps ${code.name} to unavailable', () async {
        final authenticator = LocalAuthDeviceAuthenticator(
          client: _FakeLocalAuthClient(exceptionCode: code),
        );

        final result = await authenticator.authenticate(
          localizedReason: 'Localized reason',
        );

        expect(result, _unavailable);
      });
    }

    for (final code in <LocalAuthExceptionCode>[
      LocalAuthExceptionCode.authInProgress,
      LocalAuthExceptionCode.temporaryLockout,
      LocalAuthExceptionCode.biometricLockout,
      LocalAuthExceptionCode.userRequestedFallback,
      LocalAuthExceptionCode.deviceError,
      LocalAuthExceptionCode.unknownError,
    ]) {
      test('maps ${code.name} to failed', () async {
        final authenticator = LocalAuthDeviceAuthenticator(
          client: _FakeLocalAuthClient(exceptionCode: code),
        );

        final result = await authenticator.authenticate(
          localizedReason: 'Localized reason',
        );

        expect(result, _failed);
      });
    }

    test('maps an unexpected platform exception to failed', () async {
      final authenticator = LocalAuthDeviceAuthenticator(
        client: _FakeLocalAuthClient(
          platformException: PlatformException(code: 'unexpected'),
        ),
      );

      final result = await authenticator.authenticate(
        localizedReason: 'Localized reason',
      );

      expect(result, _failed);
    });

    test('maps a missing plugin exception to failed', () async {
      final authenticator = LocalAuthDeviceAuthenticator(
        client: _FakeLocalAuthClient(
          missingPluginException: MissingPluginException(),
        ),
      );

      final result = await authenticator.authenticate(
        localizedReason: 'Localized reason',
      );

      expect(result, _failed);
    });

    test('does not hide programmer errors from the plugin boundary', () async {
      final authenticator = LocalAuthDeviceAuthenticator(
        client: _FakeLocalAuthClient(programmerError: StateError('fixture')),
      );

      await expectLater(
        authenticator.authenticate(localizedReason: 'Localized reason'),
        throwsStateError,
      );
    });

    test('rejects an empty prompt before calling the plugin', () async {
      final client = _FakeLocalAuthClient();
      final authenticator = LocalAuthDeviceAuthenticator(client: client);

      await expectLater(
        authenticator.authenticate(localizedReason: '  '),
        throwsArgumentError,
      );
      expect(client.isDeviceSupportedCallCount, 0);
    });

    test('does not start a duplicate authentication attempt', () async {
      final completion = Completer<bool>();
      final client = _FakeLocalAuthClient(authenticateCompletion: completion);
      final authenticator = LocalAuthDeviceAuthenticator(client: client);
      final first = authenticator.authenticate(localizedReason: 'First');
      await client.authenticationStarted;

      final duplicate = await authenticator.authenticate(
        localizedReason: 'Second',
      );

      expect(duplicate, _failed);
      expect(client.authenticateCallCount, 1);
      completion.complete(true);
      expect(await first, _succeeded);
    });

    test(
      'cancel invalidates a late successful result before stopping the prompt',
      () async {
        final completion = Completer<bool>();
        final client = _FakeLocalAuthClient(authenticateCompletion: completion);
        final authenticator = LocalAuthDeviceAuthenticator(client: client);
        final result = authenticator.authenticate(localizedReason: 'Reason');
        await client.authenticationStarted;

        final cancellation = await authenticator.cancel();
        completion.complete(true);

        expect(await result, _cancelled);
        expect(
          cancellation,
          DeviceAuthenticationCancellationResult.promptStopped,
        );
        expect(client.stopAuthenticationCallCount, 1);
      },
    );

    test(
      'normalizes a failed native prompt stop without restoring access',
      () async {
        final completion = Completer<bool>();
        final client = _FakeLocalAuthClient(
          authenticateCompletion: completion,
          stopAuthenticationResult: false,
        );
        final authenticator = LocalAuthDeviceAuthenticator(client: client);
        final result = authenticator.authenticate(localizedReason: 'Reason');
        await client.authenticationStarted;

        final cancellation = await authenticator.cancel();
        completion.complete(true);

        expect(
          cancellation,
          DeviceAuthenticationCancellationResult.promptStopFailed,
        );
        expect(await result, _cancelled);
      },
    );

    test(
      'normalizes a plugin exception while stopping the native prompt',
      () async {
        final completion = Completer<bool>();
        final client = _FakeLocalAuthClient(
          authenticateCompletion: completion,
          stopExceptionCode: LocalAuthExceptionCode.deviceError,
        );
        final authenticator = LocalAuthDeviceAuthenticator(client: client);
        final result = authenticator.authenticate(localizedReason: 'Reason');
        await client.authenticationStarted;

        final cancellation = await authenticator.cancel();
        completion.complete(true);

        expect(
          cancellation,
          DeviceAuthenticationCancellationResult.promptStopFailed,
        );
        expect(await result, _cancelled);
      },
    );

    test(
      'normalizes a platform exception while stopping the native prompt',
      () async {
        final completion = Completer<bool>();
        final client = _FakeLocalAuthClient(
          authenticateCompletion: completion,
          stopPlatformException: PlatformException(code: 'stop-failed'),
        );
        final authenticator = LocalAuthDeviceAuthenticator(client: client);
        final result = authenticator.authenticate(localizedReason: 'Reason');
        await client.authenticationStarted;

        final cancellation = await authenticator.cancel();
        completion.complete(true);

        expect(
          cancellation,
          DeviceAuthenticationCancellationResult.promptStopFailed,
        );
        expect(await result, _cancelled);
      },
    );

    test(
      'normalizes a missing plugin exception while stopping the native prompt',
      () async {
        final completion = Completer<bool>();
        final client = _FakeLocalAuthClient(
          authenticateCompletion: completion,
          stopMissingPluginException: MissingPluginException(),
        );
        final authenticator = LocalAuthDeviceAuthenticator(client: client);
        final result = authenticator.authenticate(localizedReason: 'Reason');
        await client.authenticationStarted;

        final cancellation = await authenticator.cancel();
        completion.complete(true);

        expect(
          cancellation,
          DeviceAuthenticationCancellationResult.promptStopFailed,
        );
        expect(await result, _cancelled);
      },
    );

    test(
      'does not start authentication while native cancellation is settling',
      () async {
        final authenticationCompletion = Completer<bool>();
        final stopCompletion = Completer<bool>();
        final client = _FakeLocalAuthClient(
          authenticateCompletion: authenticationCompletion,
          stopAuthenticationCompletion: stopCompletion,
        );
        final authenticator = LocalAuthDeviceAuthenticator(client: client);
        final first = authenticator.authenticate(localizedReason: 'First');
        await client.authenticationStarted;
        final cancellation = authenticator.cancel();
        await client.stopAuthenticationStarted;

        final overlapping = await authenticator.authenticate(
          localizedReason: 'Overlapping',
        );

        expect(overlapping, _failed);
        expect(client.authenticateCallCount, 1);
        stopCompletion.complete(true);
        expect(
          await cancellation,
          DeviceAuthenticationCancellationResult.promptStopped,
        );
        authenticationCompletion.complete(true);
        expect(await first, _cancelled);
        client.authenticateCompletion = null;
        final next = await authenticator.authenticate(localizedReason: 'Next');
        expect(next, _succeeded);
        expect(client.authenticateCallCount, 2);
      },
    );

    test(
      'shares one native stop across concurrent cancellation calls',
      () async {
        final authenticationCompletion = Completer<bool>();
        final stopCompletion = Completer<bool>();
        final client = _FakeLocalAuthClient(
          authenticateCompletion: authenticationCompletion,
          stopAuthenticationCompletion: stopCompletion,
        );
        final authenticator = LocalAuthDeviceAuthenticator(client: client);
        final authentication = authenticator.authenticate(
          localizedReason: 'Reason',
        );
        await client.authenticationStarted;

        final firstCancellation = authenticator.cancel();
        await client.stopAuthenticationStarted;
        final secondCancellation = authenticator.cancel();
        stopCompletion.complete(true);

        expect(
          await firstCancellation,
          DeviceAuthenticationCancellationResult.promptStopped,
        );
        expect(
          await secondCancellation,
          DeviceAuthenticationCancellationResult.promptStopped,
        );
        expect(client.stopAuthenticationCallCount, 1);
        authenticationCompletion.complete(true);
        expect(await authentication, _cancelled);
      },
    );

    test(
      'keeps native occupancy until a cancelled result settles when stop fails',
      () async {
        final firstCompletion = Completer<bool>();
        final client = _FakeLocalAuthClient(
          authenticateCompletion: firstCompletion,
          stopAuthenticationResult: false,
        );
        final authenticator = LocalAuthDeviceAuthenticator(client: client);
        final first = authenticator.authenticate(localizedReason: 'First');
        await client.authenticationStarted;

        expect(
          await authenticator.cancel(),
          DeviceAuthenticationCancellationResult.promptStopFailed,
        );
        final overlapping = await authenticator.authenticate(
          localizedReason: 'Overlapping',
        );

        expect(overlapping, _failed);
        expect(client.authenticateCallCount, 1);

        firstCompletion.complete(true);
        expect(await first, _cancelled);
        client.authenticateCompletion = null;
        final retry = await authenticator.authenticate(
          localizedReason: 'Retry',
        );

        expect(retry, _succeeded);
        expect(client.authenticateCallCount, 2);
      },
    );

    test('keeps native occupancy until a cancelled result settles when stop succeeds', () async {
      final firstCompletion = Completer<bool>();
      final client = _FakeLocalAuthClient(
        authenticateCompletion: firstCompletion,
      );
      final authenticator = LocalAuthDeviceAuthenticator(client: client);
      final first = authenticator.authenticate(localizedReason: 'First');
      await client.authenticationStarted;

      expect(
        await authenticator.cancel(),
        DeviceAuthenticationCancellationResult.promptStopped,
      );
      final overlapping = await authenticator.authenticate(
        localizedReason: 'Overlapping',
      );

      expect(overlapping, _failed);
      expect(client.authenticateCallCount, 1);

      firstCompletion.complete(true);
      expect(await first, _cancelled);
      client.authenticateCompletion = null;
      final retry = await authenticator.authenticate(localizedReason: 'Retry');

      expect(retry, _succeeded);
      expect(client.authenticateCallCount, 2);
    });

    test('keeps native occupancy until a cancelled result settles when stop throws', () async {
      final firstCompletion = Completer<bool>();
      final client = _FakeLocalAuthClient(
        authenticateCompletion: firstCompletion,
        stopExceptionCode: LocalAuthExceptionCode.deviceError,
      );
      final authenticator = LocalAuthDeviceAuthenticator(client: client);
      final first = authenticator.authenticate(localizedReason: 'First');
      await client.authenticationStarted;

      expect(
        await authenticator.cancel(),
        DeviceAuthenticationCancellationResult.promptStopFailed,
      );
      final overlapping = await authenticator.authenticate(
        localizedReason: 'Overlapping',
      );

      expect(overlapping, _failed);
      expect(client.authenticateCallCount, 1);

      firstCompletion.complete(true);
      expect(await first, _cancelled);
      client.authenticateCompletion = null;
      final retry = await authenticator.authenticate(localizedReason: 'Retry');

      expect(retry, _succeeded);
      expect(client.authenticateCallCount, 2);
    });

    test('cancel with no active attempt does not call the plugin', () async {
      final client = _FakeLocalAuthClient();
      final authenticator = LocalAuthDeviceAuthenticator(client: client);

      final result = await authenticator.cancel();

      expect(client.stopAuthenticationCallCount, 0);
      expect(result, DeviceAuthenticationCancellationResult.noActiveAttempt);
    });
  });
}

final class _FakeLocalAuthClient implements LocalAuthClient {
  _FakeLocalAuthClient({
    this.isSupported = true,
    this.authenticateResult = true,
    this.authenticateCompletion,
    this.exceptionCode,
    this.platformException,
    this.missingPluginException,
    this.programmerError,
    this.stopAuthenticationResult = true,
    this.stopAuthenticationCompletion,
    this.stopExceptionCode,
    this.stopPlatformException,
    this.stopMissingPluginException,
  });

  final bool isSupported;
  bool authenticateResult;
  Completer<bool>? authenticateCompletion;
  final LocalAuthExceptionCode? exceptionCode;
  final PlatformException? platformException;
  final MissingPluginException? missingPluginException;
  final Error? programmerError;
  final bool stopAuthenticationResult;
  final Completer<bool>? stopAuthenticationCompletion;
  final LocalAuthExceptionCode? stopExceptionCode;
  final PlatformException? stopPlatformException;
  final MissingPluginException? stopMissingPluginException;

  int isDeviceSupportedCallCount = 0;
  int authenticateCallCount = 0;
  int stopAuthenticationCallCount = 0;
  String? localizedReason;
  bool? biometricOnly;
  bool? sensitiveTransaction;
  bool? persistAcrossBackgrounding;
  Completer<void> authenticationStartedCompleter = Completer<void>();
  Completer<void> stopAuthenticationStartedCompleter = Completer<void>();

  Future<void> get authenticationStarted =>
      authenticationStartedCompleter.future;
  Future<void> get stopAuthenticationStarted =>
      stopAuthenticationStartedCompleter.future;

  @override
  Future<bool> isDeviceSupported() async {
    isDeviceSupportedCallCount++;
    return isSupported;
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required bool biometricOnly,
    required bool sensitiveTransaction,
    required bool persistAcrossBackgrounding,
  }) async {
    authenticateCallCount++;
    this.localizedReason = localizedReason;
    this.biometricOnly = biometricOnly;
    this.sensitiveTransaction = sensitiveTransaction;
    this.persistAcrossBackgrounding = persistAcrossBackgrounding;
    if (!authenticationStartedCompleter.isCompleted) {
      authenticationStartedCompleter.complete();
    }
    if (platformException case final exception?) {
      throw exception;
    }
    if (missingPluginException case final exception?) {
      throw exception;
    }
    if (programmerError case final error?) {
      throw error;
    }
    if (exceptionCode case final code?) {
      throw LocalAuthException(code: code);
    }
    if (authenticateCompletion case final completion?) {
      return completion.future;
    }
    return authenticateResult;
  }

  @override
  Future<bool> stopAuthentication() async {
    stopAuthenticationCallCount++;
    if (!stopAuthenticationStartedCompleter.isCompleted) {
      stopAuthenticationStartedCompleter.complete();
    }
    if (stopExceptionCode case final code?) {
      throw LocalAuthException(code: code);
    }
    if (stopPlatformException case final exception?) {
      throw exception;
    }
    if (stopMissingPluginException case final exception?) {
      throw exception;
    }
    if (stopAuthenticationCompletion case final completion?) {
      return completion.future;
    }
    return stopAuthenticationResult;
  }
}
