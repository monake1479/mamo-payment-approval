import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/app/config/app_environment.dart';
import 'package:mamo_approval/app/di/configure_dependencies.dart';
import 'package:mamo_approval/common/data/app_info/app_info_repository.dart';
import 'package:mamo_approval/common/data/app_info/data_sources/package_info_client.dart';
import 'package:mamo_approval/common/data/app_info/models/app_build_info.dart';
import 'package:mamo_approval/common/data/app_info/use_cases/load_app_build_info_use_case.dart';
import 'package:mamo_approval/common/data/device_authentication/local_auth_repository.dart';
import 'package:mamo_approval/common/data/device_authentication/use_cases/is_local_auth_supported_use_case.dart';
import 'package:mamo_approval/features/settings/states/about/about_cubit.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart';

import 'device_authentication_test_support.dart';

/// Deterministic build identity used by About tests.
const AppBuildInfo testBuildInfo = AppBuildInfo(
  version: '1.2.3',
  buildNumber: '45',
  packageName: 'mamo.payment.approval.dev',
);

/// Fakes the `package_info_plus` platform seam so `PackageInfoClient`'s mapping
/// and exception translation can be unit tested. Drive it to return [data], to
/// throw [error], or to stay [pending] so a loading state can be observed.
final class FakePackageInfoPlatform extends PackageInfoPlatform {
  FakePackageInfoPlatform({this.data, this.error, this.pending});

  final PackageInfoData? data;
  final Object? error;
  final Completer<PackageInfoData>? pending;

  int getAllCallCount = 0;

  @override
  Future<PackageInfoData> getAll({String? baseUrl}) async {
    getAllCallCount++;
    if (pending case final pending?) {
      return pending.future;
    }
    if (error case final error?) {
      throw error;
    }
    return data ??
        PackageInfoData(
          appName: 'Mamo Approval',
          packageName: testBuildInfo.packageName,
          version: testBuildInfo.version,
          buildNumber: testBuildInfo.buildNumber,
          buildSignature: '',
        );
  }
}

/// Builds a [LoadAppBuildInfoUseCase] over the fake platform seam.
LoadAppBuildInfoUseCase createLoadAppBuildInfoUseCase(
  FakePackageInfoPlatform platform,
) => LoadAppBuildInfoUseCase(AppInfoRepository(PackageInfoClient(platform)));

/// Builds an [AboutCubit] over fake platform seams. The defaults describe a
/// device that supports authentication and reports [testBuildInfo]; the cubit
/// is returned before `load()` so tests observe the loading state.
AboutCubit createAboutCubit({
  FakePackageInfoPlatform? packageInfo,
  bool isDeviceAuthenticationSupported = true,
  AppEnvironment environment = AppEnvironment.dev,
}) => AboutCubit(
  loadBuildInfo: createLoadAppBuildInfoUseCase(
    packageInfo ?? FakePackageInfoPlatform(),
  ),
  isLocalAuthSupported: IsLocalAuthSupportedUseCase(
    LocalAuthRepository(
      FakeLocalAuthClient(isSupported: isDeviceAuthenticationSupported),
    ),
  ),
  environment: environment,
);

/// Registers an [AboutCubit] factory in `getIt` for widget tests that render
/// `SettingsPage`, which provides the cubit from the locator at its top. The
/// locator is reset when the test ends.
void registerAboutCubitFactory({
  FakePackageInfoPlatform? packageInfo,
  bool isDeviceAuthenticationSupported = true,
  AppEnvironment environment = AppEnvironment.dev,
}) {
  getIt.registerFactory<AboutCubit>(
    () => createAboutCubit(
      packageInfo: packageInfo,
      isDeviceAuthenticationSupported: isDeviceAuthenticationSupported,
      environment: environment,
    ),
  );
  addTearDown(getIt.reset);
}
