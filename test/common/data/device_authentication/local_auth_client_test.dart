import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mamo_approval/common/data/device_authentication/data_sources/local_auth_client.dart';
import 'package:mamo_approval/common/data/device_authentication/error_handling/device_authentication_failure.dart';
import 'package:mamo_approval/common/data/device_authentication/models/device_authentication_cancellation_result.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:mamo_approval/common/result/models/unit.dart';

import '../../../support/device_authentication_test_support.dart';

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
  group('LocalAuthClient', () {
    test('forwards sensitive options and maps success', () async {
      final plugin = FakeLocalAuthentication();
      final client = LocalAuthClient(plugin);

      final result = await client.authenticate(
        localizedReason: 'Authenticate to reveal payment details.',
      );

      expect(result, _succeeded);
      expect(plugin.localizedReason, 'Authenticate to reveal payment details.');
      expect(plugin.biometricOnly, isFalse);
      expect(plugin.sensitiveTransaction, isTrue);
      expect(plugin.persistAcrossBackgrounding, isFalse);
    });

    test('maps a false native result to failed', () async {
      final client = LocalAuthClient(
        FakeLocalAuthentication(authenticateResult: false),
      );

      expect(await client.authenticate(localizedReason: 'Reason'), _failed);
    });

    for (final code in <LocalAuthExceptionCode>[
      LocalAuthExceptionCode.userCanceled,
      LocalAuthExceptionCode.systemCanceled,
      LocalAuthExceptionCode.timeout,
    ]) {
      test('maps ${code.name} to cancelled', () async {
        final client = LocalAuthClient(
          FakeLocalAuthentication(
            authenticateError: LocalAuthException(code: code),
          ),
        );

        expect(
          await client.authenticate(localizedReason: 'Reason'),
          _cancelled,
        );
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
        final client = LocalAuthClient(
          FakeLocalAuthentication(
            authenticateError: LocalAuthException(code: code),
          ),
        );

        expect(
          await client.authenticate(localizedReason: 'Reason'),
          _unavailable,
        );
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
        final client = LocalAuthClient(
          FakeLocalAuthentication(
            authenticateError: LocalAuthException(code: code),
          ),
        );

        expect(await client.authenticate(localizedReason: 'Reason'), _failed);
      });
    }

    test('maps an unexpected platform exception to failed', () async {
      final client = LocalAuthClient(
        FakeLocalAuthentication(
          authenticateError: PlatformException(code: 'unexpected'),
        ),
      );

      expect(await client.authenticate(localizedReason: 'Reason'), _failed);
    });

    test('maps a missing plugin exception to failed', () async {
      final client = LocalAuthClient(
        FakeLocalAuthentication(authenticateError: MissingPluginException()),
      );

      expect(await client.authenticate(localizedReason: 'Reason'), _failed);
    });

    test('lets a plugin Error propagate from authenticate', () async {
      final client = LocalAuthClient(
        FakeLocalAuthentication(authenticateError: StateError('fixture')),
      );

      await expectLater(
        client.authenticate(localizedReason: 'Reason'),
        throwsStateError,
      );
    });

    test('lets a plugin Error propagate from stopAuthentication', () async {
      final client = LocalAuthClient(
        FakeLocalAuthentication(stopError: StateError('fixture')),
      );

      await expectLater(client.stopAuthentication(), throwsStateError);
    });

    test('reports device support', () async {
      expect(
        await LocalAuthClient(FakeLocalAuthentication()).isDeviceSupported(),
        isTrue,
      );
      expect(
        await LocalAuthClient(FakeLocalAuthentication(isSupported: false))
            .isDeviceSupported(),
        isFalse,
      );
    });

    test('treats a support probe error as unsupported', () async {
      final client = LocalAuthClient(
        FakeLocalAuthentication(
          isSupportedError: PlatformException(code: 'boom'),
        ),
      );

      expect(await client.isDeviceSupported(), isFalse);
    });

    test('maps native prompt stop outcomes', () async {
      expect(
        await LocalAuthClient(FakeLocalAuthentication()).stopAuthentication(),
        DeviceAuthenticationCancellationResult.promptStopped,
      );
      expect(
        await LocalAuthClient(FakeLocalAuthentication(stopResult: false))
            .stopAuthentication(),
        DeviceAuthenticationCancellationResult.promptStopFailed,
      );
      expect(
        await LocalAuthClient(
          FakeLocalAuthentication(
            stopError: LocalAuthException(
              code: LocalAuthExceptionCode.deviceError,
            ),
          ),
        ).stopAuthentication(),
        DeviceAuthenticationCancellationResult.promptStopFailed,
      );
    });
  });
}
