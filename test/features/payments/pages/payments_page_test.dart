import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/features/payments/pages/payments_page.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

import '../../../support/payments_test_support.dart';

void main() {
  testWidgets('shows decided history newest first and excludes pending', (
    WidgetTester tester,
  ) async {
    final Payment newest = rejectedPayment(
      decidedAt: DateTime.utc(2026, 9, 17, 7),
    );
    final Payment older = approvedPayment(
      decidedAt: DateTime.utc(2026, 9, 16, 7),
    );
    final Payment pending = Payment(
      id: 'pending-payment',
      counterparty: 'Hidden Pending Party',
      amount: 45,
      currency: 'AED',
      reference: 'PENDING-1',
      createdAt: DateTime.utc(2026, 9, 17, 6),
      status: PaymentStatus.pending,
    );
    final StubPaymentsRepository repository = StubPaymentsRepository(
      onLoad: () async => Success<PaymentsFailure, List<Payment>>(<Payment>[
        older,
        pending,
        newest,
      ]),
    );
    final PaymentsCubit cubit = createPaymentsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    String? openedId;

    await tester.pumpWidget(
      _PaymentsTestApp(
        cubit: cubit,
        child: PaymentsPage(onOpenPayment: (String id) => openedId = id),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsIdentifier('payments.reportingTimeZone'),
      findsOneWidget,
    );
    expect(find.text('Times shown in Asia/Dubai'), findsOneWidget);
    expect(find.text('17 Sep 2026, 11:00'), findsOneWidget);
    expect(find.text('Hidden Pending Party'), findsNothing);
    expect(find.text(newest.counterparty), findsOneWidget);
    expect(find.text(older.counterparty), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(newest.counterparty)).dy,
      lessThan(tester.getTopLeft(find.text(older.counterparty)).dy),
    );
    await tester.tap(find.bySemanticsIdentifier('payment.row.${newest.id}'));
    expect(openedId, newest.id);
  });

  testWidgets('renders loading, empty, and recoverable failure states', (
    WidgetTester tester,
  ) async {
    final Completer<Result<PaymentsFailure, List<Payment>>> pendingLoad =
        Completer<Result<PaymentsFailure, List<Payment>>>();
    final StubPaymentsRepository loadingRepository = StubPaymentsRepository(
      onLoad: () => pendingLoad.future,
    );
    final PaymentsCubit loadingCubit = createPaymentsCubit(loadingRepository);
    addTearDown(loadingCubit.close);
    unawaited(loadingCubit.load());
    await tester.pumpWidget(
      _PaymentsTestApp(
        cubit: loadingCubit,
        child: PaymentsPage(onOpenPayment: (_) {}),
      ),
    );
    expect(find.bySemanticsIdentifier('payments.loading'), findsOneWidget);
    pendingLoad.complete(
      const Success<PaymentsFailure, List<Payment>>(<Payment>[]),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payments.empty'), findsOneWidget);

    var attempts = 0;
    final StubPaymentsRepository retryRepository = StubPaymentsRepository(
      onLoad: () async {
        attempts += 1;
        return attempts == 1
            ? const Failure<PaymentsFailure, List<Payment>>(
                PaymentsUnavailableFailure(),
              )
            : const Success<PaymentsFailure, List<Payment>>(<Payment>[]);
      },
    );
    final PaymentsCubit retryCubit = createPaymentsCubit(retryRepository);
    addTearDown(retryCubit.close);
    await retryCubit.load();
    await tester.pumpWidget(
      _PaymentsTestApp(
        cubit: retryCubit,
        child: PaymentsPage(onOpenPayment: (_) {}),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payments.error'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payments.empty'), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets('reporting-zone context fits compact layout at 200% text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final StubPaymentsRepository repository = StubPaymentsRepository(
      onLoad: () async =>
          Success<PaymentsFailure, List<Payment>>(<Payment>[approvedPayment()]),
    );
    final PaymentsCubit cubit = createPaymentsCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();

    await tester.pumpWidget(
      _PaymentsTestApp(
        cubit: cubit,
        child: PaymentsPage(onOpenPayment: (_) {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Times shown in Asia/Dubai'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _PaymentsTestApp extends StatelessWidget {
  const _PaymentsTestApp({required this.cubit, required this.child});

  final PaymentsCubit cubit;
  final Widget child;

  @override
  Widget build(BuildContext context) => BlocProvider<PaymentsCubit>.value(
    value: cubit,
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
