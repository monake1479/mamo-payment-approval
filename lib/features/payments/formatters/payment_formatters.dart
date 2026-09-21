import 'package:intl/intl.dart';
import 'package:mamo_approval/common/data/payments/models/payments_date_range.dart';
import 'package:timezone/data/latest.dart' as time_zone_data;
import 'package:timezone/timezone.dart' as time_zone;

final class PaymentFormatters {
  PaymentFormatters({required String reportingTimeZone})
    : _location = _loadLocation(reportingTimeZone);

  final time_zone.Location _location;

  String money(double amount, String currency) {
    final List<String> parts = amount.toStringAsFixed(2).split('.');
    final String whole = parts.first;
    final StringBuffer grouped = StringBuffer();
    for (int index = 0; index < whole.length; index += 1) {
      if (index > 0 && (whole.length - index) % 3 == 0) {
        grouped.write(',');
      }
      grouped.write(whole[index]);
    }
    return '$currency $grouped.${parts.last}';
  }

  String dateTime(DateTime instant) =>
      DateFormat('dd MMM yyyy, HH:mm', 'en_US').format(_accountTime(instant));

  String month(DateTime instant) =>
      DateFormat('MMMM yyyy', 'en_US').format(_accountTime(instant));

  /// Calendar days in the account zone as a UTC window: the start of
  /// [firstDay] inclusive to the start of the day after [lastDay] exclusive.
  PaymentsDateRange accountDays(DateTime firstDay, DateTime lastDay) {
    return PaymentsDateRange(
      startUtc: _accountDayStart(firstDay),
      endUtc: _accountDayStart(lastDay.add(const Duration(days: 1))),
    );
  }

  /// The calendar day of [instant] in the account zone, as a plain date.
  DateTime accountDay(DateTime instant) {
    final DateTime local = _accountTime(instant);
    return DateTime(local.year, local.month, local.day);
  }

  /// Inclusive calendar-day label for a window built by [accountDays].
  String dateRange(PaymentsDateRange range) {
    final DateTime first = _accountTime(range.startUtc);
    final DateTime last = _accountTime(
      range.endUtc.subtract(const Duration(days: 1)),
    );
    final DateFormat day = DateFormat('dd MMM yyyy', 'en_US');
    return '${day.format(first)} – ${day.format(last)}';
  }

  DateTime _accountDayStart(DateTime day) =>
      time_zone.TZDateTime(_location, day.year, day.month, day.day).toUtc();

  DateTime _accountTime(DateTime instant) =>
      time_zone.TZDateTime.from(instant.toUtc(), _location);

  static time_zone.Location _loadLocation(String name) {
    time_zone_data.initializeTimeZones();
    return time_zone.getLocation(name);
  }
}
