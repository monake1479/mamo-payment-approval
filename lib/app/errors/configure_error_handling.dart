import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:mamo_approval/app/diagnostics/local_diagnostics.dart';
import 'package:mamo_approval/app/errors/app_failure.dart';
import 'package:mamo_approval/app/errors/app_failure_app.dart';

void configureErrorHandling(LocalDiagnostics diagnostics) {
  FlutterError.onError = (details) {
    diagnostics.record(
      AppFailureCode.unexpected,
      ErrorOrigin.framework,
      stack: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (_, stack) {
    diagnostics.record(
      AppFailureCode.unexpected,
      ErrorOrigin.platform,
      stack: stack,
    );
    return true;
  };
  ErrorWidget.builder = (_) =>
      const AppFailureApp(failure: AppFailureCode.unexpected);
}
