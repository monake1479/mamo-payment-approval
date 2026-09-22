import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/device_authentication/local_auth_repository.dart';

@lazySingleton
class IsLocalAuthSupportedUseCase {
  const IsLocalAuthSupportedUseCase(this._repository);

  final LocalAuthRepository _repository;

  Future<bool> call() => _repository.isSupported();
}
