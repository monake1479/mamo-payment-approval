import 'dart:async';
import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/app.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/app_router.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/authentication/device_authenticator.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/approval_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/payments_cubit.dart';

import '../support/payments_test_support.dart';

void main() {
  late GoRouter router;
  late PaymentsCubit paymentsCubit;
  late StubPaymentsRepository repository;
  late StubDeviceAuthenticator authenticator;
  late Payment request;
  late List<PaymentDecision> decisions;

  setUp(() {
    request = pendingPayment(counterparty: '👩‍💼 Vendor');
    decisions = <PaymentDecision>[];
    authenticator = StubDeviceAuthenticator(
      result: const DeviceAuthenticationSucceeded(),
    );
    repository = StubPaymentsRepository(
      onLoad: () async =>
          PaymentsSuccess<List<Payment>>(<Payment>[approvedPayment()]),
      onCreateRequest: () async => PaymentsSuccess<Payment>(request),
      onDecide: (String paymentId, PaymentDecision decision) async {
        decisions.add(decision);
        return PaymentsSuccess<Payment>(
          request.copyWith(
            status: decision == PaymentDecision.approve
                ? PaymentStatus.approved
                : PaymentStatus.rejected,
            decidedAt: fixedNow,
          ),
        );
      },
    );
    paymentsCubit = createPaymentsCubit(repository);
    router = createAppRouter();
  });

  tearDown(() async {
    router.dispose();
    await paymentsCubit.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MamoPaymentApprovalApp(
        router: router,
        paymentsCubit: paymentsCubit,
        deviceAuthenticator: authenticator,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openRequest(WidgetTester tester) async {
    await tester.tap(find.bySemanticsIdentifier('debug.incomingRequest'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('approval.overlay'), findsOneWidget);
  }

  testWidgets(
    'masked overlay is non-dismissible and rejection restores exact origin',
    (WidgetTester tester) async {
      await pumpApp(tester);
      await tester.tap(
        find.bySemanticsIdentifier('payment.row.approved-payment'),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsIdentifier('payment.details'), findsOneWidget);

      await openRequest(tester);

      expect(find.text('👩‍💼••••'), findsOneWidget);
      expect(find.text('AED ••••.••'), findsOneWidget);
      expect(find.text('👩‍💼 Vendor'), findsNothing);
      expect(find.text('AED 88.25'), findsNothing);
      expect(find.text('INV-2048'), findsOneWidget);
      expect(find.bySemanticsIdentifier('approval.reveal'), findsOneWidget);
      expect(find.bySemanticsIdentifier('approval.reject'), findsOneWidget);
      expect(find.bySemanticsIdentifier('approval.approve'), findsOneWidget);
      expect(
        tester
            .getSemantics(find.bySemanticsIdentifier('approval.counterparty'))
            .label,
        isNot(contains('Vendor')),
      );
      expect(
        tester
            .getSemantics(find.bySemanticsIdentifier('approval.amount'))
            .label,
        isNot(contains('88.25')),
      );
      expect(
        find.bySemanticsIdentifier('debug.incomingRequest'),
        findsOneWidget,
      );
      expect(
        tester
            .getSemantics(find.bySemanticsIdentifier('debug.incomingRequest'))
            .flagsCollection
            .isEnabled,
        Tristate.isFalse,
      );

      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      await tester.drag(
        find.bySemanticsIdentifier('approval.overlay'),
        const Offset(0, 240),
      );
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.bySemanticsIdentifier('approval.overlay'), findsOneWidget);

      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsIdentifier('approval.overlay'), findsNothing);
      expect(find.bySemanticsIdentifier('payment.details'), findsOneWidget);
      expect(decisions, <PaymentDecision>[PaymentDecision.reject]);
      expect(
        paymentsCubit.state.paymentById(request.id)?.status,
        PaymentStatus.rejected,
      );
    },
  );

  testWidgets('authentication reveals and explicit approval selects Payments', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await openRequest(tester);

    final FilledButton approveBefore = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Approve'),
    );
    expect(approveBefore.onPressed, isNull);
    await tester.tap(find.text('Reveal details'));
    await tester.pumpAndSettle();

    expect(authenticator.authenticateCalls, 1);
    expect(decisions, isEmpty);
    expect(find.text('👩‍💼 Vendor'), findsOneWidget);
    expect(find.text('AED 88.25'), findsOneWidget);
    expect(find.bySemanticsIdentifier('approval.overlay'), findsOneWidget);

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('approval.overlay'), findsNothing);
    expect(find.bySemanticsIdentifier('payments.page'), findsOneWidget);
    expect(decisions, <PaymentDecision>[PaymentDecision.approve]);
    expect(paymentsCubit.state.decidedPayments.first.id, request.id);
  });

  testWidgets(
    'native-prompt inactivity preserves success and actual background remasks',
    (WidgetTester tester) async {
      final _ControlledAuthenticator controlled = _ControlledAuthenticator();
      authenticator = StubDeviceAuthenticator();
      await tester.pumpWidget(
        MamoPaymentApprovalApp(
          router: router,
          paymentsCubit: paymentsCubit,
          deviceAuthenticator: controlled,
        ),
      );
      await tester.pumpAndSettle();
      await openRequest(tester);
      await tester.tap(find.text('Reveal details'));
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      controlled.complete(const DeviceAuthenticationSucceeded());
      await tester.pumpAndSettle();

      expect(controlled.cancelCalls, 0);
      expect(find.text('👩‍💼 Vendor'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      expect(
        tester
            .element(find.bySemanticsIdentifier('approval.overlay'))
            .read<ApprovalCubit>()
            .state
            .isRevealed,
        isFalse,
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('👩‍💼 Vendor'), findsNothing);
      expect(find.text('👩‍💼••••'), findsOneWidget);
    },
  );

  testWidgets('submitted decision finishes once and navigates after resume', (
    WidgetTester tester,
  ) async {
    final Completer<PaymentsResult<Payment>> result =
        Completer<PaymentsResult<Payment>>();
    repository = StubPaymentsRepository(
      onLoad: () async => const PaymentsSuccess<List<Payment>>(<Payment>[]),
      onCreateRequest: () async => PaymentsSuccess<Payment>(request),
      onDecide: (String paymentId, PaymentDecision decision) {
        decisions.add(decision);
        return result.future;
      },
    );
    await paymentsCubit.close();
    paymentsCubit = createPaymentsCubit(repository);
    await pumpApp(tester);
    await openRequest(tester);
    await tester.tap(find.text('Reveal details'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Approve'));
    await tester.pump();
    expect(
      find.bySemanticsLabel('Submitting payment decision'),
      findsOneWidget,
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    result.complete(
      PaymentsSuccess<Payment>(
        request.copyWith(status: PaymentStatus.approved, decidedAt: fixedNow),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.decideCalls, 1);
    expect(find.bySemanticsIdentifier('approval.overlay'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('approval.overlay'), findsNothing);
    expect(find.bySemanticsIdentifier('payments.page'), findsOneWidget);
    expect(repository.decideCalls, 1);
  });

  testWidgets('drag does not activate and position survives navigation', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    final Finder action = find.bySemanticsIdentifier('debug.incomingRequest');
    final Offset before = tester.getTopLeft(action);
    expect(
      tester
          .getSemantics(action)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );

    await tester.drag(action, const Offset(-120, -160));
    await tester.pumpAndSettle();
    final Offset dragged = tester.getTopLeft(action);

    expect(dragged.dx, lessThan(before.dx));
    expect(dragged.dy, lessThan(before.dy));
    expect(repository.createCalls, 0);
    await tester.tap(find.text('Payments'));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(action), dragged);

    tester.view.physicalSize = const Size(640, 320);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(
      left: 24,
      top: 32,
      right: 16,
      bottom: 28,
    );
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    await tester.pumpAndSettle();
    final Rect clamped = tester.getRect(action);
    expect(clamped.left, greaterThanOrEqualTo(32));
    expect(clamped.top, greaterThanOrEqualTo(40));
    expect(clamped.right, lessThanOrEqualTo(616));
    expect(clamped.bottom, lessThanOrEqualTo(284));
  });

  testWidgets(
    'default action clears compact navigation but drag uses safe bounds',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpApp(tester);
      final Finder action = find.bySemanticsIdentifier('debug.incomingRequest');

      final Rect initial = tester.getRect(action);
      expect(initial.bottom, lessThanOrEqualTo(560));

      await tester.drag(action, const Offset(0, 200));
      await tester.pumpAndSettle();
      final Rect dragged = tester.getRect(action);
      expect(dragged.top, greaterThan(initial.top));
      expect(dragged.bottom, lessThanOrEqualTo(640));
      expect(repository.createCalls, 0);
    },
  );

  testWidgets(
    'approval route removes its custom transition for reduced motion',
    (WidgetTester tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpApp(tester);
      await openRequest(tester);

      expect(
        find.ancestor(
          of: find.bySemanticsIdentifier('approval.overlay'),
          matching: find.byType(FadeTransition),
        ),
        findsNothing,
      );
    },
  );

  testWidgets('authentication failure stays masked and recoverable', (
    WidgetTester tester,
  ) async {
    authenticator.result = const DeviceAuthenticationUnavailable();
    await pumpApp(tester);
    await openRequest(tester);
    await tester.tap(find.text('Reveal details'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Device authentication is unavailable'),
      findsOneWidget,
    );
    expect(find.text('👩‍💼 Vendor'), findsNothing);
    expect(find.text('Reveal details'), findsOneWidget);
  });

  testWidgets('decision failure keeps the overlay open for retry', (
    WidgetTester tester,
  ) async {
    await paymentsCubit.close();
    repository = StubPaymentsRepository(
      onLoad: () async => const PaymentsSuccess<List<Payment>>(<Payment>[]),
      onCreateRequest: () async => PaymentsSuccess<Payment>(request),
      onDecide: (String paymentId, PaymentDecision decision) async =>
          const PaymentsError<Payment>(StorageFailure()),
    );
    paymentsCubit = createPaymentsCubit(repository);
    await pumpApp(tester);
    await openRequest(tester);
    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('approval.overlay'), findsOneWidget);
    expect(
      find.text('The payment could not be updated. Try again.'),
      findsOneWidget,
    );
    expect(find.text('Reject'), findsOneWidget);
  });

  testWidgets('request creation failure is visible and retryable', (
    WidgetTester tester,
  ) async {
    repository = StubPaymentsRepository(
      onLoad: () async => const PaymentsSuccess<List<Payment>>(<Payment>[]),
      onCreateRequest: () async =>
          const PaymentsError<Payment>(StorageFailure()),
    );
    await paymentsCubit.close();
    paymentsCubit = createPaymentsCubit(repository);
    await pumpApp(tester);

    await tester.tap(find.bySemanticsIdentifier('debug.incomingRequest'));
    await tester.pumpAndSettle();

    expect(
      find.text('The incoming request could not be created. Try again.'),
      findsOneWidget,
    );
    expect(find.bySemanticsIdentifier('approval.overlay'), findsNothing);
    expect(repository.createCalls, 1);
  });

  for (final Brightness brightness in Brightness.values) {
    for (final Size size in <Size>[
      const Size(320, 640),
      const Size(1024, 768),
    ]) {
      testWidgets('overlay fits $brightness at $size with 200% text', (
        WidgetTester tester,
      ) async {
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpApp(tester);
        await openRequest(tester);

        expect(find.text('Incoming payment'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

final class _ControlledAuthenticator implements DeviceAuthenticator {
  final Completer<DeviceAuthenticationResult> _result =
      Completer<DeviceAuthenticationResult>();
  int cancelCalls = 0;

  void complete(DeviceAuthenticationResult result) => _result.complete(result);

  @override
  Future<DeviceAuthenticationResult> authenticate({
    required String localizedReason,
  }) => _result.future;

  @override
  Future<DeviceAuthenticationCancellationResult> cancel() async {
    cancelCalls += 1;
    return DeviceAuthenticationCancellationResult.promptStopped;
  }
}
