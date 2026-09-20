import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/app/app.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure_app.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/app_router.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_motion.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_status_colors.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';

import '../support/payments_test_support.dart';

double contrast(Color first, Color second) {
  final double a = first.computeLuminance();
  final double b = second.computeLuminance();
  return a > b ? (a + 0.05) / (b + 0.05) : (b + 0.05) / (a + 0.05);
}

void main() {
  for (final ThemeData theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
    test('${theme.brightness} text and action contrast', () {
      final ColorScheme colors = theme.colorScheme;
      for (final Color background in <Color>[
        colors.surface,
        colors.surfaceContainerLow,
      ]) {
        expect(
          contrast(colors.onSurface, background),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(colors.onSurfaceVariant, background),
          greaterThanOrEqualTo(4.5),
        );
        expect(contrast(colors.primary, background), greaterThanOrEqualTo(4.5));
      }
      expect(
        contrast(colors.primary, colors.onPrimary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        theme.filledButtonTheme.style!.minimumSize!.resolve(<WidgetState>{}),
        const Size(48, 48),
      );
      final InputDecorationThemeData fields = theme.inputDecorationTheme;
      expect(fields.filled, isTrue);
      expect(
        (fields.enabledBorder! as OutlineInputBorder).borderRadius,
        BorderRadius.circular(AppTheme.controlRadius),
      );
      expect(
        (fields.focusedBorder! as OutlineInputBorder).borderSide,
        BorderSide(color: colors.primary, width: 2),
      );
      expect(
        (fields.focusedErrorBorder! as OutlineInputBorder).borderSide,
        BorderSide(color: colors.error, width: 2),
      );
      expect(theme.chipTheme.shape, isA<RoundedRectangleBorder>());
      expect(
        theme.navigationRailTheme.backgroundColor,
        colors.surfaceContainerLow,
      );
      expect(theme.navigationRailTheme.indicatorColor, colors.primaryContainer);
      expect(theme.dividerTheme.color, colors.outlineVariant);
      expect(theme.dividerTheme.thickness, 1);
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.fixed);
      expect(theme.snackBarTheme.backgroundColor, colors.inverseSurface);
      final AppStatusColors statusColors = theme.extension<AppStatusColors>()!;
      expect(
        contrast(statusColors.infoContainer, statusColors.onInfoContainer),
        greaterThanOrEqualTo(4.5),
      );
      expect(statusColors.infoContainer, isNot(colors.primaryContainer));
      expect(
        contrast(
          statusColors.pendingContainer,
          statusColors.onPendingContainer,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(statusColors.pendingContainer, isNot(colors.primaryContainer));
      final SystemUiOverlayStyle systemUiStyle = AppTheme.systemUiOverlayStyle(
        colors,
      );
      expect(systemUiStyle.statusBarColor, colors.surface);
      expect(systemUiStyle.statusBarBrightness, theme.brightness);
      expect(
        systemUiStyle.statusBarIconBrightness,
        theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      );
      expect(theme.appBarTheme.systemOverlayStyle, systemUiStyle);
      expect(
        theme.pageTransitionsTheme.builders[TargetPlatform.android],
        isA<AppPageTransitionsBuilder>(),
      );
      expect(
        theme.pageTransitionsTheme.builders[TargetPlatform.iOS],
        isA<AppCupertinoPageTransitionsBuilder>(),
      );
    });
  }

  for (final Brightness brightness in Brightness.values) {
    for (final Size size in <Size>[
      const Size(320, 640),
      const Size(768, 1024),
    ]) {
      testWidgets('system $brightness at $size with enlarged text', (
        tester,
      ) async {
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final MamoPaymentRouter appRouter = MamoPaymentRouter();
        addTearDown(appRouter.dispose);
        final backend = StubPaymentsBackend(
          onLoad: () async => const <Payment>[],
        );
        final cubit = createPaymentsCubit(backend);
        addTearDown(cubit.close);
        await tester.pumpWidget(
          MamoPaymentApprovalApp(
            router: appRouter.router,
            paymentsCubit: cubit,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          Theme.of(tester.element(find.bySemanticsIdentifier('home.page')))
              .brightness,
          brightness,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(
          const AppFailureApp(failure: AppFailureCode.startupFailed),
        );
        await tester.pumpAndSettle();
        expect(
          Theme.of(tester.element(find.byType(Scaffold))).brightness,
          brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
