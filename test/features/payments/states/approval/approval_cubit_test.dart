import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/error_handling/device_authentication_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/local_auth_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/models/device_authentication_cancellation_result.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/local_authentication_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/stop_local_authentication_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/unit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/approval/approval_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/approval/approval_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/approval/approval_state.dart';

import '../../../../support/device_authentication_test_support.dart';
import '../../../../support/payments_test_support.dart';

void main() {
  late _ControlledAuthenticate authenticate;
  late _ControlledStop stop;
  late List<PaymentDecision> decisions;
  late ApprovalCubit cubit;

  setUp(() {
    authenticate = _ControlledAuthenticate();
    stop = _ControlledStop();
    decisions = <PaymentDecision>[];
    cubit = ApprovalCubit(
      request: pendingPayment(),
      authenticate: authenticate,
      stopAuthentication: stop,
      decide:
          ({
            required String paymentId,
            required PaymentDecision decision,
          }) async {
            decisions.add(decision);
            return Success<PaymentsFailure, Payment>(
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
    authenticate.complete(
      const Result<DeviceAuthenticationFailure, Unit>.success(unit),
    );

    await cubit.reveal(localizedReason: 'Authenticate');

    expect(cubit.state.isRevealed, isTrue);
    expect(cubit.state.canApprove, isTrue);
    expect(decisions, isEmpty);
  });

  for (final (DeviceAuthenticationFailure, ApprovalAuthenticationFailure)
      scenario
      in <(DeviceAuthenticationFailure, ApprovalAuthenticationFailure)>[
        (
          const DeviceAuthenticationFailure.cancelled(),
          ApprovalAuthenticationFailure.cancelled,
        ),
        (
          const DeviceAuthenticationFailure.unavailable(),
          ApprovalAuthenticationFailure.unavailable,
        ),
        (
          const DeviceAuthenticationFailure.failed(),
          ApprovalAuthenticationFailure.failed,
        ),
      ]) {
    test('${scenario.$1.runtimeType} keeps details masked', () async {
      authenticate.complete(
        Result<DeviceAuthenticationFailure, Unit>.failure(scenario.$1),
      );

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

    expect(authenticate.calls, 0);
    expect(decisions, <PaymentDecision>[PaymentDecision.reject]);
    expect(cubit.state.phase, ApprovalPhase.completed);
    expect(cubit.state.completedDecision, PaymentDecision.reject);
  });

  test('duplicate reveal taps start one authentication attempt', () async {
    final Future<void> first = cubit.reveal(localizedReason: 'Authenticate');
    final Future<void> second = cubit.reveal(localizedReason: 'Authenticate');
    expect(authenticate.calls, 1);

    authenticate.complete(
      const Result<DeviceAuthenticationFailure, Unit>.success(unit),
    );
    await Future.wait(<Future<void>>[first, second]);

    expect(cubit.state.isRevealed, isTrue);
  });

  test('background remasks and ignores late authentication success', () async {
    final Future<void> reveal = cubit.reveal(localizedReason: 'Authenticate');

    await cubit.backgrounded();
    authenticate.complete(
      const Result<DeviceAuthenticationFailure, Unit>.success(unit),
    );
    await reveal;

    expect(stop.calls, 1);
    expect(cubit.state.isRevealed, isFalse);
    expect(cubit.state.phase, ApprovalPhase.ready);
  });

  test('background after reveal revokes approval authorization', () async {
    authenticate.complete(
      const Result<DeviceAuthenticationFailure, Unit>.success(unit),
    );
    await cubit.reveal(localizedReason: 'Authenticate');

    await cubit.backgrounded();
    await cubit.approve();

    expect(cubit.state.isRevealed, isFalse);
    expect(decisions, isEmpty);
  });

  test(
    'submitted approval completes after background without replay',
    () async {
      final Completer<Result<PaymentsFailure, Payment>> decisionResult =
          Completer<Result<PaymentsFailure, Payment>>();
      await cubit.close();
      cubit = ApprovalCubit(
        request: pendingPayment(),
        authenticate: authenticate,
        stopAuthentication: stop,
        decide:
            ({required String paymentId, required PaymentDecision decision}) {
              decisions.add(decision);
              return decisionResult.future;
            },
      );
      authenticate.complete(
        const Result<DeviceAuthenticationFailure, Unit>.success(unit),
      );
      await cubit.reveal(localizedReason: 'Authenticate');
      final Future<void> approval = cubit.approve();

      await cubit.backgrounded();
      decisionResult.complete(
        Success<PaymentsFailure, Payment>(
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
      authenticate: authenticate,
      stopAuthentication: stop,
      decide:
          ({
            required String paymentId,
            required PaymentDecision decision,
          }) async => const Failure<PaymentsFailure, Payment>(
            PaymentsUnavailableFailure(),
          ),
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
      authenticate.complete(
        const Result<DeviceAuthenticationFailure, Unit>.success(unit),
      );
      await reveal;

      expect(emitted, hasLength(beforeLateResult));
      await subscription.cancel();
    },
  );
}

/// Completer-driven fake of the authentication use case so the cubit's
/// generation and lifecycle handling can be exercised in isolation. The
/// injected repository is unused because [call] is overridden.
final class _ControlledAuthenticate extends LocalAuthenticationUseCase {
  _ControlledAuthenticate() : super(LocalAuthRepository(FakeLocalAuthClient()));

  Completer<Result<DeviceAuthenticationFailure, Unit>> _result =
      Completer<Result<DeviceAuthenticationFailure, Unit>>();
  int calls = 0;

  void complete(Result<DeviceAuthenticationFailure, Unit> result) {
    if (_result.isCompleted) {
      _result = Completer<Result<DeviceAuthenticationFailure, Unit>>();
    }
    _result.complete(result);
  }

  @override
  Future<Result<DeviceAuthenticationFailure, Unit>> call({
    required String localizedReason,
  }) {
    calls += 1;
    return _result.future;
  }
}

final class _ControlledStop extends StopLocalAuthenticationUseCase {
  _ControlledStop() : super(LocalAuthRepository(FakeLocalAuthClient()));

  int calls = 0;
  DeviceAuthenticationCancellationResult result =
      DeviceAuthenticationCancellationResult.promptStopped;

  @override
  Future<DeviceAuthenticationCancellationResult> call() async {
    calls += 1;
    return result;
  }
}
