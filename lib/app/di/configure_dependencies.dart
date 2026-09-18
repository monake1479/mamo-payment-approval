import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:mamo_payment_approval_challenge/app/config/app_environment.dart';
import 'package:mamo_payment_approval_challenge/app/di/configure_dependencies.config.dart';
import 'package:mamo_payment_approval_challenge/app/diagnostics/local_diagnostics.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/app_router.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/create_payment_request_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/decide_payment_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/load_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/refresh_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies(AppEnvironment environment) async {
  getIt.registerSingleton<AppEnvironment>(environment);
  getIt.registerLazySingleton<LocalDiagnostics>(
    () => LocalDiagnostics(environment: environment),
  );
  getIt.init();
  getIt.registerSingleton<PaymentsCubit>(
    PaymentsCubit(
      loadPayments: getIt<LoadPaymentsUseCase>(),
      createPaymentRequest: getIt<CreatePaymentRequestUseCase>(),
      decidePayment: getIt<DecidePaymentUseCase>(),
      refreshPayments: getIt<RefreshPaymentsUseCase>(),
    ),
    dispose: (PaymentsCubit cubit) => cubit.close(),
  );
  getIt.registerSingleton<MamoPaymentRouter>(
    MamoPaymentRouter(),
    dispose: (router) => router.dispose(),
  );
  await getIt.allReady();
}
