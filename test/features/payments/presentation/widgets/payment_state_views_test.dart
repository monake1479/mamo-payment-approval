import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/widgets/monthly_summary_card.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/widgets/payment_state_views.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

void main() {
  for (final Brightness brightness in Brightness.values) {
    for (final Size size in <Size>[
      const Size(320, 640),
      const Size(768, 1024),
    ]) {
      testWidgets('payment states fit $brightness at $size with large text', (
        WidgetTester tester,
      ) async {
        await _configureSurface(tester, brightness: brightness, size: size);

        await tester.pumpWidget(
          _TestApp(brightness: brightness, child: const PaymentsLoadingView()),
        );
        expect(find.bySemanticsIdentifier('payments.loading'), findsOneWidget);

        await tester.pumpWidget(
          _TestApp(
            brightness: brightness,
            child: const PaymentsEmptyView(
              title: 'No decided payments yet',
              description: 'Approved and rejected payments will appear here.',
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.bySemanticsIdentifier('payments.empty'), findsOneWidget);
        expect(find.text('No decided payments yet'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('payment error offers an explicit retry', (
    WidgetTester tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      _TestApp(
        brightness: Brightness.light,
        child: PaymentsErrorView(
          failure: const StorageFailure(),
          onRetry: () => retries += 1,
        ),
      ),
    );
    expect(find.bySemanticsIdentifier('payments.error'), findsOneWidget);
    expect(find.text('Payments are unavailable'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('invalid payment data maps to safe localized copy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        brightness: Brightness.light,
        child: PaymentsErrorView(
          failure: const InvalidPaymentFailure(
            InvalidPaymentReason.malformedRecord,
          ),
          onRetry: () {},
        ),
      ),
    );
    expect(
      find.text('Some payment data could not be read. Try again.'),
      findsOneWidget,
    );
  });

  testWidgets('operation failures use safe generic recovery copy', (
    WidgetTester tester,
  ) async {
    for (final PaymentsFailure failure in <PaymentsFailure>[
      const DuplicateRequestFailure(),
      const PaymentNotFoundFailure(),
      const PaymentAlreadyDecidedFailure(),
      const PaymentBusyFailure(),
      const StorageFailure(),
    ]) {
      await tester.pumpWidget(
        _TestApp(
          brightness: Brightness.light,
          child: PaymentsErrorView(failure: failure, onRetry: () {}),
        ),
      );
      expect(
        find.text('We could not load the payment history. Try again.'),
        findsOneWidget,
      );
    }
  });

  testWidgets('zero monthly summary is valid data at large text', (
    WidgetTester tester,
  ) async {
    await _configureSurface(
      tester,
      brightness: Brightness.dark,
      size: const Size(320, 640),
    );
    await tester.pumpWidget(
      const _TestApp(
        brightness: Brightness.dark,
        child: SingleChildScrollView(
          child: MonthlySummaryCard(
            amount: 'AED 0.00',
            approvedCount: 0,
            month: 'September 2026',
            reportingTimeZone: 'Asia/Dubai',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('home.summary'), findsOneWidget);
    expect(find.bySemanticsIdentifier('home.summary.amount'), findsOneWidget);
    expect(find.bySemanticsIdentifier('home.summary.count'), findsOneWidget);
    expect(find.text('AED 0.00'), findsOneWidget);
    expect(find.text('No approved payments'), findsOneWidget);
    expect(find.text('September 2026 · Asia/Dubai'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _configureSurface(
  WidgetTester tester, {
  required Brightness brightness,
  required Size size,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.brightness, required this.child});

  final Brightness brightness;
  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: brightness == Brightness.light
        ? ThemeMode.light
        : ThemeMode.dark,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
