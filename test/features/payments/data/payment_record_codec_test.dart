import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/features/payments/data/payment_record_codec.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';

void main() {
  group('PaymentRecordCodec', () {
    test('round trips canonical amount, AED, and UTC timestamps', () {
      final Payment payment = Payment(
        id: 'payment-1',
        counterparty: 'Counterparty',
        amount: 1234.5,
        reference: 'Reference',
        createdAt: DateTime.utc(2026, 9, 1, 10, 30),
        status: PaymentStatus.approved,
        decidedAt: DateTime.utc(2026, 9, 2, 11, 45),
      );

      final Map<String, Object?> record = PaymentRecordCodec.encode(payment);
      final PaymentsResult<Payment> decoded = PaymentRecordCodec.decode(record);

      expect(record['amount'], '1234.50');
      expect(record['currency'], 'AED');
      expect(record['createdAt'], '2026-09-01T10:30:00.000Z');
      expect(record['decidedAt'], '2026-09-02T11:45:00.000Z');
      expect((decoded as PaymentsSuccess<Payment>).value, payment);
    });

    test('rejects non-UTC, excess precision, and inconsistent status', () {
      final Map<String, Object?> base = <String, Object?>{
        'id': 'payment-1',
        'counterparty': 'Counterparty',
        'amount': '1.00',
        'currency': 'AED',
        'reference': 'Reference',
        'createdAt': '2026-09-01T10:30:00.000Z',
        'status': 'approved',
        'decidedAt': '2026-09-02T11:45:00.000Z',
      };

      for (final Map<String, Object?> record in <Map<String, Object?>>[
        <String, Object?>{
          ...base,
          'createdAt': '2026-09-01T14:30:00.000+04:00',
        },
        <String, Object?>{...base, 'amount': '1.001'},
        <String, Object?>{...base, 'currency': 'USD'},
        <String, Object?>{...base, 'status': 'pending'},
      ]) {
        expect(
          PaymentRecordCodec.decode(record),
          isA<PaymentsError<Payment>>(),
          reason: '$record must be rejected',
        );
      }
    });

    test('maps malformed records to a stable failure', () {
      final PaymentsResult<Payment> result = PaymentRecordCodec.decode(
        <String, Object?>{'id': 7},
      );

      expect(
        (result as PaymentsError<Payment>).failure,
        const InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
      );
    });
  });
}
