import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/app/config/app_environment.dart';
import 'package:mamo_approval/common/data/app_info/error_handling/app_info_failure.dart';
import 'package:mamo_approval/common/data/app_info/models/app_build_info.dart';
import 'package:mamo_approval/common/data/app_info/use_cases/load_app_build_info_use_case.dart';
import 'package:mamo_approval/common/data/device_authentication/local_auth_repository.dart';
import 'package:mamo_approval/common/data/device_authentication/use_cases/is_local_auth_supported_use_case.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:mamo_approval/features/settings/states/about/about_cubit.dart';
import 'package:mamo_approval/features/settings/states/about/about_state.dart';

import '../../../../support/app_info_test_support.dart';
import '../../../../support/device_authentication_test_support.dart';

void main() {
  test('starts loading before the first request', () {
    final AboutCubit cubit = createAboutCubit();
    addTearDown(cubit.close);

    expect(cubit.state, const AboutState.loading());
  });

  test('loads the build identity, environment, and availability', () async {
    final FakePackageInfoPlatform platform = FakePackageInfoPlatform();
    final AboutCubit cubit = createAboutCubit(
      packageInfo: platform,
      environment: AppEnvironment.staging,
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(
      cubit.state,
      const AboutState.loaded(
        buildInfo: testBuildInfo,
        environment: AppEnvironment.staging,
        isDeviceAuthenticationAvailable: true,
      ),
    );
    expect(platform.getAllCallCount, 1);
  });

  test(
    'reports an unsupported device without starting authentication',
    () async {
      final FakeLocalAuthClient authClient = FakeLocalAuthClient(
        isSupported: false,
      );
      final AboutCubit cubit = AboutCubit(
        loadBuildInfo: createLoadAppBuildInfoUseCase(FakePackageInfoPlatform()),
        isLocalAuthSupported: IsLocalAuthSupportedUseCase(
          LocalAuthRepository(authClient),
        ),
        environment: AppEnvironment.dev,
      );
      addTearDown(cubit.close);

      await cubit.load();

      expect(
        cubit.state,
        const AboutState.loaded(
          buildInfo: testBuildInfo,
          environment: AppEnvironment.dev,
          isDeviceAuthenticationAvailable: false,
        ),
      );
      expect(authClient.isDeviceSupportedCallCount, 1);
      expect(authClient.authenticateCallCount, 0);
    },
  );

  test(
    'surfaces a typed failure when the build identity is unavailable',
    () async {
      final AboutCubit cubit = createAboutCubit(
        packageInfo: FakePackageInfoPlatform(error: Exception('channel down')),
      );
      addTearDown(cubit.close);

      await cubit.load();

      expect(
        cubit.state,
        const AboutState.failed(failure: AppInfoFailure.unavailable()),
      );
    },
  );

  test('retrying after a failure reloads through the loading state', () async {
    final _SequencedLoadAppBuildInfoUseCase loadBuildInfo =
        _SequencedLoadAppBuildInfoUseCase(
          <Result<AppInfoFailure, AppBuildInfo>>[
            const Result<AppInfoFailure, AppBuildInfo>.failure(
              AppInfoFailure.unavailable(),
            ),
            const Result<AppInfoFailure, AppBuildInfo>.success(testBuildInfo),
          ],
        );
    final AboutCubit cubit = AboutCubit(
      loadBuildInfo: loadBuildInfo,
      isLocalAuthSupported: IsLocalAuthSupportedUseCase(
        LocalAuthRepository(FakeLocalAuthClient()),
      ),
      environment: AppEnvironment.prod,
    );
    addTearDown(cubit.close);
    final List<AboutState> emitted = <AboutState>[];
    final StreamSubscription<AboutState> subscription = cubit.stream.listen(
      emitted.add,
    );
    addTearDown(subscription.cancel);

    await cubit.load();
    await cubit.load();
    await pumpEventQueue();

    expect(emitted, <AboutState>[
      const AboutState.failed(failure: AppInfoFailure.unavailable()),
      const AboutState.loading(),
      const AboutState.loaded(
        buildInfo: testBuildInfo,
        environment: AppEnvironment.prod,
        isDeviceAuthenticationAvailable: true,
      ),
    ]);
    expect(loadBuildInfo.callCount, 2);
  });

  test('ignores a repeated load while one is in flight', () async {
    final Completer<Result<AppInfoFailure, AppBuildInfo>> completion =
        Completer<Result<AppInfoFailure, AppBuildInfo>>();
    final _SequencedLoadAppBuildInfoUseCase loadBuildInfo =
        _SequencedLoadAppBuildInfoUseCase(
          const <Result<AppInfoFailure, AppBuildInfo>>[],
          pending: completion.future,
        );
    final AboutCubit cubit = AboutCubit(
      loadBuildInfo: loadBuildInfo,
      isLocalAuthSupported: IsLocalAuthSupportedUseCase(
        LocalAuthRepository(FakeLocalAuthClient()),
      ),
      environment: AppEnvironment.dev,
    );
    addTearDown(cubit.close);
    final List<AboutState> emitted = <AboutState>[];
    final StreamSubscription<AboutState> subscription = cubit.stream.listen(
      emitted.add,
    );
    addTearDown(subscription.cancel);

    final Future<void> first = cubit.load();
    final Future<void> second = cubit.load();
    completion.complete(
      const Result<AppInfoFailure, AppBuildInfo>.success(testBuildInfo),
    );
    await Future.wait<void>(<Future<void>>[first, second]);
    await pumpEventQueue();

    expect(loadBuildInfo.callCount, 1);
    expect(emitted, hasLength(1));
    expect(emitted.single, isA<AboutLoaded>());
  });

  test('does not emit after being closed', () async {
    final Completer<Result<AppInfoFailure, AppBuildInfo>> completion =
        Completer<Result<AppInfoFailure, AppBuildInfo>>();
    final AboutCubit cubit = AboutCubit(
      loadBuildInfo: _SequencedLoadAppBuildInfoUseCase(
        const <Result<AppInfoFailure, AppBuildInfo>>[],
        pending: completion.future,
      ),
      isLocalAuthSupported: IsLocalAuthSupportedUseCase(
        LocalAuthRepository(FakeLocalAuthClient()),
      ),
      environment: AppEnvironment.dev,
    );

    final Future<void> load = cubit.load();
    await cubit.close();
    completion.complete(
      const Result<AppInfoFailure, AppBuildInfo>.success(testBuildInfo),
    );
    await load;

    expect(cubit.state, const AboutState.loading());
  });
}

/// Returns scripted results in order, or a single deferred [pending] result.
final class _SequencedLoadAppBuildInfoUseCase
    implements LoadAppBuildInfoUseCase {
  _SequencedLoadAppBuildInfoUseCase(this._results, {this.pending});

  final List<Result<AppInfoFailure, AppBuildInfo>> _results;
  final Future<Result<AppInfoFailure, AppBuildInfo>>? pending;
  int callCount = 0;

  @override
  Future<Result<AppInfoFailure, AppBuildInfo>> call() {
    callCount++;
    if (pending case final pending?) {
      return pending;
    }
    return Future<Result<AppInfoFailure, AppBuildInfo>>.value(
      _results[callCount - 1],
    );
  }
}
