import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/app.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/app_router.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/pages/foundation_page.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

void main() {
  late GoRouter router;
  setUp(() => router = createAppRouter());
  tearDown(() => router.dispose());

  for (final Locale deviceLocale in <Locale>[
    const Locale('en'),
    const Locale('en', 'GB'),
    const Locale('pl', 'PL'),
  ]) {
    testWidgets('renders English copy for device locale $deviceLocale', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.localesTestValue = <Locale>[deviceLocale];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(MamoPaymentApprovalApp(router: router));
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(FoundationPage));
      expect(Localizations.localeOf(context), const Locale('en'));
      expect(AppLocalizations.of(context).foundationTitle, 'Payment approval');
      expect(find.text('Payment approval'), findsOneWidget);
      expect(
        find.textContaining('project foundation is ready'),
        findsOneWidget,
      );
      expect(
        tester.widget<Title>(find.byType(Title)).title,
        'Payment Approval',
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final Size size in <Size>[const Size(320, 640), const Size(1024, 768)]) {
    testWidgets('localized foundation fits $size with large text', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(MamoPaymentApprovalApp(router: router));
      await tester.pumpAndSettle();

      expect(find.text('Payment approval'), findsOneWidget);
      await tester.ensureVisible(
        find.textContaining('project foundation is ready'),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('project foundation is ready'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('root uses the injected router and cannot pop an empty stack', (
    tester,
  ) async {
    await tester.pumpWidget(MamoPaymentApprovalApp(router: router));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig,
      same(router),
    );
    expect(router.canPop(), isFalse);
    expect(find.text('Payment approval'), findsOneWidget);
  });

  testWidgets(
    'unknown paths stay safe across rebuilds and can return to root',
    (tester) async {
      await tester.pumpWidget(MamoPaymentApprovalApp(router: router));
      await tester.pumpAndSettle();
      router.go('/missing/PRIVATE_PAYLOAD');
      await tester.pumpAndSettle();
      expect(find.bySemanticsIdentifier('app.failure'), findsOneWidget);
      expect(find.textContaining('PRIVATE_PAYLOAD'), findsNothing);
      await tester.pumpWidget(MamoPaymentApprovalApp(router: router));
      await tester.pumpAndSettle();
      expect(find.bySemanticsIdentifier('app.failure'), findsOneWidget);
      router.go('/');
      await tester.pumpAndSettle();
      expect(find.text('Payment approval'), findsOneWidget);
      expect(find.bySemanticsIdentifier('app.failure'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
