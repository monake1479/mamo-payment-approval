import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/local_auth_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/is_local_auth_supported_use_case.dart';

import '../../../../support/device_authentication_test_support.dart';

void main() {
  test('reports a supported device from the repository', () async {
    final client = FakeLocalAuthClient();
    final useCase = IsLocalAuthSupportedUseCase(LocalAuthRepository(client));

    expect(await useCase.call(), isTrue);
    expect(client.isDeviceSupportedCallCount, 1);
  });

  test('reports an unsupported device from the repository', () async {
    final client = FakeLocalAuthClient(isSupported: false);
    final useCase = IsLocalAuthSupportedUseCase(LocalAuthRepository(client));

    expect(await useCase.call(), isFalse);
  });
}
