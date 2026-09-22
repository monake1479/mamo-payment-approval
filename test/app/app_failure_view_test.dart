import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/app/config/app_environment.dart';
import 'package:mamo_approval/app/diagnostics/local_diagnostics.dart';
import 'package:mamo_approval/app/errors/app_failure.dart';
import 'package:mamo_approval/app/errors/app_failure_app.dart';
import 'package:mamo_approval/app/errors/app_failure_view.dart';
import 'package:mamo_approval/app/errors/configure_error_handling.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

void main() {
  for (final Size size in <Size>[const Size(320, 640), const Size(768, 1024)]) {
    for (final AppFailureCode code in AppFailureCode.values) {
      testWidgets('$code is localized at $size with large text', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(AppFailureApp(failure: code));
        await tester.pumpAndSettle();
        final BuildContext context = tester.element(
          find.byType(AppFailureView),
        );
        final String message = code.message(AppLocalizations.of(context));
        await tester.ensureVisible(find.text(message));
        expect(find.text(message), findsOneWidget);
        expect(find.bySemanticsIdentifier('app.failure'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'a build error renders localized UI without exposing its exception',
    (tester) async {
      final void Function(FlutterErrorDetails)? previousFlutter =
          FlutterError.onError;
      final bool Function(Object, StackTrace)? previousPlatform =
          PlatformDispatcher.instance.onError;
      final ErrorWidgetBuilder previousBuilder = ErrorWidget.builder;
      final List<String> records = <String>[];
      configureErrorHandling(
        LocalDiagnostics(environment: AppEnvironment.dev, write: records.add),
      );
      try {
        await tester.pumpWidget(const _BrokenWidget());
        await tester.pumpAndSettle();
        expect(find.text('Unable to continue'), findsOneWidget);
        expect(find.textContaining('PRIVATE_PAYLOAD'), findsNothing);
        expect(records, hasLength(1));
        expect(records.single, isNot(contains('PRIVATE_PAYLOAD')));
      } finally {
        FlutterError.onError = previousFlutter;
        PlatformDispatcher.instance.onError = previousPlatform;
        ErrorWidget.builder = previousBuilder;
      }
    },
  );
}

class _BrokenWidget extends StatelessWidget {
  const _BrokenWidget();

  @override
  Widget build(BuildContext context) => throw StateError('PRIVATE_PAYLOAD');
}
