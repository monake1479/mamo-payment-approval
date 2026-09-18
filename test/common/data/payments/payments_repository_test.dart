import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/data_sources/payments_remote_data_source.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/dtos/payment_dto.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/mock_backend/payments/mock_payments_backend.dart';

void main() {
  final DateTime fixedNow = DateTime.utc(2026, 9, 17, 8);

  group('PaymentsRepository', () {
    test('seed is deterministic, valid, and relative to the clock', () async {
      final PaymentsRepository first = _repository(clock: () => fixedNow);
      final PaymentsRepository second = _repository(clock: () => fixedNow);

      final List<Payment> firstPayments =
          ((await first.load()) as Success<PaymentsFailure, List<Payment>>)
              .value;
      final List<Payment> secondPayments =
          ((await second.load()) as Success<PaymentsFailure, List<Payment>>)
              .value;

      expect(firstPayments, secondPayments);
      expect(firstPayments, hasLength(3));
      expect(
        firstPayments.every((Payment payment) => payment.currency == 'AED'),
        isTrue,
      );
      expect(
        firstPayments.where(
          (Payment payment) => payment.status == PaymentStatus.pending,
        ),
        isEmpty,
      );
    });

    test('operations are asynchronous even without a configured delay', () {
      final PaymentsRepository repository = _repository(clock: () => fixedNow);
      bool completed = false;

      repository.load().then((Result<PaymentsFailure, List<Payment>> _) {
        completed = true;
      });

      expect(completed, isFalse);
    });

    test('maps deterministic backend failures when configured', () async {
      final PaymentsRepository repository = _repository(
        clock: () => fixedNow,
        simulatedFailureInterval: 2,
      );

      expect(
        await repository.load(),
        isA<Success<PaymentsFailure, List<Payment>>>(),
      );
      final Result<PaymentsFailure, List<Payment>> failure = await repository
          .load();
      expect(
        (failure as Failure<PaymentsFailure, List<Payment>>).failure,
        const PaymentsUnavailableFailure(),
      );
      expect(
        await repository.load(),
        isA<Success<PaymentsFailure, List<Payment>>>(),
      );
    });

    test(
      'creates deterministic requests and rejects concurrent duplicates',
      () async {
        final PaymentsRepository repository = _repository(
          initialPayments: const <Payment>[],
          clock: () => fixedNow,
          operationDelay: const Duration(milliseconds: 1),
        );

        final Future<Result<PaymentsFailure, Payment>> first = repository
            .createRequest();
        final Future<Result<PaymentsFailure, Payment>> second = repository
            .createRequest();
        final List<Result<PaymentsFailure, Payment>> results =
            await Future.wait(<Future<Result<PaymentsFailure, Payment>>>[
              first,
              second,
            ]);

        final List<Success<PaymentsFailure, Payment>> successes = results
            .whereType<Success<PaymentsFailure, Payment>>()
            .toList();
        final List<Failure<PaymentsFailure, Payment>> errors = results
            .whereType<Failure<PaymentsFailure, Payment>>()
            .toList();
        expect(successes, hasLength(1));
        expect(successes.single.value.id, 'request-0001');
        expect(successes.single.value.createdAt, fixedNow);
        expect(successes.single.value.currency, 'AED');
        expect(errors.single.failure, const DuplicateRequestFailure());
        expect(
          ((await repository.load()) as Success<PaymentsFailure, List<Payment>>)
              .value,
          hasLength(1),
        );
      },
    );

    test(
      'allows one final decision and records the injected UTC time',
      () async {
        DateTime now = fixedNow;
        final PaymentsRepository repository = _repository(
          initialPayments: const <Payment>[],
          clock: () => now,
        );
        final Payment request =
            ((await repository.createRequest())
                    as Success<PaymentsFailure, Payment>)
                .value;
        now = fixedNow.add(const Duration(minutes: 3));

        final Result<PaymentsFailure, Payment> approved = await repository
            .decide(paymentId: request.id, decision: PaymentDecision.approve);
        final Result<PaymentsFailure, Payment> repeated = await repository
            .decide(paymentId: request.id, decision: PaymentDecision.reject);

        expect(
          (approved as Success<PaymentsFailure, Payment>).value.status,
          PaymentStatus.approved,
        );
        expect(approved.value.decidedAt, now);
        expect(
          (repeated as Failure<PaymentsFailure, Payment>).failure,
          const PaymentAlreadyDecidedFailure(),
        );
      },
    );

    test('does not impose an application-side transaction maximum', () async {
      final Payment approved = Payment(
        id: 'approved',
        counterparty: 'Counterparty',
        amount: 1000000000,
        currency: 'AED',
        reference: 'Approved',
        createdAt: DateTime.utc(2026, 9, 15),
        status: PaymentStatus.approved,
        decidedAt: DateTime.utc(2026, 9, 16),
      );
      final Payment pending = Payment(
        id: 'pending',
        counterparty: 'Counterparty',
        amount: 0.01,
        currency: 'AED',
        reference: 'Pending',
        createdAt: DateTime.utc(2026, 9, 16),
        status: PaymentStatus.pending,
      );
      final PaymentsRepository repository = _repository(
        initialPayments: <Payment>[approved, pending],
        clock: () => fixedNow,
      );

      final Result<PaymentsFailure, Payment> result = await repository.decide(
        paymentId: pending.id,
        decision: PaymentDecision.approve,
      );
      final List<Payment> stored =
          ((await repository.load()) as Success<PaymentsFailure, List<Payment>>)
              .value;

      expect(result, isA<Success<PaymentsFailure, Payment>>());
      expect(
        stored
            .singleWhere((Payment payment) => payment.id == pending.id)
            .status,
        PaymentStatus.approved,
      );
    });

    test('uses the currency configured by the mock backend', () async {
      final PaymentsRepository repository = _repository(
        initialPayments: const <Payment>[],
        currency: 'USD',
        clock: () => fixedNow,
      );

      final Payment created =
          ((await repository.createRequest())
                  as Success<PaymentsFailure, Payment>)
              .value;

      expect(repository.reportingCurrency, 'USD');
      expect(created.currency, 'USD');
    });

    test(
      'returns not found and malformed backend responses as explicit failures',
      () async {
        final PaymentsRepository repository = _repository(
          initialPayments: const <Payment>[],
          clock: () => fixedNow,
        );
        final Result<PaymentsFailure, Payment> missing = await repository
            .decide(paymentId: 'missing', decision: PaymentDecision.approve);
        final PaymentsRepository malformed = _repository(
          initialRecords: <Map<String, Object?>>[
            <String, Object?>{'id': 'incomplete'},
          ],
          clock: () => fixedNow,
        );

        expect(
          (missing as Failure<PaymentsFailure, Payment>).failure,
          const PaymentNotFoundFailure(),
        );
        expect(
          await malformed.load(),
          isA<Failure<PaymentsFailure, List<Payment>>>(),
        );
      },
    );
  });
}

PaymentsRepository _repository({
  List<Payment>? initialPayments,
  List<Map<String, Object?>>? initialRecords,
  DateTime Function()? clock,
  Duration operationDelay = Duration.zero,
  String reportingTimeZone = 'Asia/Dubai',
  String currency = 'AED',
  int simulatedFailureInterval = 0,
}) {
  final List<Map<String, Object?>>? records =
      initialRecords ??
      initialPayments
          ?.map((payment) => PaymentDto.fromModel(payment).toJson())
          .toList();
  return PaymentsRepository(
    PaymentsRemoteDataSource(
      MockPaymentsBackend(
        initialRecords: records,
        clock: clock,
        operationDelay: operationDelay,
        reportingTimeZone: reportingTimeZone,
        currency: currency,
        simulatedFailureInterval: simulatedFailureInterval,
      ),
    ),
  );
}
