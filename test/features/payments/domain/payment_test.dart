import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';

void main() {
  group('Payment validation', () {
    test('accepts pending and decided UTC timelines', () {
      final Payment pending = _payment(status: PaymentStatus.pending);
      final Payment decided = _payment(
        status: PaymentStatus.approved,
        decidedAt: DateTime.utc(2026, 9, 2),
      );

      expect(pending.validate(), isNull);
      expect(decided.validate(), isNull);
      expect(pending.currency, 'AED');
    });

    test('rejects local timestamps and inconsistent status timelines', () {
      expect(
        _payment(
          status: PaymentStatus.pending,
          decidedAt: DateTime.utc(2026, 9, 2),
        ).validate(),
        const InvalidPaymentFailure(InvalidPaymentReason.invalidStatusTimeline),
      );
      expect(
        _payment(status: PaymentStatus.rejected).validate(),
        const InvalidPaymentFailure(InvalidPaymentReason.invalidStatusTimeline),
      );
      expect(
        _payment(
          status: PaymentStatus.approved,
          decidedAt: DateTime.utc(2026, 8, 31),
        ).validate(),
        const InvalidPaymentFailure(InvalidPaymentReason.invalidStatusTimeline),
      );
      expect(
        Payment(
          id: 'payment',
          counterparty: 'Counterparty',
          amount: 1,
          reference: 'Reference',
          createdAt: DateTime(2026, 9),
          status: PaymentStatus.pending,
        ).validate(),
        const InvalidPaymentFailure(InvalidPaymentReason.invalidTimestamp),
      );
    });

    test('compares canonical whole-fils amounts', () {
      final Payment first = _payment(
        status: PaymentStatus.approved,
        amount: 0.1 + 0.2,
        decidedAt: DateTime.utc(2026, 9, 2),
      );
      final Payment second = _payment(
        status: PaymentStatus.approved,
        amount: 0.30,
        decidedAt: DateTime.utc(2026, 9, 2),
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}

Payment _payment({
  required PaymentStatus status,
  double amount = 1,
  DateTime? decidedAt,
}) {
  return Payment(
    id: 'payment',
    counterparty: 'Counterparty',
    amount: amount,
    reference: 'Reference',
    createdAt: DateTime.utc(2026, 9),
    status: status,
    decidedAt: decidedAt,
  );
}
