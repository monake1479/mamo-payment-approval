import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/features/payments/data/in_memory_payments_repository.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';

void main() {
  final DateTime fixedNow = DateTime.utc(2026, 9, 17, 8);

  group('InMemoryPaymentsRepository', () {
    test('seed is deterministic, valid, and relative to the clock', () async {
      final InMemoryPaymentsRepository first =
          InMemoryPaymentsRepository.seeded(clock: () => fixedNow);
      final InMemoryPaymentsRepository second =
          InMemoryPaymentsRepository.seeded(clock: () => fixedNow);

      final List<Payment> firstPayments =
          ((await first.load()) as PaymentsSuccess<List<Payment>>).value;
      final List<Payment> secondPayments =
          ((await second.load()) as PaymentsSuccess<List<Payment>>).value;

      expect(firstPayments, secondPayments);
      expect(firstPayments, hasLength(3));
      expect(
        firstPayments.every((Payment payment) => payment.validate() == null),
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
      final InMemoryPaymentsRepository repository =
          InMemoryPaymentsRepository.seeded(clock: () => fixedNow);
      bool completed = false;

      repository.load().then((PaymentsResult<List<Payment>> _) {
        completed = true;
      });

      expect(completed, isFalse);
    });

    test(
      'creates deterministic requests and rejects concurrent duplicates',
      () async {
        final InMemoryPaymentsRepository repository =
            InMemoryPaymentsRepository(
              initialPayments: const <Payment>[],
              clock: () => fixedNow,
              operationDelay: const Duration(milliseconds: 1),
            );

        final Future<PaymentsResult<Payment>> first = repository
            .createRequest();
        final Future<PaymentsResult<Payment>> second = repository
            .createRequest();
        final List<PaymentsResult<Payment>> results = await Future.wait(
          <Future<PaymentsResult<Payment>>>[first, second],
        );

        final List<PaymentsSuccess<Payment>> successes = results
            .whereType<PaymentsSuccess<Payment>>()
            .toList();
        final List<PaymentsError<Payment>> errors = results
            .whereType<PaymentsError<Payment>>()
            .toList();
        expect(successes, hasLength(1));
        expect(successes.single.value.id, 'request-0001');
        expect(successes.single.value.createdAt, fixedNow);
        expect(errors.single.failure, const DuplicateRequestFailure());
        expect(
          ((await repository.load()) as PaymentsSuccess<List<Payment>>).value,
          hasLength(1),
        );
      },
    );

    test(
      'allows one final decision and records the injected UTC time',
      () async {
        DateTime now = fixedNow;
        final InMemoryPaymentsRepository repository =
            InMemoryPaymentsRepository(
              initialPayments: const <Payment>[],
              clock: () => now,
            );
        final Payment request =
            ((await repository.createRequest()) as PaymentsSuccess<Payment>)
                .value;
        now = fixedNow.add(const Duration(minutes: 3));

        final PaymentsResult<Payment> approved = await repository.decide(
          paymentId: request.id,
          decision: PaymentDecision.approve,
        );
        final PaymentsResult<Payment> repeated = await repository.decide(
          paymentId: request.id,
          decision: PaymentDecision.reject,
        );

        expect(
          (approved as PaymentsSuccess<Payment>).value.status,
          PaymentStatus.approved,
        );
        expect(approved.value.decidedAt, now);
        expect(
          (repeated as PaymentsError<Payment>).failure,
          const PaymentAlreadyDecidedFailure(),
        );
      },
    );

    test('does not persist a decision that exceeds the summary cap', () async {
      final Payment approved = Payment(
        id: 'approved',
        counterparty: 'Counterparty',
        amount: 999999999.99,
        reference: 'Approved',
        createdAt: DateTime.utc(2026, 9, 15),
        status: PaymentStatus.approved,
        decidedAt: DateTime.utc(2026, 9, 16),
      );
      final Payment pending = Payment(
        id: 'pending',
        counterparty: 'Counterparty',
        amount: 0.01,
        reference: 'Pending',
        createdAt: DateTime.utc(2026, 9, 16),
        status: PaymentStatus.pending,
      );
      final InMemoryPaymentsRepository repository = InMemoryPaymentsRepository(
        initialPayments: <Payment>[approved, pending],
        clock: () => fixedNow,
      );

      final PaymentsResult<Payment> result = await repository.decide(
        paymentId: pending.id,
        decision: PaymentDecision.approve,
      );
      final List<Payment> stored =
          ((await repository.load()) as PaymentsSuccess<List<Payment>>).value;

      expect(result, isA<PaymentsError<Payment>>());
      expect(
        stored
            .singleWhere((Payment payment) => payment.id == pending.id)
            .status,
        PaymentStatus.pending,
      );
    });

    test(
      'returns not found and malformed storage as explicit failures',
      () async {
        final InMemoryPaymentsRepository repository =
            InMemoryPaymentsRepository(
              initialPayments: const <Payment>[],
              clock: () => fixedNow,
            );
        final PaymentsResult<Payment> missing = await repository.decide(
          paymentId: 'missing',
          decision: PaymentDecision.approve,
        );
        final InMemoryPaymentsRepository malformed =
            InMemoryPaymentsRepository.fromRecords(
              records: <Map<String, Object?>>[
                <String, Object?>{'id': 'incomplete'},
              ],
              clock: () => fixedNow,
            );

        expect(
          (missing as PaymentsError<Payment>).failure,
          const PaymentNotFoundFailure(),
        );
        expect(await malformed.load(), isA<PaymentsError<List<Payment>>>());
      },
    );
  });
}
