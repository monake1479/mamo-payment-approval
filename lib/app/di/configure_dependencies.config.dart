// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:local_auth/local_auth.dart' as _i152;
import 'package:mamo_approval/app/config/app_environment.dart' as _i565;
import 'package:mamo_approval/app/di/app_info_module.dart' as _i207;
import 'package:mamo_approval/app/di/app_preferences_module.dart' as _i353;
import 'package:mamo_approval/app/di/device_authentication_module.dart'
    as _i925;
import 'package:mamo_approval/app/di/mock_backend_module.dart' as _i994;
import 'package:mamo_approval/common/data/app_info/app_info_repository.dart'
    as _i533;
import 'package:mamo_approval/common/data/app_info/data_sources/package_info_client.dart'
    as _i935;
import 'package:mamo_approval/common/data/app_info/use_cases/load_app_build_info_use_case.dart'
    as _i15;
import 'package:mamo_approval/common/data/appearance/data_sources/theme_preference_local_data_source.dart'
    as _i609;
import 'package:mamo_approval/common/data/appearance/theme_preference_repository.dart'
    as _i617;
import 'package:mamo_approval/common/data/appearance/use_cases/load_theme_preference_use_case.dart'
    as _i950;
import 'package:mamo_approval/common/data/appearance/use_cases/save_theme_preference_use_case.dart'
    as _i422;
import 'package:mamo_approval/common/data/device_authentication/data_sources/local_auth_client.dart'
    as _i192;
import 'package:mamo_approval/common/data/device_authentication/local_auth_repository.dart'
    as _i133;
import 'package:mamo_approval/common/data/device_authentication/use_cases/is_local_auth_supported_use_case.dart'
    as _i70;
import 'package:mamo_approval/common/data/device_authentication/use_cases/local_authentication_use_case.dart'
    as _i641;
import 'package:mamo_approval/common/data/device_authentication/use_cases/stop_local_authentication_use_case.dart'
    as _i445;
import 'package:mamo_approval/common/data/payments/data_sources/payments_remote_data_source.dart'
    as _i891;
import 'package:mamo_approval/common/data/payments/payments_repository.dart'
    as _i823;
import 'package:mamo_approval/common/data/payments/use_cases/create_payment_request_use_case.dart'
    as _i570;
import 'package:mamo_approval/common/data/payments/use_cases/decide_payment_use_case.dart'
    as _i82;
import 'package:mamo_approval/common/data/payments/use_cases/load_payments_use_case.dart'
    as _i402;
import 'package:mamo_approval/common/data/payments/use_cases/refresh_payments_use_case.dart'
    as _i245;
import 'package:mamo_approval/features/settings/states/about/about_cubit.dart'
    as _i455;
import 'package:mamo_approval/mock_backend/payments/payments_backend_client.dart'
    as _i643;
import 'package:package_info_plus_platform_interface/package_info_platform_interface.dart'
    as _i490;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appPreferencesModule = _$AppPreferencesModule();
    final appInfoModule = _$AppInfoModule();
    final deviceAuthenticationModule = _$DeviceAuthenticationModule();
    final mockBackendModule = _$MockBackendModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appPreferencesModule.sharedPreferences(),
      preResolve: true,
    );
    gh.lazySingleton<_i490.PackageInfoPlatform>(
      () => appInfoModule.packageInfoPlatform(),
    );
    gh.lazySingleton<_i152.LocalAuthentication>(
      () => deviceAuthenticationModule.localAuthentication(),
    );
    gh.lazySingleton<_i643.PaymentsBackendClient>(
      () => mockBackendModule.paymentsBackendClient(),
    );
    gh.lazySingleton<_i609.ThemePreferenceLocalDataSource>(
      () => _i609.ThemePreferenceLocalDataSource(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i192.LocalAuthClient>(
      () => _i192.LocalAuthClient(gh<_i152.LocalAuthentication>()),
    );
    gh.lazySingleton<_i617.ThemePreferenceRepository>(
      () => _i617.ThemePreferenceRepository(
        gh<_i609.ThemePreferenceLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i891.PaymentsRemoteDataSource>(
      () => _i891.PaymentsRemoteDataSource(gh<_i643.PaymentsBackendClient>()),
    );
    gh.lazySingleton<_i935.PackageInfoClient>(
      () => _i935.PackageInfoClient(gh<_i490.PackageInfoPlatform>()),
    );
    gh.lazySingleton<_i950.LoadThemePreferenceUseCase>(
      () => _i950.LoadThemePreferenceUseCase(
        gh<_i617.ThemePreferenceRepository>(),
      ),
    );
    gh.lazySingleton<_i422.SaveThemePreferenceUseCase>(
      () => _i422.SaveThemePreferenceUseCase(
        gh<_i617.ThemePreferenceRepository>(),
      ),
    );
    gh.lazySingleton<_i533.AppInfoRepository>(
      () => _i533.AppInfoRepository(gh<_i935.PackageInfoClient>()),
    );
    gh.lazySingleton<_i133.LocalAuthRepository>(
      () => _i133.LocalAuthRepository(gh<_i192.LocalAuthClient>()),
    );
    gh.lazySingleton<_i823.PaymentsRepository>(
      () => _i823.PaymentsRepository(gh<_i891.PaymentsRemoteDataSource>()),
    );
    gh.lazySingleton<_i15.LoadAppBuildInfoUseCase>(
      () => _i15.LoadAppBuildInfoUseCase(gh<_i533.AppInfoRepository>()),
    );
    gh.lazySingleton<_i70.IsLocalAuthSupportedUseCase>(
      () => _i70.IsLocalAuthSupportedUseCase(gh<_i133.LocalAuthRepository>()),
    );
    gh.lazySingleton<_i641.LocalAuthenticationUseCase>(
      () => _i641.LocalAuthenticationUseCase(gh<_i133.LocalAuthRepository>()),
    );
    gh.lazySingleton<_i445.StopLocalAuthenticationUseCase>(
      () =>
          _i445.StopLocalAuthenticationUseCase(gh<_i133.LocalAuthRepository>()),
    );
    gh.lazySingleton<_i570.CreatePaymentRequestUseCase>(
      () => _i570.CreatePaymentRequestUseCase(gh<_i823.PaymentsRepository>()),
    );
    gh.lazySingleton<_i82.DecidePaymentUseCase>(
      () => _i82.DecidePaymentUseCase(gh<_i823.PaymentsRepository>()),
    );
    gh.lazySingleton<_i402.LoadPaymentsUseCase>(
      () => _i402.LoadPaymentsUseCase(gh<_i823.PaymentsRepository>()),
    );
    gh.lazySingleton<_i245.RefreshPaymentsUseCase>(
      () => _i245.RefreshPaymentsUseCase(gh<_i823.PaymentsRepository>()),
    );
    gh.factory<_i455.AboutCubit>(
      () => _i455.AboutCubit(
        loadBuildInfo: gh<_i15.LoadAppBuildInfoUseCase>(),
        isLocalAuthSupported: gh<_i70.IsLocalAuthSupportedUseCase>(),
        environment: gh<_i565.AppEnvironment>(),
      ),
    );
    return this;
  }
}

class _$AppPreferencesModule extends _i353.AppPreferencesModule {}

class _$AppInfoModule extends _i207.AppInfoModule {}

class _$DeviceAuthenticationModule extends _i925.DeviceAuthenticationModule {}

class _$MockBackendModule extends _i994.MockBackendModule {}
