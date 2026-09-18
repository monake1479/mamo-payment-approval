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
import 'package:mamo_payment_approval_challenge/app/di/mock_backend_module.dart'
    as _i853;
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

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final mockBackendModule = _$MockBackendModule();
    gh.lazySingleton<_i677.PaymentsBackendClient>(
      () => mockBackendModule.paymentsBackendClient(),
    );
    gh.lazySingleton<_i462.PaymentsRemoteDataSource>(
      () => _i462.PaymentsRemoteDataSource(gh<_i677.PaymentsBackendClient>()),
    );
    gh.lazySingleton<_i831.PaymentsRepository>(
      () => _i831.PaymentsRepository(gh<_i462.PaymentsRemoteDataSource>()),
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

class _$MockBackendModule extends _i853.MockBackendModule {}
