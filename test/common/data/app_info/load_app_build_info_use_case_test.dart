import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/common/data/app_info/error_handling/app_info_failure.dart';
import 'package:mamo_approval/common/data/app_info/models/app_build_info.dart';
import 'package:mamo_approval/common/result/models/result.dart';

import '../../../support/app_info_test_support.dart';

void main() {
  test('returns the build identity reported by the data source', () async {
    final FakePackageInfoPlatform platform = FakePackageInfoPlatform();

    expect(
      await createLoadAppBuildInfoUseCase(platform)(),
      const Result<AppInfoFailure, AppBuildInfo>.success(testBuildInfo),
    );
    expect(platform.getAllCallCount, 1);
  });

  test('passes a typed failure through unchanged', () async {
    final FakePackageInfoPlatform platform = FakePackageInfoPlatform(
      error: Exception('channel down'),
    );

    expect(
      await createLoadAppBuildInfoUseCase(platform)(),
      const Result<AppInfoFailure, AppBuildInfo>.failure(
        AppInfoFailure.unavailable(),
      ),
    );
  });
}
