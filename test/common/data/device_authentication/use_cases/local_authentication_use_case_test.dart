import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/error_handling/device_authentication_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/local_auth_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/local_authentication_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/unit.dart';

import '../../../../support/device_authentication_test_support.dart';

void main() {
  test('forwards the localized reason and returns success', () async {
    final client = FakeLocalAuthClient();
    final useCase = LocalAuthenticationUseCase(LocalAuthRepository(client));

    final result = await useCase.call(localizedReason: 'Reveal reason');

    expect(
      result,
      const Result<DeviceAuthenticationFailure, Unit>.success(unit),
    );
    expect(client.authenticateCallCount, 1);
    expect(client.localizedReason, 'Reveal reason');
  });

  test('rejects an empty prompt before touching the repository', () async {
    final client = FakeLocalAuthClient();
    final useCase = LocalAuthenticationUseCase(LocalAuthRepository(client));

    await expectLater(useCase.call(localizedReason: '  '), throwsArgumentError);
    expect(client.authenticateCallCount, 0);
    expect(client.isDeviceSupportedCallCount, 0);
  });

  test('propagates a typed failure from the repository', () async {
    final client = FakeLocalAuthClient(
      authenticateResult:
          const Result<DeviceAuthenticationFailure, Unit>.failure(
            DeviceAuthenticationFailure.failed(),
          ),
    );
    final useCase = LocalAuthenticationUseCase(LocalAuthRepository(client));

    final result = await useCase.call(localizedReason: 'Reveal reason');

    expect(
      result,
      const Result<DeviceAuthenticationFailure, Unit>.failure(
        DeviceAuthenticationFailure.failed(),
      ),
    );
  });
}
