import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/app.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/app_router.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_motion.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/local_auth_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/local_authentication_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/stop_local_authentication_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/pages/home_page.dart';
import 'package:mamo_payment_approval_challenge/features/payments/pages/payment_details_page.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

import '../support/device_authentication_test_support.dart';
import '../support/payments_test_support.dart';

void main() {
  late MamoPaymentRouter appRouter;
  late GoRouter router;
  late StubPaymentsBackend backend;
  late PaymentsCubit cubit;
  late LocalAuthenticationUseCase authenticate;
  late StopLocalAuthenticationUseCase stop;

  setUp(() {
    backend = StubPaymentsBackend(
      onLoad: () async => <Payment>[approvedPayment(), rejectedPayment()],
    );
    cubit = createPaymentsCubit(backend);
    final LocalAuthRepository authRepository = LocalAuthRepository(
      FakeLocalAuthClient(),
    );
    authenticate = LocalAuthenticationUseCase(authRepository);
    stop = StopLocalAuthenticationUseCase(authRepository);
    appRouter = MamoPaymentRouter();
    router = appRouter.router;
  });
  tearDown(() async {
    appRouter.dispose();
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
        MamoPaymentApprovalApp(
          router: router,
          paymentsCubit: cubit,
          authenticate: authenticate,
          stopAuthentication: stop,
        ),
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
      MamoPaymentApprovalApp(
        router: router,
        paymentsCubit: cubit,
        authenticate: authenticate,
        stopAuthentication: stop,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig,
      same(router),
    );
    expect(router.canPop(), isFalse);
    expect(find.bySemanticsIdentifier('home.page'), findsOneWidget);
    expect(backend.loadCalls, 1);

    await tester.pumpWidget(
      MamoPaymentApprovalApp(
        router: router,
        paymentsCubit: cubit,
        authenticate: authenticate,
        stopAuthentication: stop,
      ),
    );
    await tester.pumpAndSettle();
    expect(backend.loadCalls, 1);
    expect(find.bySemanticsIdentifier('home.page'), findsOneWidget);
  });

  testWidgets('details return to their exact Home and Payments origins', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MamoPaymentApprovalApp(
        router: router,
        paymentsCubit: cubit,
        authenticate: authenticate,
        stopAuthentication: stop,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.bySemanticsIdentifier('payment.row.approved-payment'),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payment.details'), findsOneWidget);
    expect(find.bySemanticsIdentifier('navigation.compact'), findsNothing);
    expect(
      router.namedLocation(
        AppRoutes.paymentDetails,
        pathParameters: const <String, String>{'paymentId': 'approved-payment'},
      ),
      '/payments/payment/approved-payment',
    );
    final BuildContext detailsContext = tester.element(
      find.byType(PaymentDetailsPage),
    );
    expect(ModalRoute.of(detailsContext)!.settings, isA<AppMotionPage<void>>());
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
    expect(find.bySemanticsIdentifier('navigation.compact'), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payments.page'), findsOneWidget);
  });

  testWidgets('details reveal their content after the route becomes visible', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MamoPaymentApprovalApp(
        router: router,
        paymentsCubit: cubit,
        authenticate: authenticate,
        stopAuthentication: stop,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.bySemanticsIdentifier('payment.row.approved-payment'),
    );
    await tester.pump();

    Iterable<double> detailsOpacityValues() => tester
        .widgetList<Opacity>(
          find.descendant(
            of: find.byType(AppPageStaggeredColumn),
            matching: find.byType(Opacity),
          ),
        )
        .map((Opacity item) => item.opacity);

    expect(detailsOpacityValues(), everyElement(0));
    await tester.pump(const Duration(milliseconds: 170));
    expect(detailsOpacityValues(), everyElement(0));

    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 80));
    expect(detailsOpacityValues(), everyElement(greaterThan(0)));
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payment.details'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home and Payments content enters when its tab becomes active', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MamoPaymentApprovalApp(
        router: router,
        paymentsCubit: cubit,
        authenticate: authenticate,
        stopAuthentication: stop,
      ),
    );
    await tester.pumpAndSettle();

    Iterable<double> pageOpacityValues(String semanticsIdentifier) => tester
        .widgetList<Opacity>(
          find.descendant(
            of: find.bySemanticsIdentifier(semanticsIdentifier),
            matching: find.byType(Opacity),
          ),
        )
        .map((Opacity item) => item.opacity);

    await tester.tap(find.text('Payments'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 170));
    final List<double> enteringPayments = pageOpacityValues('payments.page')
        .toList(growable: false);
    expect(enteringPayments, isNotEmpty);
    expect(enteringPayments, contains(isNot(1)));
    await tester.pump(const Duration(milliseconds: 80));
    expect(
      pageOpacityValues('payments.page').first,
      greaterThanOrEqualTo(enteringPayments.first),
    );
    await tester.pumpAndSettle();
    expect(pageOpacityValues('payments.page'), everyElement(1));

    await tester.tap(find.text('Home'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 170));
    final List<double> enteringHome = pageOpacityValues('home.page')
        .toList(growable: false);
    expect(enteringHome, isNotEmpty);
    expect(enteringHome, contains(isNot(1)));
    await tester.pump(const Duration(milliseconds: 80));
    expect(
      pageOpacityValues('home.page').first,
      greaterThanOrEqualTo(enteringHome.first),
    );
    await tester.pumpAndSettle();
    expect(pageOpacityValues('home.page'), everyElement(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('horizontal swipes switch between Home and Payments', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MamoPaymentApprovalApp(
        router: router,
        paymentsCubit: cubit,
        authenticate: authenticate,
        stopAuthentication: stop,
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(
      find.bySemanticsIdentifier('navigation.swipeRegion'),
      const Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payments.page'), findsOneWidget);

    await tester.fling(
      find.bySemanticsIdentifier('navigation.swipeRegion'),
      const Offset(300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('home.page'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('system back returns to Home from the Payments destination', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MamoPaymentApprovalApp(
        router: router,
        paymentsCubit: cubit,
        authenticate: authenticate,
        stopAuthentication: stop,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('home.page'), findsOneWidget);

    // Reached Payments through the Home "View all" action.
    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payments.page'), findsOneWidget);

    final bool poppedFromViewAll = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(poppedFromViewAll, isTrue);
    expect(find.bySemanticsIdentifier('home.page'), findsOneWidget);

    // Same behaviour when Payments is reached through the nav bar.
    await tester.tap(find.text('Payments'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payments.page'), findsOneWidget);

    final bool poppedFromNavBar = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(poppedFromNavBar, isTrue);
    expect(find.bySemanticsIdentifier('home.page'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('iOS edge-back gesture returns from details to its origin', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MamoPaymentApprovalApp(
        router: router,
        paymentsCubit: cubit,
        authenticate: authenticate,
        stopAuthentication: stop,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.bySemanticsIdentifier('payment.row.approved-payment'),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payment.details'), findsOneWidget);
    expect(find.bySemanticsIdentifier('navigation.compact'), findsNothing);

    final TestGesture gesture = await tester.startGesture(const Offset(5, 300));
    await gesture.moveBy(const Offset(500, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('home.page'), findsOneWidget);
    expect(find.bySemanticsIdentifier('payment.details'), findsNothing);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('unknown paths stay safe across rebuilds and can return Home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MamoPaymentApprovalApp(
        router: router,
        paymentsCubit: cubit,
        authenticate: authenticate,
        stopAuthentication: stop,
      ),
    );
    await tester.pumpAndSettle();
    router.go('/missing/PRIVATE_PAYLOAD');
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('app.failure'), findsOneWidget);
    expect(find.textContaining('PRIVATE_PAYLOAD'), findsNothing);
    await tester.pumpWidget(
      MamoPaymentApprovalApp(
        router: router,
        paymentsCubit: cubit,
        authenticate: authenticate,
        stopAuthentication: stop,
      ),
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
        authenticate: authenticate,
        stopAuthentication: stop,
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
    backend = StubPaymentsBackend(
      onLoad: () async => <Payment>[octoberPayment],
    );
    await cubit.close();
    cubit = createPaymentsCubit(backend, clock: () => now);

    await tester.pumpWidget(
      MamoPaymentApprovalApp(
        router: router,
        paymentsCubit: cubit,
        authenticate: authenticate,
        stopAuthentication: stop,
      ),
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
