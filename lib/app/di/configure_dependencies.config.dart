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
import 'package:mamo_payment_approval_challenge/app/di/app_preferences_module.dart'
    as _i134;
import 'package:mamo_payment_approval_challenge/app/di/device_authentication_module.dart'
    as _i493;
import 'package:mamo_payment_approval_challenge/app/di/mock_backend_module.dart'
    as _i853;
import 'package:mamo_payment_approval_challenge/common/data/appearance/data_sources/theme_preference_local_data_source.dart'
    as _i251;
import 'package:mamo_payment_approval_challenge/common/data/appearance/theme_preference_repository.dart'
    as _i773;
import 'package:mamo_payment_approval_challenge/common/data/appearance/use_cases/load_theme_preference_use_case.dart'
    as _i851;
import 'package:mamo_payment_approval_challenge/common/data/appearance/use_cases/save_theme_preference_use_case.dart'
    as _i167;
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/data_sources/local_auth_client.dart'
    as _i839;
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/local_auth_repository.dart'
    as _i330;
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/is_local_auth_supported_use_case.dart'
    as _i528;
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/local_authentication_use_case.dart'
    as _i437;
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/stop_local_authentication_use_case.dart'
    as _i166;
import 'package:mamo_payment_approval_challenge/common/data/payments/data_sources/payments_remote_data_source.dart'
    as _i462;
import 'package:mamo_payment_approval_challenge/common/data/payments/payments_repository.dart'
    as _i831;
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/create_payment_request_use_case.dart'
    as _i559;
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/decide_payment_use_case.dart'
    as _i343;
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/load_payments_use_case.dart'
    as _i1042;
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/refresh_payments_use_case.dart'
    as _i1;
import 'package:mamo_payment_approval_challenge/mock_backend/payments/payments_backend_client.dart'
    as _i677;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appPreferencesModule = _$AppPreferencesModule();
    final deviceAuthenticationModule = _$DeviceAuthenticationModule();
    final mockBackendModule = _$MockBackendModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appPreferencesModule.sharedPreferences(),
      preResolve: true,
    );
    gh.lazySingleton<_i152.LocalAuthentication>(
      () => deviceAuthenticationModule.localAuthentication(),
    );
    gh.lazySingleton<_i677.PaymentsBackendClient>(
      () => mockBackendModule.paymentsBackendClient(),
    );
    gh.lazySingleton<_i251.ThemePreferenceLocalDataSource>(
      () => _i251.ThemePreferenceLocalDataSource(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i839.LocalAuthClient>(
      () => _i839.LocalAuthClient(gh<_i152.LocalAuthentication>()),
    );
    gh.lazySingleton<_i462.PaymentsRemoteDataSource>(
      () => _i462.PaymentsRemoteDataSource(gh<_i677.PaymentsBackendClient>()),
    );
    gh.lazySingleton<_i330.LocalAuthRepository>(
      () => _i330.LocalAuthRepository(gh<_i839.LocalAuthClient>()),
    );
    gh.lazySingleton<_i773.ThemePreferenceRepository>(
      () => _i773.ThemePreferenceRepository(
        gh<_i251.ThemePreferenceLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i831.PaymentsRepository>(
      () => _i831.PaymentsRepository(gh<_i462.PaymentsRemoteDataSource>()),
    );
    gh.lazySingleton<_i851.LoadThemePreferenceUseCase>(
      () => _i851.LoadThemePreferenceUseCase(
        gh<_i773.ThemePreferenceRepository>(),
      ),
    );
    gh.lazySingleton<_i167.SaveThemePreferenceUseCase>(
      () => _i167.SaveThemePreferenceUseCase(
        gh<_i773.ThemePreferenceRepository>(),
      ),
    );
    gh.lazySingleton<_i528.IsLocalAuthSupportedUseCase>(
      () => _i528.IsLocalAuthSupportedUseCase(gh<_i330.LocalAuthRepository>()),
    );
    gh.lazySingleton<_i437.LocalAuthenticationUseCase>(
      () => _i437.LocalAuthenticationUseCase(gh<_i330.LocalAuthRepository>()),
    );
    gh.lazySingleton<_i166.StopLocalAuthenticationUseCase>(
      () =>
          _i166.StopLocalAuthenticationUseCase(gh<_i330.LocalAuthRepository>()),
    );
    gh.lazySingleton<_i559.CreatePaymentRequestUseCase>(
      () => _i559.CreatePaymentRequestUseCase(gh<_i831.PaymentsRepository>()),
    );
    gh.lazySingleton<_i343.DecidePaymentUseCase>(
      () => _i343.DecidePaymentUseCase(gh<_i831.PaymentsRepository>()),
    );
    gh.lazySingleton<_i1042.LoadPaymentsUseCase>(
      () => _i1042.LoadPaymentsUseCase(gh<_i831.PaymentsRepository>()),
    );
    gh.lazySingleton<_i1.RefreshPaymentsUseCase>(
      () => _i1.RefreshPaymentsUseCase(gh<_i831.PaymentsRepository>()),
    );
    return this;
  }
}

class _$AppPreferencesModule extends _i134.AppPreferencesModule {}

class _$DeviceAuthenticationModule extends _i493.DeviceAuthenticationModule {}

class _$MockBackendModule extends _i853.MockBackendModule {}
