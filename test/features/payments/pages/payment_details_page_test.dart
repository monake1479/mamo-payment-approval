import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/pages/payment_details_page.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/widgets/payment_status_chip.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

import '../../../support/payments_test_support.dart';

void main() {
  for (final Brightness brightness in Brightness.values) {
    for (final Size size in <Size>[
      const Size(320, 640),
      const Size(768, 1024),
    ]) {
      testWidgets('renders complete decided details at $size in $brightness', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final Payment payment = approvedPayment();
        final StubPaymentsBackend backend = StubPaymentsBackend(
          onLoad: () async => <Payment>[payment],
        );
        final PaymentsCubit cubit = createPaymentsCubit(backend);
        addTearDown(cubit.close);
        await cubit.load();

        await tester.pumpWidget(
          _DetailsTestApp(
            brightness: brightness,
            cubit: cubit,
            child: PaymentDetailsPage(paymentId: payment.id),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.bySemanticsIdentifier('payment.details'), findsOneWidget);
        expect(
          find.bySemanticsIdentifier('payment.details.amount'),
          findsOneWidget,
        );
        expect(find.text('AED 1,240.50'), findsOneWidget);
        expect(find.text(payment.counterparty), findsOneWidget);
        expect(find.text(payment.reference), findsOneWidget);
        expect(find.text('Approved'), findsOneWidget);
        expect(find.byType(PaymentStatusChip), findsOneWidget);
        expect(
          find.ancestor(
            of: find.bySemanticsIdentifier('payment.status.approved'),
            matching: find.byType(Card),
          ),
          findsOneWidget,
        );
        expect(
          tester
              .getTopLeft(find.bySemanticsIdentifier('payment.status.approved'))
              .dy,
          greaterThan(
            tester
                .getTopLeft(
                  find.bySemanticsIdentifier('payment.details.counterparty'),
                )
                .dy,
          ),
        );
        await tester.ensureVisible(
          find.bySemanticsIdentifier('payment.details.decided'),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('anchors decided details at the top of the page', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final Payment payment = approvedPayment();
    final StubPaymentsBackend backend = StubPaymentsBackend(
      onLoad: () async => <Payment>[payment],
    );
    final PaymentsCubit cubit = createPaymentsCubit(backend);
    addTearDown(cubit.close);
    await cubit.load();

    await tester.pumpWidget(
      _DetailsTestApp(
        brightness: Brightness.light,
        cubit: cubit,
        child: PaymentDetailsPage(paymentId: payment.id),
      ),
    );
    await tester.pumpAndSettle();

    final double bodyTop = tester.getBottomLeft(find.byType(AppBar)).dy;
    final double detailsTop = tester
        .getTopLeft(find.bySemanticsIdentifier('payment.details'))
        .dy;
    expect(detailsTop, closeTo(bodyTop + AppTheme.sectionGap, 0.1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('resolves details from the latest canonical collection state', (
    WidgetTester tester,
  ) async {
    Payment currentPayment = approvedPayment();
    final StubPaymentsBackend backend = StubPaymentsBackend(
      onLoad: () async => <Payment>[currentPayment],
    );
    final PaymentsCubit cubit = createPaymentsCubit(backend);
    addTearDown(cubit.close);
    await cubit.load();

    await tester.pumpWidget(
      _DetailsTestApp(
        brightness: Brightness.light,
        cubit: cubit,
        child: PaymentDetailsPage(paymentId: currentPayment.id),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('AED 1,240.50'), findsOneWidget);

    currentPayment = Payment(
      id: currentPayment.id,
      counterparty: currentPayment.counterparty,
      amount: 1500.75,
      currency: currentPayment.currency,
      reference: currentPayment.reference,
      createdAt: currentPayment.createdAt,
      status: currentPayment.status,
      decidedAt: currentPayment.decidedAt,
    );
    await cubit.load();
    await tester.pumpAndSettle();

    expect(find.text('AED 1,500.75'), findsOneWidget);
    expect(find.text('AED 1,240.50'), findsNothing);
  });

  testWidgets('invalid and pending identifiers render safe missing UI', (
    WidgetTester tester,
  ) async {
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
      onLoad: () async => <Payment>[pending],
    );
    final PaymentsCubit cubit = createPaymentsCubit(backend);
    addTearDown(cubit.close);
    await cubit.load();

    for (final String id in <String>['missing-payment', pending.id]) {
      await tester.pumpWidget(
        _DetailsTestApp(
          brightness: Brightness.light,
          cubit: cubit,
          child: PaymentDetailsPage(paymentId: id),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsIdentifier('payment.details.notFound'),
        findsOneWidget,
      );
      expect(find.text('Payment not found'), findsOneWidget);
      expect(find.text('Hidden pending party'), findsNothing);
    }
  });
}

class _DetailsTestApp extends StatelessWidget {
  const _DetailsTestApp({
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
