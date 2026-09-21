import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/common/data/app_info/data_sources/package_info_client.dart';
import 'package:mamo_approval/common/data/app_info/error_handling/app_info_failure.dart';
import 'package:mamo_approval/common/data/app_info/models/app_build_info.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';

import '../../../support/app_info_test_support.dart';

void main() {
  test('maps the platform package data to the build identity', () async {
    final FakePackageInfoPlatform platform = FakePackageInfoPlatform(
      data: PackageInfoData(
        appName: 'Mamo Approval',
        packageName: 'mamo.payment.approval',
        version: '2.0.0',
        buildNumber: '7',
        buildSignature: 'ignored',
        installerStore: 'ignored',
      ),
    );

    final Result<AppInfoFailure, AppBuildInfo> result = await PackageInfoClient(
      platform,
    ).loadBuildInfo();

    expect(
      result,
      const Result<AppInfoFailure, AppBuildInfo>.success(
        AppBuildInfo(
          version: '2.0.0',
          buildNumber: '7',
          packageName: 'mamo.payment.approval',
        ),
      ),
    );
    expect(platform.getAllCallCount, 1);
  });

  for (final Exception error in <Exception>[
    PlatformException(code: 'channel-error'),
    MissingPluginException(),
  ]) {
    test('translates $error into an unavailable failure', () async {
      final PackageInfoClient client = PackageInfoClient(
        FakePackageInfoPlatform(error: error),
      );

      expect(
        await client.loadBuildInfo(),
        const Result<AppInfoFailure, AppBuildInfo>.failure(
          AppInfoFailure.unavailable(),
        ),
      );
    });
  }

  test('failure exposes a stable code', () {
    expect(const AppInfoFailure.unavailable().code, 'app_info.unavailable');
  });
}
