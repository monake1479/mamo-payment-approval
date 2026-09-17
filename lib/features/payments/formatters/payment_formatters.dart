import 'package:intl/intl.dart';
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

  DateTime _accountTime(DateTime instant) =>
      time_zone.TZDateTime.from(instant.toUtc(), _location);

  static time_zone.Location _loadLocation(String name) {
    time_zone_data.initializeTimeZones();
    return time_zone.getLocation(name);
  }
}
