import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/app_info/data_sources/package_info_client.dart';
import 'package:mamo_approval/common/data/app_info/error_handling/app_info_failure.dart';
import 'package:mamo_approval/common/data/app_info/models/app_build_info.dart';
import 'package:mamo_approval/common/result/models/result.dart';

/// Shared application-information repository. It delegates to the
/// [PackageInfoClient] data source; there is no local/remote selection or
/// caching because the installed package identity is read on demand.
@lazySingleton
class AppInfoRepository {
  const AppInfoRepository(this._client);

  final PackageInfoClient _client;

  Future<Result<AppInfoFailure, AppBuildInfo>> loadBuildInfo() =>
      _client.loadBuildInfo();
}
