import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_operations.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';

void main() {
  group('PaymentOperations', () {
    test('orders decided payments by decision time then stable ID', () {
      final PaymentOperations operations = PaymentOperations(
        reportingTimeZone: 'Asia/Dubai',
      );
      final DateTime created = DateTime.utc(2026, 8);
      final DateTime latestDecision = DateTime.utc(2026, 9, 10);
      final List<Payment> history = operations.decidedHistory(<Payment>[
        _payment(
          id: 'z',
          createdAt: created,
          status: PaymentStatus.approved,
          decidedAt: latestDecision,
        ),
        _payment(
          id: 'pending',
          createdAt: created,
          status: PaymentStatus.pending,
        ),
        _payment(
          id: 'older-request-decided-now',
          createdAt: DateTime.utc(2025),
          status: PaymentStatus.rejected,
          decidedAt: latestDecision.add(const Duration(minutes: 1)),
        ),
        _payment(
          id: 'a',
          createdAt: created,
          status: PaymentStatus.rejected,
          decidedAt: latestDecision,
        ),
      ]);

      expect(history.map((Payment payment) => payment.id), <String>[
        'older-request-decided-now',
        'a',
        'z',
      ]);
    });

    test('uses Dubai UTC month edges and approved decision time only', () {
      final PaymentOperations operations = PaymentOperations(
        reportingTimeZone: 'Asia/Dubai',
      );
      final DateTime created = DateTime.utc(2026);
      final List<Payment> payments = <Payment>[
        _payment(
          id: 'before',
          createdAt: created,
          status: PaymentStatus.approved,
          decidedAt: DateTime.utc(2026, 8, 31, 19, 59, 59, 999),
        ),
        _payment(
          id: 'start',
          createdAt: created,
          amount: 0.10,
          status: PaymentStatus.approved,
          decidedAt: DateTime.utc(2026, 8, 31, 20),
        ),
        _payment(
          id: 'end-minus',
          createdAt: created,
          amount: 0.20,
          status: PaymentStatus.approved,
          decidedAt: DateTime.utc(2026, 9, 30, 19, 59, 59, 999),
        ),
        _payment(
          id: 'end',
          createdAt: created,
          status: PaymentStatus.approved,
          decidedAt: DateTime.utc(2026, 9, 30, 20),
        ),
        _payment(
          id: 'rejected',
          createdAt: created,
          status: PaymentStatus.rejected,
          decidedAt: DateTime.utc(2026, 9, 10),
        ),
        _payment(
          id: 'pending',
          createdAt: DateTime.utc(2026, 9, 10),
          status: PaymentStatus.pending,
        ),
      ];

      final PaymentSummary summary = operations.currentMonthSummary(
        payments: payments,
        now: DateTime.utc(2026, 9, 15),
      );

      expect(
        summary,
        const PaymentSummary(approvedAmount: 0.30, approvedCount: 2),
      );
    });

    test('handles a DST reporting-zone month without a fixed offset', () {
      final PaymentOperations operations = PaymentOperations(
        reportingTimeZone: 'America/New_York',
      );
      final DateTime created = DateTime.utc(2026);
      final PaymentSummary summary = operations.currentMonthSummary(
        now: DateTime.utc(2026, 3, 15),
        payments: <Payment>[
          _payment(
            id: 'start',
            createdAt: created,
            status: PaymentStatus.approved,
            decidedAt: DateTime.utc(2026, 3, 1, 5),
          ),
          _payment(
            id: 'last',
            createdAt: created,
            status: PaymentStatus.approved,
            decidedAt: DateTime.utc(2026, 4, 1, 3, 59, 59),
          ),
          _payment(
            id: 'exclusive-end',
            createdAt: created,
            status: PaymentStatus.approved,
            decidedAt: DateTime.utc(2026, 4, 1, 4),
          ),
        ],
      );

      expect(summary.approvedCount, 2);
      expect(summary.approvedAmount, 2);
    });

    test('handles account-zone month and year rollover', () {
      final PaymentOperations operations = PaymentOperations(
        reportingTimeZone: 'Asia/Dubai',
      );
      final DateTime created = DateTime.utc(2025);
      final PaymentSummary summary = operations.currentMonthSummary(
        now: DateTime.utc(2026, 1, 15),
        payments: <Payment>[
          _payment(
            id: 'previous-year',
            createdAt: created,
            status: PaymentStatus.approved,
            decidedAt: DateTime.utc(2025, 12, 31, 19, 59, 59),
          ),
          _payment(
            id: 'new-year',
            createdAt: created,
            status: PaymentStatus.approved,
            decidedAt: DateTime.utc(2025, 12, 31, 20),
          ),
        ],
      );

      expect(summary.approvedCount, 1);
      expect(summary.approvedAmount, 1);
    });

    test('reports aggregate overflow as an explicit failure', () {
      final PaymentOperations operations = PaymentOperations(
        reportingTimeZone: 'Asia/Dubai',
      );
      final DateTime decision = DateTime.utc(2026, 9);
      final PaymentsResult<PaymentSummary> result = operations
          .tryCurrentMonthSummary(
            now: DateTime.utc(2026, 9, 15),
            payments: <Payment>[
              _payment(
                id: 'one',
                createdAt: decision,
                amount: 600000000,
                status: PaymentStatus.approved,
                decidedAt: decision,
              ),
              _payment(
                id: 'two',
                createdAt: decision,
                amount: 400000000,
                status: PaymentStatus.approved,
                decidedAt: decision,
              ),
            ],
          );

      expect(result, isA<PaymentsError<PaymentSummary>>());
    });

    test('uses the instant rather than the DateTime zone representation', () {
      final PaymentOperations operations = PaymentOperations(
        reportingTimeZone: 'Asia/Dubai',
      );
      final DateTime instant = DateTime.utc(2026, 8, 31, 21);
      final Payment payment = _payment(
        id: 'payment',
        createdAt: DateTime.utc(2026, 8),
        status: PaymentStatus.approved,
        decidedAt: instant,
      );

      expect(
        operations.currentMonthSummary(
          payments: <Payment>[payment],
          now: instant,
        ),
        operations.currentMonthSummary(
          payments: <Payment>[payment],
          now: instant.toLocal(),
        ),
      );
    });
  });

  group('PaymentSummary equality', () {
    test('invalid summary equality remains reflexive by identity', () {
      final PaymentSummary invalid = PaymentSummary(
        approvedAmount: 1.001,
        approvedCount: 1,
      );
      final PaymentSummary distinctInvalid = PaymentSummary(
        approvedAmount: 1.001,
        approvedCount: 1,
      );

      expect(invalid == invalid, isTrue);
      expect(<PaymentSummary>{invalid}.contains(invalid), isTrue);
      expect(invalid == distinctInvalid, isFalse);
    });
  });
}

Payment _payment({
  required String id,
  required DateTime createdAt,
  required PaymentStatus status,
  double amount = 1,
  DateTime? decidedAt,
}) {
  return Payment(
    id: id,
    counterparty: 'Counterparty',
    amount: amount,
    reference: 'Reference',
    createdAt: createdAt,
    status: status,
    decidedAt: decidedAt,
  );
}
