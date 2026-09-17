import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_money.dart';
import 'package:timezone/data/latest.dart' as time_zone_data;
import 'package:timezone/timezone.dart' as time_zone;

final class PaymentFormatters {
  PaymentFormatters({required String reportingTimeZone})
    : _location = _loadLocation(reportingTimeZone);

  final time_zone.Location _location;
  static const List<String> _shortMonths = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const List<String> _longMonths = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String aed(double amount) => PaymentMoney.formatAed(amount);

  String dateTime(DateTime instant) {
    final DateTime accountTime = _accountTime(instant);
    final String day = accountTime.day.toString().padLeft(2, '0');
    final String hour = accountTime.hour.toString().padLeft(2, '0');
    final String minute = accountTime.minute.toString().padLeft(2, '0');
    return '$day ${_shortMonths[accountTime.month - 1]} '
        '${accountTime.year}, $hour:$minute';
  }

  String month(DateTime instant) {
    final DateTime accountTime = _accountTime(instant);
    return '${_longMonths[accountTime.month - 1]} ${accountTime.year}';
  }

  DateTime _accountTime(DateTime instant) =>
      time_zone.TZDateTime.from(instant.toUtc(), _location);

  static time_zone.Location _loadLocation(String name) {
    time_zone_data.initializeTimeZones();
    return time_zone.getLocation(name);
  }
}
