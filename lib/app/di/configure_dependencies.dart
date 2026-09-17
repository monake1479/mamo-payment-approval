import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/config/app_environment.dart';
import 'package:mamo_payment_approval_challenge/app/diagnostics/local_diagnostics.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/app_router.dart';
import 'package:mamo_payment_approval_challenge/features/payments/data/in_memory_payments_repository.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_operations.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/payments_cubit.dart';

final GetIt getIt = GetIt.instance;
const String _demoReportingTimeZone = 'Asia/Dubai';

Future<void> configureDependencies(AppEnvironment environment) async {
  getIt.registerSingleton<AppEnvironment>(environment);
  getIt.registerLazySingleton<LocalDiagnostics>(
    () => LocalDiagnostics(environment: environment),
  );
  getIt.registerLazySingleton<PaymentsRepository>(
    () => InMemoryPaymentsRepository.seeded(clock: _utcNow),
  );
  getIt.registerLazySingleton<PaymentOperations>(
    () => PaymentOperations(reportingTimeZone: _demoReportingTimeZone),
  );
  getIt.registerSingleton<PaymentsCubit>(
    PaymentsCubit(
      repository: getIt<PaymentsRepository>(),
      operations: getIt<PaymentOperations>(),
      clock: _utcNow,
    ),
    dispose: (PaymentsCubit cubit) => cubit.close(),
  );
  getIt.registerSingleton<GoRouter>(
    createAppRouter(),
    dispose: (router) => router.dispose(),
  );
  await getIt.allReady();
}

DateTime _utcNow() => DateTime.now().toUtc();
