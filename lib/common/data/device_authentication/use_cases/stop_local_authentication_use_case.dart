import 'package:injectable/injectable.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/local_auth_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/models/device_authentication_cancellation_result.dart';

@lazySingleton
class StopLocalAuthenticationUseCase {
  const StopLocalAuthenticationUseCase(this._repository);

  final LocalAuthRepository _repository;

  Future<DeviceAuthenticationCancellationResult> call() => _repository.stop();
}
