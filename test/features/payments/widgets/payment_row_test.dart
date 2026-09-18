import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/formatters/payment_formatters.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/payment_row.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/payment_status_chip.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

void main() {
  for (final Brightness brightness in Brightness.values) {
    testWidgets('decided payment row is accessible at 200% in $brightness', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      var taps = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: brightness == Brightness.light
              ? ThemeMode.light
              : ThemeMode.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PaymentRow(
              payment: Payment(
                id: 'payment-1',
                counterparty: 'A long synthetic counterparty name',
                amount: 1234.5,
                currency: 'AED',
                reference: 'REFERENCE-1',
                createdAt: DateTime.utc(2026, 9, 1, 8),
                status: PaymentStatus.approved,
                decidedAt: DateTime.utc(2026, 9, 2, 10),
              ),
              formatters: PaymentFormatters(reportingTimeZone: 'Asia/Dubai'),
              onTap: () => taps += 1,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier('payment.row.payment-1'),
        findsOneWidget,
      );
      expect(
        tester.getSemantics(
          find.bySemanticsIdentifier('payment.row.payment-1'),
        ),
        matchesSemantics(
          identifier: 'payment.row.payment-1',
          label:
              'A long synthetic counterparty name, AED 1,234.50, Approved, '
              'decided 02 Sep 2026, 14:00',
          isButton: true,
          hasTapAction: true,
        ),
      );
      expect(find.text('A long synthetic counterparty name'), findsOneWidget);
      expect(find.text('AED 1,234.50'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.byType(PaymentStatusChip), findsOneWidget);
      expect(find.text('02 Sep 2026, 14:00'), findsOneWidget);
      await tester.tap(find.bySemanticsIdentifier('payment.row.payment-1'));
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('rejected status has text and icon semantics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PaymentRow(
            payment: Payment(
              id: 'payment-2',
              counterparty: 'Synthetic recipient',
              amount: 25,
              currency: 'AED',
              reference: 'REFERENCE-2',
              createdAt: DateTime.utc(2026, 9, 1, 8),
              status: PaymentStatus.rejected,
              decidedAt: DateTime.utc(2026, 9, 2, 10),
            ),
            formatters: PaymentFormatters(reportingTimeZone: 'Asia/Dubai'),
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('Rejected'), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    expect(find.byType(PaymentStatusChip), findsOneWidget);
  });
}
