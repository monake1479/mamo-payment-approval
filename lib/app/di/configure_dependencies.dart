import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:mamo_payment_approval_challenge/app/config/app_environment.dart';
import 'package:mamo_payment_approval_challenge/app/di/configure_dependencies.config.dart';
import 'package:mamo_payment_approval_challenge/app/diagnostics/local_diagnostics.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/app_router.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies(AppEnvironment environment) async {
  getIt.registerSingleton<AppEnvironment>(environment);
  getIt.registerLazySingleton<LocalDiagnostics>(
    () => LocalDiagnostics(environment: environment),
  );
  getIt.registerSingleton<MamoPaymentRouter>(
    MamoPaymentRouter(),
    dispose: (router) => router.dispose(),
  );
  getIt.init();
  await getIt.allReady();
}
