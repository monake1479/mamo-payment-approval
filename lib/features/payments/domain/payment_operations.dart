import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_money.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';
import 'package:timezone/data/latest.dart' as time_zone_data;
import 'package:timezone/timezone.dart' as time_zone;

final class PaymentSummary {
  const PaymentSummary({
    required this.approvedAmount,
    required this.approvedCount,
  });

  static const PaymentSummary empty = PaymentSummary(
    approvedAmount: 0,
    approvedCount: 0,
  );

  final double approvedAmount;
  final int approvedCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentSummary &&
          PaymentMoney.equivalentOrZero(other.approvedAmount, approvedAmount) &&
          other.approvedCount == approvedCount;

  @override
  int get hashCode =>
      Object.hash(PaymentMoney.toFilsOrZero(approvedAmount), approvedCount);
}

final class PaymentOperations {
  PaymentOperations({required this.reportingTimeZone})
    : _location = _loadLocation(reportingTimeZone);

  final String reportingTimeZone;
  final time_zone.Location _location;

  List<Payment> decidedHistory(Iterable<Payment> payments) {
    final List<Payment> history = payments
        .where((Payment payment) => payment.status != PaymentStatus.pending)
        .toList(growable: false);
    history.sort((Payment left, Payment right) {
      final int byDecision = right.decidedAt!.compareTo(left.decidedAt!);
      if (byDecision != 0) {
        return byDecision;
      }
      return left.id.compareTo(right.id);
    });
    return List<Payment>.unmodifiable(history);
  }

  PaymentSummary currentMonthSummary({
    required Iterable<Payment> payments,
    required DateTime now,
  }) {
    final PaymentsResult<PaymentSummary> result = tryCurrentMonthSummary(
      payments: payments,
      now: now,
    );
    return switch (result) {
      PaymentsSuccess<PaymentSummary>(:final PaymentSummary value) => value,
      PaymentsError<PaymentSummary>() => throw StateError(
        'Canonical payment collection contains an invalid amount.',
      ),
    };
  }

  DateTime currentMonthStartUtc(DateTime now) => _bounds(now).start;

  PaymentsResult<PaymentSummary> tryCurrentMonthSummary({
    required Iterable<Payment> payments,
    required DateTime now,
  }) {
    final _ReportingBounds bounds = _bounds(now);
    final List<double> approvedAmounts = payments
        .where((Payment payment) {
          final DateTime? decidedAt = payment.decidedAt;
          return payment.status == PaymentStatus.approved &&
              decidedAt != null &&
              !decidedAt.isBefore(bounds.start) &&
              decidedAt.isBefore(bounds.end);
        })
        .map((Payment payment) => payment.amount)
        .toList(growable: false);
    final PaymentsResult<double> total = PaymentMoney.sum(approvedAmounts);
    return switch (total) {
      PaymentsSuccess<double>(:final double value) =>
        PaymentsSuccess<PaymentSummary>(
          PaymentSummary(
            approvedAmount: value,
            approvedCount: approvedAmounts.length,
          ),
        ),
      PaymentsError<double>(:final failure) => PaymentsError<PaymentSummary>(
        failure,
      ),
    };
  }

  static time_zone.Location _loadLocation(String name) {
    time_zone_data.initializeTimeZones();
    return time_zone.getLocation(name);
  }

  _ReportingBounds _bounds(DateTime now) {
    final time_zone.TZDateTime localNow = time_zone.TZDateTime.from(
      now.toUtc(),
      _location,
    );
    return _ReportingBounds(
      start: time_zone.TZDateTime(
        _location,
        localNow.year,
        localNow.month,
      ).toUtc(),
      end: time_zone.TZDateTime(
        _location,
        localNow.year,
        localNow.month + 1,
      ).toUtc(),
    );
  }
}

final class _ReportingBounds {
  const _ReportingBounds({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}
