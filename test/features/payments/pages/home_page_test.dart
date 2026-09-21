import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/pages/home_page.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

import '../../../support/payments_test_support.dart';

void main() {
  for (final Brightness brightness in Brightness.values) {
    for (final Size size in <Size>[
      const Size(320, 640),
      const Size(768, 1024),
    ]) {
      testWidgets(
        'renders current summary and recent history at $size $brightness',
        (WidgetTester tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final Payment approved = approvedPayment();
          final Payment rejected = rejectedPayment();
          final Payment priorMonth = approvedPayment(
            id: 'prior-payment',
            counterparty: 'Previous month party',
            amount: 89.90,
            decidedAt: DateTime.utc(2026, 8, 30, 8),
          );
          final Payment pending = Payment(
            id: 'pending-payment',
            counterparty: 'Hidden pending party',
            amount: 50,
            currency: 'AED',
            reference: 'PENDING-1',
            createdAt: DateTime.utc(2026, 9, 17, 7),
            status: PaymentStatus.pending,
          );
          final StubPaymentsBackend backend = StubPaymentsBackend(
            onLoad: () async => <Payment>[
              priorMonth,
              pending,
              rejected,
              approved,
            ],
          );
          final PaymentsCubit cubit = createPaymentsCubit(backend);
          addTearDown(cubit.close);
          await cubit.load();
          var viewedAll = false;
          String? openedId;

          await tester.pumpWidget(
            _HomeTestApp(
              brightness: brightness,
              cubit: cubit,
              child: HomePage(
                onOpenPayment: (String id) => openedId = id,
                onViewAll: () => viewedAll = true,
                onOpenSettings: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.bySemanticsIdentifier('home.summary'), findsOneWidget);
          expect(find.text('AED 1,240.50'), findsWidgets);
          expect(find.text('1 approved payment'), findsOneWidget);
          expect(find.text('September 2026 · Asia/Dubai'), findsOneWidget);
          expect(find.text('Hidden pending party'), findsNothing);
          await tester.dragUntilVisible(
            find.bySemanticsIdentifier('payment.row.${approved.id}'),
            find.byKey(const PageStorageKey<String>('home.content')),
            const Offset(0, -300),
          );
          await tester.ensureVisible(
            find.bySemanticsIdentifier('payment.row.${approved.id}'),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.bySemanticsIdentifier('payment.row.${approved.id}'),
          );
          expect(openedId, approved.id);
          await tester.dragUntilVisible(
            find.bySemanticsIdentifier('home.viewAllPayments'),
            find.byKey(const PageStorageKey<String>('home.content')),
            const Offset(0, 300),
          );
          await tester.ensureVisible(
            find.bySemanticsIdentifier('home.viewAllPayments'),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.bySemanticsIdentifier('home.viewAllPayments'));
          expect(viewedAll, isTrue);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('loaded empty state keeps a valid zero summary', (
    WidgetTester tester,
  ) async {
    final StubPaymentsBackend backend = StubPaymentsBackend(
      onLoad: () async => const <Payment>[],
    );
    final PaymentsCubit cubit = createPaymentsCubit(backend);
    addTearDown(cubit.close);
    await cubit.load();

    await tester.pumpWidget(
      _HomeTestApp(
        brightness: Brightness.light,
        cubit: cubit,
        child: HomePage(
          onOpenPayment: (_) {},
          onViewAll: () {},
          onOpenSettings: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AED 0.00'), findsOneWidget);
    expect(find.text('No approved payments'), findsOneWidget);
    expect(find.bySemanticsIdentifier('home.recent.empty'), findsOneWidget);
    expect(find.bySemanticsIdentifier('payments.error'), findsNothing);
  });
}

class _HomeTestApp extends StatelessWidget {
  const _HomeTestApp({
    required this.brightness,
    required this.cubit,
    required this.child,
  });

  final Brightness brightness;
  final PaymentsCubit cubit;
  final Widget child;

  @override
  Widget build(BuildContext context) => BlocProvider<PaymentsCubit>.value(
    value: cubit,
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: brightness == Brightness.light
          ? ThemeMode.light
          : ThemeMode.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
