import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';

void main() {
  group('Payment', () {
    test('is an immutable Freezed value carrying source currency', () {
      final Payment payment = _payment();
      final Payment same = _payment();

      expect(payment, same);
      expect(payment.hashCode, same.hashCode);
      expect(payment.currency, 'AED');
      expect(payment.copyWith(currency: 'USD'), isNot(payment));
    });

    test('copyWith creates the requested decision without mutating source', () {
      final Payment pending = _payment();
      final DateTime decidedAt = DateTime.utc(2026, 9, 2);
      final Payment approved = pending.copyWith(
        status: PaymentStatus.approved,
        decidedAt: decidedAt,
      );

      expect(pending.status, PaymentStatus.pending);
      expect(pending.decidedAt, isNull);
      expect(approved.status, PaymentStatus.approved);
      expect(approved.decidedAt, decidedAt);
    });
  });
}

Payment _payment() => Payment(
  id: 'payment',
  counterparty: 'Counterparty',
  amount: 1,
  currency: 'AED',
  reference: 'Reference',
  createdAt: DateTime.utc(2026, 9),
  status: PaymentStatus.pending,
);
