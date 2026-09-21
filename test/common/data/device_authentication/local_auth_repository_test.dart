import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/error_handling/device_authentication_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/local_auth_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/models/device_authentication_cancellation_result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/unit.dart';

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

  group('LocalAuthRepository', () {
    test(
      'forwards the localized reason and returns the client result',
      () async {
        final client = FakeLocalAuthClient();
        final repository = LocalAuthRepository(client);

        final result = await repository.authenticate(localizedReason: 'Reason');

        expect(result, _succeeded);
        expect(client.authenticateCallCount, 1);
        expect(client.localizedReason, 'Reason');
      },
    );

    test(
      'returns unavailable without a prompt on an unsupported device',
      () async {
        final client = FakeLocalAuthClient(isSupported: false);
        final repository = LocalAuthRepository(client);

        final result = await repository.authenticate(localizedReason: 'Reason');

        expect(result, _unavailable);
        expect(client.authenticateCallCount, 0);
      },
    );

    test('passes a typed client failure straight through', () async {
      final client = FakeLocalAuthClient(authenticateResult: _failed);
      final repository = LocalAuthRepository(client);

      expect(await repository.authenticate(localizedReason: 'Reason'), _failed);
    });

    test('does not start a duplicate authentication attempt', () async {
      final completion = Completer<Result<DeviceAuthenticationFailure, Unit>>();
      final client = FakeLocalAuthClient(authenticateCompletion: completion);
      final repository = LocalAuthRepository(client);
      final first = repository.authenticate(localizedReason: 'First');
      await client.authenticationStarted;

      final duplicate = await repository.authenticate(
        localizedReason: 'Second',
      );

      expect(duplicate, _failed);
      expect(client.authenticateCallCount, 1);
      completion.complete(_succeeded);
      expect(await first, _succeeded);
    });

    test(
      'invalidates a late result after stop and reports cancelled',
      () async {
        final completion =
            Completer<Result<DeviceAuthenticationFailure, Unit>>();
        final client = FakeLocalAuthClient(authenticateCompletion: completion);
        final repository = LocalAuthRepository(client);
        final result = repository.authenticate(localizedReason: 'Reason');
        await client.authenticationStarted;

        final cancellation = await repository.stop();
        completion.complete(_succeeded);

        expect(await result, _cancelled);
        expect(
          cancellation,
          DeviceAuthenticationCancellationResult.promptStopped,
        );
        expect(client.stopAuthenticationCallCount, 1);
      },
    );

    test('releases occupancy after the client throws an error', () async {
      final completion = Completer<Result<DeviceAuthenticationFailure, Unit>>();
      final client = FakeLocalAuthClient(authenticateCompletion: completion);
      final repository = LocalAuthRepository(client);
      final first = repository.authenticate(localizedReason: 'First');
      await client.authenticationStarted;
      completion.completeError(StateError('boom'));

      await expectLater(first, throwsStateError);

      // The finally block must have cleared occupancy so a later attempt runs.
      client.authenticateCompletion = null;
      final retry = await repository.authenticate(localizedReason: 'Retry');

      expect(retry, _succeeded);
      expect(client.authenticateCallCount, 2);
    });

    test('keeps native occupancy until a cancelled result settles', () async {
      final completion = Completer<Result<DeviceAuthenticationFailure, Unit>>();
      final client = FakeLocalAuthClient(authenticateCompletion: completion);
      final repository = LocalAuthRepository(client);
      final first = repository.authenticate(localizedReason: 'First');
      await client.authenticationStarted;

      expect(
        await repository.stop(),
        DeviceAuthenticationCancellationResult.promptStopped,
      );
      final overlapping = await repository.authenticate(
        localizedReason: 'Overlapping',
      );

      expect(overlapping, _failed);
      expect(client.authenticateCallCount, 1);

      completion.complete(_succeeded);
      expect(await first, _cancelled);
      client.authenticateCompletion = null;
      final retry = await repository.authenticate(localizedReason: 'Retry');

      expect(retry, _succeeded);
      expect(client.authenticateCallCount, 2);
    });

    test(
      'does not start authentication while cancellation is settling',
      () async {
        final authentication =
            Completer<Result<DeviceAuthenticationFailure, Unit>>();
        final stop = Completer<DeviceAuthenticationCancellationResult>();
        final client = FakeLocalAuthClient(
          authenticateCompletion: authentication,
          stopCompletion: stop,
        );
        final repository = LocalAuthRepository(client);
        final first = repository.authenticate(localizedReason: 'First');
        await client.authenticationStarted;
        final cancellation = repository.stop();
        await client.stopStarted;

        final overlapping = await repository.authenticate(
          localizedReason: 'Overlapping',
        );

        expect(overlapping, _failed);
        expect(client.authenticateCallCount, 1);
        stop.complete(DeviceAuthenticationCancellationResult.promptStopped);
        expect(
          await cancellation,
          DeviceAuthenticationCancellationResult.promptStopped,
        );
        authentication.complete(_succeeded);
        expect(await first, _cancelled);
      },
    );

    test('shares one native stop across concurrent cancellations', () async {
      final authentication =
          Completer<Result<DeviceAuthenticationFailure, Unit>>();
      final stop = Completer<DeviceAuthenticationCancellationResult>();
      final client = FakeLocalAuthClient(
        authenticateCompletion: authentication,
        stopCompletion: stop,
      );
      final repository = LocalAuthRepository(client);
      unawaited(repository.authenticate(localizedReason: 'Reason'));
      await client.authenticationStarted;

      final firstCancellation = repository.stop();
      await client.stopStarted;
      final secondCancellation = repository.stop();
      stop.complete(DeviceAuthenticationCancellationResult.promptStopped);

      expect(
        await firstCancellation,
        DeviceAuthenticationCancellationResult.promptStopped,
      );
      expect(
        await secondCancellation,
        DeviceAuthenticationCancellationResult.promptStopped,
      );
      expect(client.stopAuthenticationCallCount, 1);
      authentication.complete(_succeeded);
    });

    test(
      'holds occupancy until settled even when the stop reports failed',
      () async {
        final completion =
            Completer<Result<DeviceAuthenticationFailure, Unit>>();
        final client = FakeLocalAuthClient(
          authenticateCompletion: completion,
          stopResult: DeviceAuthenticationCancellationResult.promptStopFailed,
        );
        final repository = LocalAuthRepository(client);
        final first = repository.authenticate(localizedReason: 'First');
        await client.authenticationStarted;

        expect(
          await repository.stop(),
          DeviceAuthenticationCancellationResult.promptStopFailed,
        );
        final overlapping = await repository.authenticate(
          localizedReason: 'Overlapping',
        );

        expect(overlapping, _failed);
        completion.complete(_failed);
        // A late failure after stop must also settle as cancelled, not leak its
        // real mapping.
        expect(await first, _cancelled);
      },
    );

    test(
      'reports no active attempt for a stop after the attempt settled',
      () async {
        final client = FakeLocalAuthClient();
        final repository = LocalAuthRepository(client);

        expect(
          await repository.authenticate(localizedReason: 'Reason'),
          _succeeded,
        );
        final result = await repository.stop();

        expect(result, DeviceAuthenticationCancellationResult.noActiveAttempt);
        expect(client.stopAuthenticationCallCount, 0);
      },
    );

    test('stop with no active attempt does not call the client', () async {
      final client = FakeLocalAuthClient();
      final repository = LocalAuthRepository(client);

      final result = await repository.stop();

      expect(client.stopAuthenticationCallCount, 0);
      expect(result, DeviceAuthenticationCancellationResult.noActiveAttempt);
    });

    test(
      'caches device support across repeated checks and an attempt',
      () async {
        final client = FakeLocalAuthClient();
        final repository = LocalAuthRepository(client);

        expect(await repository.isSupported(), isTrue);
        expect(await repository.isSupported(), isTrue);
        final result = await repository.authenticate(localizedReason: 'Reason');

        expect(result, _succeeded);
        expect(client.isDeviceSupportedCallCount, 1);
      },
    );

    test('re-probes support until it is confirmed, then caches it', () async {
      final client = FakeLocalAuthClient(isSupported: false);
      final repository = LocalAuthRepository(client);

      expect(await repository.isSupported(), isFalse);
      expect(await repository.isSupported(), isFalse);
      // A negative probe is not cached, so each check re-runs.
      expect(client.isDeviceSupportedCallCount, 2);

      client.isSupported = true;
      expect(await repository.isSupported(), isTrue);
      expect(await repository.isSupported(), isTrue);
      // Once confirmed, the positive result is cached.
      expect(client.isDeviceSupportedCallCount, 3);
    });
  });
}
