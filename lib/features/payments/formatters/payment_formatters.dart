import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as time_zone_data;
import 'package:timezone/timezone.dart' as time_zone;

final class PaymentFormatters {
  PaymentFormatters({required String reportingTimeZone})
    : _location = _loadLocation(reportingTimeZone);

  final time_zone.Location _location;

  String money(String currency, double amount) => formatMoney(currency, amount);

  static String formatMoney(String currency, double amount) =>
      '$currency ${NumberFormat('#,##0.00', 'en_US').format(amount)}';

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
