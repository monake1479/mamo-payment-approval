import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mamo_payment_approval_challenge/features/payments/formatters/payment_formatters.dart';

void main() {
  final PaymentFormatters formatter = PaymentFormatters(
    reportingTimeZone: 'Asia/Dubai',
  );

  test('formats AED with fixed English separators and two decimals', () {
    expect(formatter.money('AED', 0), 'AED 0.00');
    expect(formatter.money('AED', 1234.5), 'AED 1,234.50');
    expect(formatter.money('USD', 999999999.99), 'USD 999,999,999.99');
  });

  test('converts UTC instants to the account zone before formatting', () {
    final DateTime instant = DateTime.utc(2026, 8, 31, 22, 5);

    expect(formatter.dateTime(instant), '01 Sep 2026, 02:05');
    expect(formatter.month(instant), 'September 2026');
  });

  test('keeps the English date contract when the default locale differs', () {
    final String? previousLocale = Intl.defaultLocale;
    addTearDown(() => Intl.defaultLocale = previousLocale);
    Intl.defaultLocale = 'pl_PL';

    final DateTime instant = DateTime.utc(2026, 12, 31, 23, 9);
    expect(formatter.dateTime(instant), '01 Jan 2027, 03:09');
    expect(formatter.month(instant), 'January 2027');
  });
}
