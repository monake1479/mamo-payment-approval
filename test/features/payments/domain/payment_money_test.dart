import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_money.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';

void main() {
  group('PaymentMoney', () {
    test('accepts and canonicalizes valid whole-fils doubles', () {
      final PaymentsResult<double> result = PaymentMoney.canonicalize(
        12.34000000001,
      );

      expect((result as PaymentsSuccess<double>).value, 12.34);
      expect(PaymentMoney.equivalent(0.1 + 0.2, 0.30), isTrue);
    });

    test('rejects unsupported values without rounding them', () {
      for (final double amount in <double>[
        0,
        -0.01,
        1.001,
        double.nan,
        double.infinity,
        PaymentMoney.maximumAmount + 0.01,
      ]) {
        final PaymentsResult<double> result = PaymentMoney.canonicalize(amount);
        expect(
          (result as PaymentsError<double>).failure,
          const InvalidPaymentFailure(InvalidPaymentReason.invalidAmount),
          reason: '$amount must be rejected',
        );
      }
    });

    test('sums already valid values exactly and enforces the cap', () {
      final PaymentsResult<double> simple = PaymentMoney.sum(<double>[
        0.10,
        0.20,
      ]);
      final PaymentsResult<double> repeated = PaymentMoney.sum(
        List<double>.filled(100, 0.10),
      );
      final PaymentsResult<double> maximum = PaymentMoney.sum(<double>[
        999999999.98,
        0.01,
      ]);
      final PaymentsResult<double> overflow = PaymentMoney.sum(<double>[
        999999999.99,
        0.01,
      ]);

      expect((simple as PaymentsSuccess<double>).value, 0.30);
      expect((repeated as PaymentsSuccess<double>).value, 10.00);
      expect((maximum as PaymentsSuccess<double>).value, 999999999.99);
      expect(
        (overflow as PaymentsError<double>).failure,
        const InvalidPaymentFailure(InvalidPaymentReason.invalidAmount),
      );
    });

    test('serializes and formats with the fixed AED contract', () {
      expect(PaymentMoney.formatAed(0), 'AED 0.00');
      expect(PaymentMoney.serialize(1234.5), '1234.50');
      expect(PaymentMoney.formatAed(1234.5), 'AED 1,234.50');
      expect(PaymentMoney.formatAed(999999999.99), 'AED 999,999,999.99');
      expect(
        (PaymentMoney.parse('1234.50') as PaymentsSuccess<double>).value,
        1234.5,
      );
      expect(PaymentMoney.parse('1,234.50'), isA<PaymentsError<double>>());
      expect(PaymentMoney.parse('1234.5'), isA<PaymentsError<double>>());
      expect(PaymentMoney.parse('01.00'), isA<PaymentsError<double>>());
    });
  });
}
