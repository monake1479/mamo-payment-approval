import 'package:injectable/injectable.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/error_handling/device_authentication_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/local_auth_repository.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/unit.dart';

@lazySingleton
class LocalAuthenticationUseCase {
  const LocalAuthenticationUseCase(this._repository);

  final LocalAuthRepository _repository;

  Future<Result<DeviceAuthenticationFailure, Unit>> call({
    required String localizedReason,
  }) async {
    if (localizedReason.trim().isEmpty) {
      throw ArgumentError.value(
        localizedReason,
        'localizedReason',
        'The device authentication prompt reason must not be empty.',
      );
    }
    return _repository.authenticate(localizedReason: localizedReason);
  }
}
