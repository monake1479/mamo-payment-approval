import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mamo_approval/common/data/payments/models/payments_date_range.dart';
import 'package:mamo_approval/features/payments/formatters/payment_formatters.dart';

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

  test('keeps the English date contract when the default locale differs', () {
    final String? previousLocale = Intl.defaultLocale;
    addTearDown(() => Intl.defaultLocale = previousLocale);
    Intl.defaultLocale = 'pl_PL';

    final DateTime instant = DateTime.utc(2026, 12, 31, 23, 9);
    expect(formatter.dateTime(instant), '01 Jan 2027, 03:09');
    expect(formatter.month(instant), 'January 2027');
  });

  test('turns account-zone calendar days into a UTC window and back', () {
    final PaymentsDateRange window = formatter.accountDays(
      DateTime(2026, 9, 15),
      DateTime(2026, 9, 17),
    );

    // Asia/Dubai is UTC+4 all year.
    expect(window.startUtc, DateTime.utc(2026, 9, 14, 20));
    expect(window.endUtc, DateTime.utc(2026, 9, 17, 20));
    expect(formatter.dateRange(window), '15 Sep 2026 – 17 Sep 2026');
    expect(
      formatter.accountDay(DateTime.utc(2026, 9, 14, 21)),
      DateTime(2026, 9, 15),
    );
  });
}
