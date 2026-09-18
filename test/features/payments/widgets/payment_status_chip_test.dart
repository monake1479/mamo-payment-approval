import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_status_colors.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/payment_status_chip.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

void main() {
  for (final ThemeData theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
    testWidgets('${theme.brightness} status chips use semantic theme roles', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Wrap(
              children: <Widget>[
                PaymentStatusChip(status: PaymentStatusVisual.approved),
                PaymentStatusChip(status: PaymentStatusVisual.pending),
                PaymentStatusChip(status: PaymentStatusVisual.rejected),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Approved'), findsOneWidget);
      expect(find.bySemanticsLabel('Pending'), findsOneWidget);
      expect(find.bySemanticsLabel('Rejected'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);

      final List<Chip> chips = tester
          .widgetList<Chip>(find.byType(Chip))
          .toList();
      final AppStatusColors statusColors = theme.extension<AppStatusColors>()!;
      expect(chips[0].backgroundColor, theme.colorScheme.primaryContainer);
      expect(chips[1].backgroundColor, statusColors.pendingContainer);
      expect(chips[2].backgroundColor, theme.colorScheme.errorContainer);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  }
}
