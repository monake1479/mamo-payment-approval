import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/local_auth_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/models/device_authentication_cancellation_result.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/stop_local_authentication_use_case.dart';

import '../../../../support/device_authentication_test_support.dart';

void main() {
  test('reports no active attempt without touching the plugin', () async {
    final client = FakeLocalAuthClient();
    final useCase = StopLocalAuthenticationUseCase(LocalAuthRepository(client));

    final result = await useCase.call();

    expect(result, DeviceAuthenticationCancellationResult.noActiveAttempt);
    expect(client.stopAuthenticationCallCount, 0);
  });

  test('stops an in-flight attempt through the repository', () async {
    final client = FakeLocalAuthClient();
    final repository = LocalAuthRepository(client);
    final useCase = StopLocalAuthenticationUseCase(repository);
    // Reserve an attempt so stop() has something to invalidate.
    unawaited(repository.authenticate(localizedReason: 'Reveal reason'));
    await client.authenticationStarted;

    final result = await useCase.call();

    expect(result, DeviceAuthenticationCancellationResult.promptStopped);
    expect(client.stopAuthenticationCallCount, 1);
  });
}
