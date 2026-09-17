import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/app.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/app_router.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_operations.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/pages/home_page.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

import '../support/payments_test_support.dart';

void main() {
  late GoRouter router;
  late StubPaymentsRepository repository;
  late PaymentsCubit cubit;

  setUp(() {
    repository = StubPaymentsRepository(
      onLoad: () async => PaymentsSuccess<List<Payment>>(<Payment>[
        approvedPayment(),
        rejectedPayment(),
      ]),
    );
    cubit = createPaymentsCubit(repository);
    router = createAppRouter();
  });
  tearDown(() async {
    router.dispose();
    await cubit.close();
  });

  for (final Locale deviceLocale in <Locale>[
    const Locale('en'),
    const Locale('en', 'GB'),
    const Locale('pl', 'PL'),
  ]) {
    testWidgets('renders English Home for device locale $deviceLocale', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.localesTestValue = <Locale>[deviceLocale];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(
        MamoPaymentApprovalApp(router: router, paymentsCubit: cubit),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(HomePage));
      expect(Localizations.localeOf(context), const Locale('en'));
      expect(AppLocalizations.of(context).homeTitle, 'Home');
      expect(find.text('Home'), findsWidgets);
      expect(find.text('AED 1,240.50'), findsWidgets);
      expect(
        tester.widget<Title>(find.byType(Title)).title,
        'Payment Approval',
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('root uses the injected router and loads once across rebuilds', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MamoPaymentApprovalApp(router: router, paymentsCubit: cubit),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig,
      same(router),
    );
    expect(router.canPop(), isFalse);
    expect(find.bySemanticsIdentifier('home.page'), findsOneWidget);
    expect(repository.loadCalls, 1);

    await tester.pumpWidget(
      MamoPaymentApprovalApp(router: router, paymentsCubit: cubit),
    );
    await tester.pumpAndSettle();
    expect(repository.loadCalls, 1);
    expect(find.bySemanticsIdentifier('home.page'), findsOneWidget);
  });

  testWidgets('details return to their exact Home and Payments origins', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MamoPaymentApprovalApp(router: router, paymentsCubit: cubit),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.bySemanticsIdentifier('payment.row.approved-payment'),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payment.details'), findsOneWidget);
    await tester.tap(find.bySemanticsIdentifier('payment.details.back'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('home.page'), findsOneWidget);

    await tester.tap(find.text('Payments'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payments.page'), findsOneWidget);
    await tester.tap(
      find.bySemanticsIdentifier('payment.row.approved-payment'),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payment.details'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payments.page'), findsOneWidget);
  });

  testWidgets('unknown paths stay safe across rebuilds and can return Home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MamoPaymentApprovalApp(router: router, paymentsCubit: cubit),
    );
    await tester.pumpAndSettle();
    router.go('/missing/PRIVATE_PAYLOAD');
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('app.failure'), findsOneWidget);
    expect(find.textContaining('PRIVATE_PAYLOAD'), findsNothing);
    await tester.pumpWidget(
      MamoPaymentApprovalApp(router: router, paymentsCubit: cubit),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('app.failure'), findsOneWidget);
    router.goNamed(AppRoutes.home);
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('home.page'), findsOneWidget);
    expect(find.bySemanticsIdentifier('app.failure'), findsNothing);
  });

  testWidgets('global layer builder wraps the navigator without replacing it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MamoPaymentApprovalApp(
        router: router,
        paymentsCubit: cubit,
        globalLayerBuilder: (BuildContext context, Widget navigator) => Stack(
          children: <Widget>[
            navigator,
            const IgnorePointer(child: SizedBox(key: Key('global-layer'))),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('global-layer')), findsOneWidget);
    expect(find.bySemanticsIdentifier('home.page'), findsOneWidget);
  });

  testWidgets('resume refreshes the account-month summary', (
    WidgetTester tester,
  ) async {
    DateTime now = DateTime.utc(2026, 9, 17, 8);
    final Payment octoberPayment = approvedPayment(
      id: 'october-payment',
      amount: 10,
      decidedAt: DateTime.utc(2026, 10),
    );
    repository = StubPaymentsRepository(
      onLoad: () async =>
          PaymentsSuccess<List<Payment>>(<Payment>[octoberPayment]),
    );
    await cubit.close();
    cubit = PaymentsCubit(
      repository: repository,
      operations: PaymentOperations(reportingTimeZone: 'Asia/Dubai'),
      clock: () => now,
    );

    await tester.pumpWidget(
      MamoPaymentApprovalApp(router: router, paymentsCubit: cubit),
    );
    await tester.pumpAndSettle();
    expect(find.text('AED 0.00'), findsOneWidget);
    expect(find.text('September 2026 · Asia/Dubai'), findsOneWidget);

    now = DateTime.utc(2026, 10, 2);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('AED 10.00'), findsWidgets);
    expect(find.text('October 2026 · Asia/Dubai'), findsOneWidget);
  });
}
