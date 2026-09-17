import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/authentication/device_authenticator.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/approval_cubit.dart';

import '../../../../support/payments_test_support.dart';

void main() {
  late _ControlledAuthenticator authenticator;
  late List<PaymentDecision> decisions;
  late ApprovalCubit cubit;

  setUp(() {
    authenticator = _ControlledAuthenticator();
    decisions = <PaymentDecision>[];
    cubit = ApprovalCubit(
      request: pendingPayment(),
      authenticator: authenticator,
      decide:
          ({
            required String paymentId,
            required PaymentDecision decision,
          }) async {
            decisions.add(decision);
            return PaymentsSuccess<Payment>(
              pendingPayment(id: paymentId).copyWith(
                status: decision == PaymentDecision.approve
                    ? PaymentStatus.approved
                    : PaymentStatus.rejected,
                decidedAt: fixedNow,
              ),
            );
          },
    );
  });

  tearDown(() async {
    if (!cubit.isClosed) {
      await cubit.close();
    }
  });

  test('starts masked and blocks approval before authentication', () async {
    expect(cubit.state.request.id, 'pending-payment');
    expect(cubit.state.isRevealed, isFalse);
    expect(cubit.state.canApprove, isFalse);

    await cubit.approve();

    expect(decisions, isEmpty);
    expect(cubit.state.phase, ApprovalPhase.ready);
  });

  test('successful authentication reveals but never decides', () async {
    authenticator.complete(const DeviceAuthenticationSucceeded());

    await cubit.reveal(localizedReason: 'Authenticate');

    expect(cubit.state.isRevealed, isTrue);
    expect(cubit.state.canApprove, isTrue);
    expect(decisions, isEmpty);
  });

  for (final (DeviceAuthenticationResult, ApprovalAuthenticationFailure)
      scenario
      in <(DeviceAuthenticationResult, ApprovalAuthenticationFailure)>[
        (
          const DeviceAuthenticationCancelled(),
          ApprovalAuthenticationFailure.cancelled,
        ),
        (
          const DeviceAuthenticationUnavailable(),
          ApprovalAuthenticationFailure.unavailable,
        ),
        (
          const DeviceAuthenticationFailed(),
          ApprovalAuthenticationFailure.failed,
        ),
      ]) {
    test('${scenario.$1.runtimeType} keeps details masked', () async {
      authenticator.complete(scenario.$1);

      await cubit.reveal(localizedReason: 'Authenticate');

      expect(cubit.state.isRevealed, isFalse);
      expect(
        cubit.state.failure,
        isA<ApprovalAuthenticationError>().having(
          (ApprovalAuthenticationError failure) => failure.reason,
          'reason',
          scenario.$2,
        ),
      );
    });
  }

  test('reject does not authenticate and completes once', () async {
    await Future.wait(<Future<void>>[cubit.reject(), cubit.reject()]);

    expect(authenticator.authenticateCalls, 0);
    expect(decisions, <PaymentDecision>[PaymentDecision.reject]);
    expect(cubit.state.phase, ApprovalPhase.completed);
    expect(cubit.state.completedDecision, PaymentDecision.reject);
  });

  test('duplicate reveal taps start one authentication attempt', () async {
    final Future<void> first = cubit.reveal(localizedReason: 'Authenticate');
    final Future<void> second = cubit.reveal(localizedReason: 'Authenticate');
    expect(authenticator.authenticateCalls, 1);

    authenticator.complete(const DeviceAuthenticationSucceeded());
    await Future.wait(<Future<void>>[first, second]);

    expect(cubit.state.isRevealed, isTrue);
  });

  test('background remasks and ignores late authentication success', () async {
    final Future<void> reveal = cubit.reveal(localizedReason: 'Authenticate');

    await cubit.backgrounded();
    authenticator.complete(const DeviceAuthenticationSucceeded());
    await reveal;

    expect(authenticator.cancelCalls, 1);
    expect(cubit.state.isRevealed, isFalse);
    expect(cubit.state.phase, ApprovalPhase.ready);
  });

  test('background after reveal revokes approval authorization', () async {
    authenticator.complete(const DeviceAuthenticationSucceeded());
    await cubit.reveal(localizedReason: 'Authenticate');

    await cubit.backgrounded();
    await cubit.approve();

    expect(cubit.state.isRevealed, isFalse);
    expect(decisions, isEmpty);
  });

  test(
    'submitted approval completes after background without replay',
    () async {
      final Completer<PaymentsResult<Payment>> decisionResult =
          Completer<PaymentsResult<Payment>>();
      await cubit.close();
      cubit = ApprovalCubit(
        request: pendingPayment(),
        authenticator: authenticator,
        decide:
            ({required String paymentId, required PaymentDecision decision}) {
              decisions.add(decision);
              return decisionResult.future;
            },
      );
      authenticator.complete(const DeviceAuthenticationSucceeded());
      await cubit.reveal(localizedReason: 'Authenticate');
      final Future<void> approval = cubit.approve();

      await cubit.backgrounded();
      decisionResult.complete(
        PaymentsSuccess<Payment>(
          pendingPayment().copyWith(
            status: PaymentStatus.approved,
            decidedAt: fixedNow,
          ),
        ),
      );
      await approval;

      expect(decisions, <PaymentDecision>[PaymentDecision.approve]);
      expect(cubit.state.isRevealed, isFalse);
      expect(cubit.state.completedDecision, PaymentDecision.approve);
    },
  );

  test('decision failure remains recoverable in the overlay', () async {
    await cubit.close();
    cubit = ApprovalCubit(
      request: pendingPayment(),
      authenticator: authenticator,
      decide: ({
        required String paymentId,
        required PaymentDecision decision,
      }) async => const PaymentsError<Payment>(StorageFailure()),
    );

    await cubit.reject();

    expect(cubit.state.phase, ApprovalPhase.ready);
    expect(cubit.state.canReject, isTrue);
    expect(cubit.state.failure, isA<ApprovalDecisionError>());
  });

  test(
    'late authentication completion after disposal is ineffective',
    () async {
      final List<ApprovalState> emitted = <ApprovalState>[];
      final StreamSubscription<ApprovalState> subscription = cubit.stream
          .listen(emitted.add);
      final Future<void> reveal = cubit.reveal(localizedReason: 'Authenticate');

      await cubit.close();
      final int beforeLateResult = emitted.length;
      authenticator.complete(const DeviceAuthenticationSucceeded());
      await reveal;

      expect(emitted, hasLength(beforeLateResult));
      await subscription.cancel();
    },
  );
}

final class _ControlledAuthenticator implements DeviceAuthenticator {
  Completer<DeviceAuthenticationResult> _result =
      Completer<DeviceAuthenticationResult>();
  int authenticateCalls = 0;
  int cancelCalls = 0;

  void complete(DeviceAuthenticationResult result) {
    if (_result.isCompleted) {
      _result = Completer<DeviceAuthenticationResult>();
    }
    _result.complete(result);
  }

  @override
  Future<DeviceAuthenticationResult> authenticate({
    required String localizedReason,
  }) {
    authenticateCalls += 1;
    return _result.future;
  }

  @override
  Future<DeviceAuthenticationCancellationResult> cancel() async {
    cancelCalls += 1;
    return DeviceAuthenticationCancellationResult.promptStopped;
  }
}
