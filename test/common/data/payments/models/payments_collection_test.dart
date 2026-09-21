import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/data/payments/models/payment_summary.dart';
import 'package:mamo_approval/common/data/payments/models/payments_collection.dart';

void main() {
  group('PaymentsCollection', () {
    test('orders decisions newest first and breaks ties by ID', () {
      final DateTime decisionTime = DateTime.utc(2026, 9, 17, 8);
      final PaymentsCollection collection = _collection(<Payment>[
        _payment(id: 'b', decidedAt: decisionTime),
        _payment(id: 'a', decidedAt: decisionTime),
        _payment(
          id: 'newest',
          decidedAt: decisionTime.add(const Duration(minutes: 1)),
        ),
        _payment(id: 'pending', status: PaymentStatus.pending),
      ]);

      expect(collection.payments.map((Payment payment) => payment.id), <String>[
        'newest',
        'a',
        'b',
        'pending',
      ]);
    });

    test('uses inclusive Dubai month start and exclusive next month start', () {
      final DateTime septemberStartUtc = DateTime.utc(2026, 8, 31, 20);
      final DateTime octoberStartUtc = DateTime.utc(2026, 9, 30, 20);
      final PaymentsCollection collection = _collection(<Payment>[
        _payment(
          id: 'before',
          decidedAt: septemberStartUtc.subtract(
            const Duration(microseconds: 1),
          ),
        ),
        _payment(id: 'start', amount: 2, decidedAt: septemberStartUtc),
        _payment(
          id: 'end',
          amount: 3,
          decidedAt: octoberStartUtc.subtract(const Duration(microseconds: 1)),
        ),
        _payment(id: 'next', amount: 5, decidedAt: octoberStartUtc),
        _payment(
          id: 'rejected',
          amount: 7,
          status: PaymentStatus.rejected,
          decidedAt: septemberStartUtc,
        ),
        _payment(id: 'pending', amount: 11, status: PaymentStatus.pending),
      ]);

      expect(
        collection.summary,
        const PaymentSummary(approvedAmount: 5, approvedCount: 2),
      );
      expect(collection.reportingPeriodStartUtc, septemberStartUtc);
    });

    test('respects DST offsets for account-time-zone month boundaries', () {
      final DateTime marchStartUtc = DateTime.utc(2026, 3, 1, 5);
      final DateTime aprilStartUtc = DateTime.utc(2026, 4, 1, 4);
      final PaymentsCollection collection = PaymentsCollection.fromPayments(
        payments: <Payment>[
          _payment(
            id: 'before',
            decidedAt: marchStartUtc.subtract(const Duration(microseconds: 1)),
          ),
          _payment(id: 'start', amount: 2, decidedAt: marchStartUtc),
          _payment(
            id: 'end',
            amount: 3,
            decidedAt: aprilStartUtc.subtract(const Duration(microseconds: 1)),
          ),
          _payment(id: 'next', amount: 5, decidedAt: aprilStartUtc),
        ],
        now: DateTime.utc(2026, 3, 15),
        reportingTimeZone: 'America/New_York',
        reportingCurrency: 'AED',
      );

      expect(collection.reportingPeriodStartUtc, marchStartUtc);
      expect(
        collection.summary,
        const PaymentSummary(approvedAmount: 5, approvedCount: 2),
      );
    });

    test('summarizes only the configured currency without an amount cap', () {
      final PaymentsCollection collection = _collection(<Payment>[
        _payment(id: 'aed', amount: 1000000000),
        _payment(id: 'usd', amount: 12, currency: 'USD'),
      ]);

      expect(
        collection.summary,
        const PaymentSummary(approvedAmount: 1000000000, approvedCount: 1),
      );
    });

    test('returns the named empty summary for no matching approvals', () {
      final PaymentsCollection collection = _collection(const <Payment>[]);

      expect(collection.summary, PaymentSummary.empty());
    });
  });
}

PaymentsCollection _collection(List<Payment> payments) {
  return PaymentsCollection.fromPayments(
    payments: payments,
    now: DateTime.utc(2026, 9, 17, 8),
    reportingTimeZone: 'Asia/Dubai',
    reportingCurrency: 'AED',
  );
}

Payment _payment({
  required String id,
  double amount = 1,
  String currency = 'AED',
  PaymentStatus status = PaymentStatus.approved,
  DateTime? decidedAt,
}) {
  final DateTime createdAt = DateTime.utc(2026);
  return Payment(
    id: id,
    counterparty: 'Counterparty',
    amount: amount,
    currency: currency,
    reference: 'Reference',
    createdAt: createdAt,
    status: status,
    decidedAt: status == PaymentStatus.pending
        ? null
        : decidedAt ?? DateTime.utc(2026, 9, 17, 8),
  );
}
