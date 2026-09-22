import 'package:injectable/injectable.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';

/// Provides the `package_info_plus` platform seam to dependency injection so
/// the application-information data source never touches the plugin's static
/// API directly.
@module
abstract class AppInfoModule {
  @lazySingleton
  PackageInfoPlatform packageInfoPlatform() => PackageInfoPlatform.instance;
}
