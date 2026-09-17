import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/config/app_environment.dart';
import 'package:mamo_payment_approval_challenge/app/diagnostics/local_diagnostics.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/app_router.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies(AppEnvironment environment) async {
  getIt.registerSingleton<AppEnvironment>(environment);
  getIt.registerLazySingleton<LocalDiagnostics>(
    () => LocalDiagnostics(environment: environment),
  );
  getIt.registerSingleton<GoRouter>(
    createAppRouter(),
    dispose: (router) => router.dispose(),
  );
  await getIt.allReady();
}
