import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/features/payments/formatters/payment_formatters.dart';

void main() {
  final PaymentFormatters formatter = PaymentFormatters(
    reportingTimeZone: 'Asia/Dubai',
  );

  test('formats ISO currencies with fixed English separators', () {
    expect(formatter.money(0, 'AED'), 'AED 0.00');
    expect(formatter.money(1234.5, 'AED'), 'AED 1,234.50');
    expect(formatter.money(999999999.99, 'USD'), 'USD 999,999,999.99');
  });

  test('converts UTC instants to the account zone before formatting', () {
    final DateTime instant = DateTime.utc(2026, 8, 31, 22, 5);

    expect(formatter.dateTime(instant), '01 Sep 2026, 02:05');
    expect(formatter.month(instant), 'September 2026');
  });
}
