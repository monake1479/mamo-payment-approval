import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/app_info/app_info_repository.dart';
import 'package:mamo_approval/common/data/app_info/error_handling/app_info_failure.dart';
import 'package:mamo_approval/common/data/app_info/models/app_build_info.dart';
import 'package:mamo_approval/common/result/models/result.dart';

@lazySingleton
class LoadAppBuildInfoUseCase {
  const LoadAppBuildInfoUseCase(this._repository);

  final AppInfoRepository _repository;

  Future<Result<AppInfoFailure, AppBuildInfo>> call() =>
      _repository.loadBuildInfo();
}
