import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_motion.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/pages/payments_page.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/search/payments_search_bloc.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';
import 'package:mamo_payment_approval_challenge/mock_backend/payments/payments_backend_exception.dart';

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
    final StubPaymentsBackend backend = StubPaymentsBackend(
      onLoad: () async => <Payment>[older, pending, newest],
    );
    final PaymentsCubit cubit = createPaymentsCubit(backend);
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
    expect(find.text('Times shown in Asia/Dubai'), findsOneWidget);
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
    final Completer<List<Payment>> pendingLoad = Completer<List<Payment>>();
    final StubPaymentsBackend loadingBackend = StubPaymentsBackend(
      onLoad: () => pendingLoad.future,
    );
    final PaymentsCubit loadingCubit = createPaymentsCubit(loadingBackend);
    addTearDown(loadingCubit.close);
    unawaited(loadingCubit.load());
    await tester.pumpWidget(
      _PaymentsTestApp(
        cubit: loadingCubit,
        child: PaymentsPage(onOpenPayment: (_) {}),
      ),
    );
    expect(find.bySemanticsIdentifier('payments.loading'), findsOneWidget);
    pendingLoad.complete(const <Payment>[]);
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('payments.empty'), findsOneWidget);

    var attempts = 0;
    final StubPaymentsBackend retryBackend = StubPaymentsBackend(
      onLoad: () async {
        attempts += 1;
        if (attempts == 1) {
          throw const PaymentsBackendException(
            PaymentsBackendErrorCode.unavailable,
          );
        }
        return const <Payment>[];
      },
    );
    final PaymentsCubit retryCubit = createPaymentsCubit(retryBackend);
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

  testWidgets('reveals loaded history after the loading state fades out', (
    WidgetTester tester,
  ) async {
    final Completer<List<Payment>> pendingLoad = Completer<List<Payment>>();
    final StubPaymentsBackend backend = StubPaymentsBackend(
      onLoad: () => pendingLoad.future,
    );
    final PaymentsCubit cubit = createPaymentsCubit(backend);
    addTearDown(cubit.close);
    unawaited(cubit.load());

    await tester.pumpWidget(
      _PaymentsTestApp(
        cubit: cubit,
        child: PaymentsPage(onOpenPayment: (_) {}),
      ),
    );
    expect(find.bySemanticsIdentifier('payments.loading'), findsOneWidget);

    pendingLoad.complete(<Payment>[approvedPayment()]);
    await tester.pump();
    await tester.pump();

    Iterable<double> historyOpacityValues() => tester
        .widgetList<Opacity>(
          find.descendant(
            of: find.byType(AppStaggeredColumn),
            matching: find.byType(Opacity),
          ),
        )
        .map((Opacity item) => item.opacity);

    expect(historyOpacityValues(), everyElement(0));
    await tester.pump(AppMotion.fast - const Duration(milliseconds: 1));
    expect(historyOpacityValues(), everyElement(0));

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 80));
    final List<double> entering = historyOpacityValues().toList(
      growable: false,
    );
    // Reporting zone, search controls, and history enter as three groups.
    expect(entering, hasLength(3));
    expect(entering.first, greaterThan(0));
    expect(entering.first, greaterThan(entering[1]));
    expect(entering[1], greaterThanOrEqualTo(entering.last));

    await tester.pumpAndSettle();
    expect(find.text('Atlas Office Supplies'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('search and status filtering', () {
    // A focused field's blinking cursor keeps scheduling frames, so settle on
    // a deterministic cursor instead of timing out `pumpAndSettle`.
    setUp(() => EditableText.debugDeterministicCursor = true);
    tearDown(() => EditableText.debugDeterministicCursor = false);
    final Payment atlas = approvedPayment(
      decidedAt: DateTime.utc(2026, 9, 16, 7),
    );
    final Payment marina = rejectedPayment(
      decidedAt: DateTime.utc(2026, 9, 17, 7),
    );
    final Payment pending = pendingPayment(
      counterparty: 'Marina Hidden Pending',
      reference: 'PO-9999',
    );

    // The provider owns the bloc so it closes while the widget tree is torn
    // down inside the test zone; closing a Bloc from `addTearDown` would wait
    // on event-stream microtasks that never run once the test zone has ended.
    Future<(PaymentsCubit, StubPaymentsBackend)> pumpPage(
      WidgetTester tester, {
      required Future<List<Payment>> Function() onLoad,
      Duration debounceDuration = Duration.zero,
      ValueChanged<String>? onOpenPayment,
    }) async {
      final StubPaymentsBackend backend = StubPaymentsBackend(onLoad: onLoad);
      final PaymentsCubit cubit = createPaymentsCubit(backend);
      addTearDown(cubit.close);
      await cubit.load();
      await tester.pumpWidget(
        _PaymentsTestApp(
          cubit: cubit,
          createSearchBloc: () => createPaymentsSearchBloc(
            backend,
            debounceDuration: debounceDuration,
          ),
          child: PaymentsPage(onOpenPayment: onOpenPayment ?? (_) {}),
        ),
      );
      await tester.pumpAndSettle();
      return (cubit, backend);
    }

    PaymentsSearchBloc searchBlocOf(WidgetTester tester) =>
        tester.element(find.byType(PaymentsPage)).read<PaymentsSearchBloc>();

    testWidgets('matches visible counterparty or reference, never pending', (
      WidgetTester tester,
    ) async {
      String? openedId;
      await pumpPage(
        tester,
        onLoad: () async => <Payment>[atlas, pending, marina],
        onOpenPayment: (String id) => openedId = id,
      );
      expect(find.bySemanticsIdentifier('payments.search.field'), findsOne);
      expect(find.text(atlas.counterparty), findsOneWidget);
      expect(find.text(marina.counterparty), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'MARINA');
      await tester.pumpAndSettle();

      expect(find.text('1 matching payment'), findsOneWidget);
      expect(find.text(marina.counterparty), findsOneWidget);
      expect(find.text(atlas.counterparty), findsNothing);
      expect(find.text(pending.counterparty), findsNothing);
      await tester.tap(find.bySemanticsIdentifier('payment.row.${marina.id}'));
      expect(openedId, marina.id);

      await tester.enterText(find.byType(TextField), 'po-');
      await tester.pumpAndSettle();
      expect(find.text(atlas.counterparty), findsOneWidget);
      expect(find.text(pending.counterparty), findsNothing);
      expect(find.text('PO-9999'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty result explains itself and clear restores history', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, onLoad: () async => <Payment>[atlas, marina]);

      await tester.enterText(find.byType(TextField), 'nobody');
      await tester.pumpAndSettle();
      expect(find.bySemanticsIdentifier('payments.search.empty'), findsOne);
      expect(find.text('No matching payments'), findsOneWidget);
      expect(find.text(atlas.counterparty), findsNothing);

      await tester.tap(find.bySemanticsIdentifier('payments.search.clear'));
      await tester.pumpAndSettle();
      expect(searchBlocOf(tester).state.isActive, isFalse);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
      expect(find.bySemanticsIdentifier('payments.search.empty'), findsNothing);
      expect(find.text(atlas.counterparty), findsOneWidget);
      expect(find.text(marina.counterparty), findsOneWidget);
    });

    testWidgets('status chips filter the history and combine with text', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester, onLoad: () async => <Payment>[atlas, marina]);
      final Finder approvedChip = find.bySemanticsIdentifier(
        'payments.search.filter.approved',
      );
      final Finder rejectedChip = find.bySemanticsIdentifier(
        'payments.search.filter.rejected',
      );
      expect(tester.getSize(approvedChip).height, greaterThanOrEqualTo(48));

      await tester.tap(approvedChip);
      await tester.pumpAndSettle();
      expect(find.text(atlas.counterparty), findsOneWidget);
      expect(find.text(marina.counterparty), findsNothing);

      await tester.tap(rejectedChip);
      await tester.pumpAndSettle();
      expect(find.text('2 matching payments'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'ship');
      await tester.pumpAndSettle();
      expect(find.text(marina.counterparty), findsOneWidget);
      expect(find.text(atlas.counterparty), findsNothing);

      await tester.tap(rejectedChip);
      await tester.pumpAndSettle();
      expect(find.bySemanticsIdentifier('payments.search.empty'), findsOne);

      // No selected status means every decided status again.
      await tester.tap(approvedChip);
      await tester.pumpAndSettle();
      expect(find.bySemanticsIdentifier('payments.search.empty'), findsNothing);
      expect(find.text(marina.counterparty), findsOneWidget);
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(find.text(atlas.counterparty), findsOneWidget);
      expect(find.text(marina.counterparty), findsOneWidget);
    });

    testWidgets('search failure is recoverable from the error state', (
      WidgetTester tester,
    ) async {
      int loads = 0;
      await pumpPage(
        tester,
        onLoad: () async {
          loads += 1;
          if (loads == 2) {
            throw const PaymentsBackendException(
              PaymentsBackendErrorCode.unavailable,
            );
          }
          return <Payment>[atlas, marina];
        },
      );

      await tester.enterText(find.byType(TextField), 'atlas');
      await tester.pumpAndSettle();
      expect(find.bySemanticsIdentifier('payments.search.error'), findsOne);
      expect(find.text('Search is unavailable'), findsOneWidget);
      expect(find.text(atlas.counterparty), findsNothing);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsIdentifier('payments.search.error'), findsNothing);
      expect(find.text(atlas.counterparty), findsOneWidget);
      expect(loads, 3);
    });

    testWidgets('typing waits for the debounce window before searching', (
      WidgetTester tester,
    ) async {
      final (_, StubPaymentsBackend backend) = await pumpPage(
        tester,
        onLoad: () async => <Payment>[atlas, marina],
        debounceDuration: const Duration(milliseconds: 300),
      );

      await tester.enterText(find.byType(TextField), 'm');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'mar');
      await tester.pump(const Duration(milliseconds: 299));
      expect(backend.searchCalls, 0);
      expect(find.text(atlas.counterparty), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(backend.searchCalls, 1);
      expect(find.text(atlas.counterparty), findsNothing);
      expect(find.text(marina.counterparty), findsOneWidget);
    });

    testWidgets('a canonical collection change re-runs the active search', (
      WidgetTester tester,
    ) async {
      final List<Payment> stored = <Payment>[atlas];
      final (PaymentsCubit cubit, _) = await pumpPage(
        tester,
        onLoad: () async => List<Payment>.of(stored),
      );

      await tester.enterText(find.byType(TextField), 'marina');
      await tester.pumpAndSettle();
      expect(find.bySemanticsIdentifier('payments.search.empty'), findsOne);

      stored.add(marina);
      await cubit.load();
      await tester.pumpAndSettle();
      expect(find.text(marina.counterparty), findsOneWidget);
      expect(find.text('1 matching payment'), findsOneWidget);
    });
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
    final StubPaymentsBackend backend = StubPaymentsBackend(
      onLoad: () async => <Payment>[approvedPayment()],
    );
    final PaymentsCubit cubit = createPaymentsCubit(backend);
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
  const _PaymentsTestApp({
    required this.cubit,
    required this.child,
    this.createSearchBloc,
  });

  final PaymentsCubit cubit;
  final PaymentsSearchBloc Function()? createSearchBloc;
  final Widget child;

  @override
  Widget build(BuildContext context) => BlocProvider<PaymentsCubit>.value(
    value: cubit,
    child: BlocProvider<PaymentsSearchBloc>(
      create: (BuildContext _) =>
          createSearchBloc?.call() ??
          createPaymentsSearchBloc(
            StubPaymentsBackend(onLoad: () async => const <Payment>[]),
          ),
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}
