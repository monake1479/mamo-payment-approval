import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/data_sources/payments_remote_data_source.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment_mutation.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payments_collection.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/create_payment_request_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/decide_payment_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/load_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/mock_backend/payments/mock_payments_backend.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 9, 17, 8);
  final Payment pending = Payment(
    id: 'request',
    counterparty: 'Counterparty',
    amount: 12.34,
    currency: 'AED',
    reference: 'Reference',
    createdAt: DateTime.utc(2026, 9, 17),
    status: PaymentStatus.pending,
  );

  test('load projects repository data with reporting configuration', () async {
    final _FakePaymentsRepository repository = _FakePaymentsRepository(pending);
    final Result<PaymentsFailure, PaymentsCollection> result =
        await LoadPaymentsUseCase(repository, clock: () => now)();

    final PaymentsCollection collection =
        (result as Success<PaymentsFailure, PaymentsCollection>).value;
    expect(collection.activeRequest, pending);
    expect(collection.reportingTimeZone, 'Asia/Dubai');
    expect(collection.reportingCurrency, 'AED');
  });

  test(
    'create rejects an existing pending request before repository I/O',
    () async {
      final _FakePaymentsRepository repository = _FakePaymentsRepository(
        pending,
      );
      final Result<PaymentsFailure, PaymentMutation> result =
          await CreatePaymentRequestUseCase(repository, clock: () => now)(
            currentPayments: <Payment>[pending],
          );

      expect(
        (result as Failure<PaymentsFailure, PaymentMutation>).failure,
        const DuplicateRequestFailure(),
      );
      expect(repository.createCalls, 0);
    },
  );

  test(
    'decision validates the transition and returns a projected mutation',
    () async {
      final _FakePaymentsRepository repository = _FakePaymentsRepository(
        pending,
      );
      final Result<PaymentsFailure, PaymentMutation> result =
          await DecidePaymentUseCase(repository, clock: () => now)(
            currentPayments: <Payment>[pending],
            paymentId: pending.id,
            decision: PaymentDecision.approve,
          );

      final PaymentMutation mutation =
          (result as Success<PaymentsFailure, PaymentMutation>).value;
      expect(mutation.payment.status, PaymentStatus.approved);
      expect(mutation.collection.activeRequest, isNull);
      expect(mutation.collection.summary.approvedAmount, 12.34);
      expect(repository.decision, PaymentDecision.approve);
    },
  );

  test('use cases preserve typed repository failures', () async {
    final _FakePaymentsRepository repository = _FakePaymentsRepository(pending)
      ..loadFailure = const PaymentsUnavailableFailure();

    final Result<PaymentsFailure, PaymentsCollection> result =
        await LoadPaymentsUseCase(repository, clock: () => now)();

    expect(
      (result as Failure<PaymentsFailure, PaymentsCollection>).failure,
      const PaymentsUnavailableFailure(),
    );
  });

  test('decision does not impose an aggregate amount cap', () async {
    final Payment large = Payment(
      id: 'large',
      counterparty: 'Counterparty',
      amount: 1000000000,
      currency: 'AED',
      reference: 'Large',
      createdAt: DateTime.utc(2026, 9, 15),
      status: PaymentStatus.approved,
      decidedAt: DateTime.utc(2026, 9, 16),
    );
    final _FakePaymentsRepository repository = _FakePaymentsRepository(pending);

    final Result<PaymentsFailure, PaymentMutation> result =
        await DecidePaymentUseCase(repository, clock: () => now)(
          currentPayments: <Payment>[large, pending],
          paymentId: pending.id,
          decision: PaymentDecision.approve,
        );

    expect(result, isA<Success<PaymentsFailure, PaymentMutation>>());
    expect(repository.decideCalls, 1);
  });

  test(
    'decision rejects a repository response with a different transition',
    () async {
      final _FakePaymentsRepository repository =
          _FakePaymentsRepository(pending)
            ..decisionResult = Success<PaymentsFailure, Payment>(
              pending.copyWith(status: PaymentStatus.rejected, decidedAt: now),
            );

      final Result<PaymentsFailure, PaymentMutation> result =
          await DecidePaymentUseCase(repository, clock: () => now)(
            currentPayments: <Payment>[pending],
            paymentId: pending.id,
            decision: PaymentDecision.approve,
          );

      expect(
        (result as Failure<PaymentsFailure, PaymentMutation>).failure,
        const InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
      );
    },
  );
}

final class _FakePaymentsRepository extends PaymentsRepository {
  _FakePaymentsRepository(this.pending)
    : super(
        PaymentsRemoteDataSource(
          MockPaymentsBackend(
            initialRecords: const <Map<String, Object?>>[],
            clock: () => DateTime.utc(2026, 9, 17, 8),
          ),
        ),
      );

  final Payment pending;
  PaymentDecision? decision;
  PaymentsFailure? loadFailure;
  Result<PaymentsFailure, Payment>? decisionResult;
  int createCalls = 0;
  int decideCalls = 0;

  @override
  Future<Result<PaymentsFailure, Payment>> createRequest() async {
    createCalls += 1;
    return Success<PaymentsFailure, Payment>(pending);
  }

  @override
  Future<Result<PaymentsFailure, Payment>> decide({
    required String paymentId,
    required PaymentDecision decision,
  }) async {
    decideCalls += 1;
    this.decision = decision;
    final Result<PaymentsFailure, Payment>? configured = decisionResult;
    if (configured != null) {
      return configured;
    }
    return Success<PaymentsFailure, Payment>(
      pending.copyWith(
        status: switch (decision) {
          PaymentDecision.approve => PaymentStatus.approved,
          PaymentDecision.reject => PaymentStatus.rejected,
        },
        decidedAt: DateTime.utc(2026, 9, 17, 8),
      ),
    );
  }

  @override
  Future<Result<PaymentsFailure, List<Payment>>> load() async {
    final PaymentsFailure? failure = loadFailure;
    if (failure != null) {
      return Failure<PaymentsFailure, List<Payment>>(failure);
    }
    return Success<PaymentsFailure, List<Payment>>(<Payment>[pending]);
  }
}
