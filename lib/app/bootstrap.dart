import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mamo_approval/app/app.dart';
import 'package:mamo_approval/app/config/app_environment.dart';
import 'package:mamo_approval/app/di/configure_dependencies.dart';
import 'package:mamo_approval/app/diagnostics/local_diagnostics.dart';
import 'package:mamo_approval/app/errors/app_failure.dart';
import 'package:mamo_approval/app/errors/app_failure_app.dart';
import 'package:mamo_approval/app/errors/configure_error_handling.dart';
import 'package:mamo_approval/app/navigation/app_router.dart';
import 'package:mamo_approval/app/platform/app_orientation.dart';
import 'package:mamo_approval/common/data/device_authentication/use_cases/local_authentication_use_case.dart';
import 'package:mamo_approval/common/data/device_authentication/use_cases/stop_local_authentication_use_case.dart';
import 'package:mamo_approval/features/payments/states/payments/payments_cubit.dart';

Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await configureAppOrientation();
    validateAppEnvironment(environment, appFlavor);
    await configureDependencies(environment);
  } on AppEnvironmentMismatch {
    LocalDiagnostics(environment: environment)
        .record(AppFailureCode.environmentMismatch, ErrorOrigin.startup);
    runApp(const AppFailureApp(failure: AppFailureCode.environmentMismatch));
    return;
  } catch (_, stack) {
    LocalDiagnostics(
      environment: environment,
    ).record(AppFailureCode.startupFailed, ErrorOrigin.startup, stack: stack);
    runApp(const AppFailureApp(failure: AppFailureCode.startupFailed));
    return;
  }

  configureErrorHandling(getIt<LocalDiagnostics>());
  runApp(
    MamoPaymentApprovalApp(
      router: getIt<MamoPaymentRouter>().router,
      paymentsCubit: getIt<PaymentsCubit>(),
      authenticate: getIt<LocalAuthenticationUseCase>(),
      stopAuthentication: getIt<StopLocalAuthenticationUseCase>(),
    ),
  );
}
