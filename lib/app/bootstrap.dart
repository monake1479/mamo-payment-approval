import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mamo_payment_approval_challenge/app/app.dart';
import 'package:mamo_payment_approval_challenge/app/config/app_environment.dart';
import 'package:mamo_payment_approval_challenge/app/di/configure_dependencies.dart';
import 'package:mamo_payment_approval_challenge/app/diagnostics/local_diagnostics.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure_app.dart';
import 'package:mamo_payment_approval_challenge/app/errors/configure_error_handling.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/app_router.dart';
import 'package:mamo_payment_approval_challenge/app/platform/app_orientation.dart';

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
  runApp(MamoPaymentApprovalApp(router: getIt<MamoPaymentRouter>().router));
}
