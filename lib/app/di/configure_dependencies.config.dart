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
import 'package:mamo_approval/app/di/device_authentication_module.dart'
    as _i925;
import 'package:mamo_approval/app/di/mock_backend_module.dart' as _i994;
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
import 'package:mamo_approval/common/data/payments/use_cases/search_payments_use_case.dart'
    as _i637;
import 'package:mamo_approval/features/payments/states/search/payments_search_bloc.dart'
    as _i237;
import 'package:mamo_approval/mock_backend/payments/payments_backend_client.dart'
    as _i643;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final deviceAuthenticationModule = _$DeviceAuthenticationModule();
    final mockBackendModule = _$MockBackendModule();
    gh.lazySingleton<_i152.LocalAuthentication>(
      () => deviceAuthenticationModule.localAuthentication(),
    );
    gh.lazySingleton<_i643.PaymentsBackendClient>(
      () => mockBackendModule.paymentsBackendClient(),
    );
    gh.lazySingleton<_i192.LocalAuthClient>(
      () => _i192.LocalAuthClient(gh<_i152.LocalAuthentication>()),
    );
    gh.lazySingleton<_i891.PaymentsRemoteDataSource>(
      () => _i891.PaymentsRemoteDataSource(gh<_i643.PaymentsBackendClient>()),
    );
    gh.lazySingleton<_i133.LocalAuthRepository>(
      () => _i133.LocalAuthRepository(gh<_i192.LocalAuthClient>()),
    );
    gh.lazySingleton<_i823.PaymentsRepository>(
      () => _i823.PaymentsRepository(gh<_i891.PaymentsRemoteDataSource>()),
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
    gh.lazySingleton<_i637.SearchPaymentsUseCase>(
      () => _i637.SearchPaymentsUseCase(gh<_i823.PaymentsRepository>()),
    );
    gh.factory<_i237.PaymentsSearchBloc>(
      () => _i237.PaymentsSearchBloc(gh<_i637.SearchPaymentsUseCase>()),
    );
    return this;
  }
}

class _$DeviceAuthenticationModule extends _i925.DeviceAuthenticationModule {}

class _$MockBackendModule extends _i994.MockBackendModule {}
