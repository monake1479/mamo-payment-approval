import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/app/app.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure_app.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/app_router.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';

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
    });
  }

  for (final Brightness brightness in Brightness.values) {
    for (final Size size in <Size>[
      const Size(320, 640),
      const Size(1024, 768),
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
        final router = createAppRouter();
        addTearDown(router.dispose);
        final repository = StubPaymentsRepository(
          onLoad: () async => const PaymentsSuccess<List<Payment>>(<Payment>[]),
        );
        final cubit = createPaymentsCubit(repository);
        addTearDown(cubit.close);
        await tester.pumpWidget(
          MamoPaymentApprovalApp(
            router: router,
            paymentsCubit: cubit,
            deviceAuthenticator: StubDeviceAuthenticator(),
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
