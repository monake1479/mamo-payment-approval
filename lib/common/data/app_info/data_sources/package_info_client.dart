import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/app_info/error_handling/app_info_failure.dart';
import 'package:mamo_approval/common/data/app_info/models/app_build_info.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';

/// Application-information data source over the `package_info_plus` plugin.
///
/// It reads the federated platform interface directly rather than the plugin's
/// static `PackageInfo.fromPlatform()` accessor: the static accessor caches its
/// first successful answer process-wide with no reset, which would make the
/// failure path untestable next to the success path. The platform instance is
/// injected so the mapping can be unit tested with a fake, and every plugin
/// exception is translated here into a typed [AppInfoFailure].
@lazySingleton
class PackageInfoClient {
  const PackageInfoClient(this._platform);

  final PackageInfoPlatform _platform;

  Future<Result<AppInfoFailure, AppBuildInfo>> loadBuildInfo() async {
    try {
      final PackageInfoData data = await _platform.getAll();
      return Result<AppInfoFailure, AppBuildInfo>.success(
        AppBuildInfo(
          version: data.version,
          buildNumber: data.buildNumber,
          packageName: data.packageName,
        ),
      );
    } on Exception {
      return const Result<AppInfoFailure, AppBuildInfo>.failure(
        AppInfoFailure.unavailable(),
      );
    }
  }
}
