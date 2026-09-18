import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment_summary.dart';
import 'package:timezone/data/latest.dart' as time_zone_data;
import 'package:timezone/timezone.dart' as time_zone;

part 'payments_collection.freezed.dart';

@freezed
abstract class PaymentsCollection with _$PaymentsCollection {
  const PaymentsCollection._();

  const factory PaymentsCollection({
    required List<Payment> payments,
    required PaymentSummary summary,
    required DateTime reportingPeriodStartUtc,
    required String reportingTimeZone,
    required String reportingCurrency,
  }) = _PaymentsCollection;

  factory PaymentsCollection.fromPayments({
    required Iterable<Payment> payments,
    required DateTime now,
    required String reportingTimeZone,
    required String reportingCurrency,
  }) {
    time_zone_data.initializeTimeZones();
    final time_zone.Location location = time_zone.getLocation(
      reportingTimeZone,
    );
    final time_zone.TZDateTime localNow = time_zone.TZDateTime.from(
      now.toUtc(),
      location,
    );
    final DateTime periodStart = time_zone.TZDateTime(
      location,
      localNow.year,
      localNow.month,
    ).toUtc();
    final DateTime periodEnd = time_zone.TZDateTime(
      location,
      localNow.year,
      localNow.month + 1,
    ).toUtc();
    final List<Payment> source = payments.toList(growable: false);
    final List<Payment> decided =
        source
            .where((Payment payment) => payment.status != PaymentStatus.pending)
            .toList(growable: false)
          ..sort((Payment left, Payment right) {
            final int byDecision = right.decidedAt!.compareTo(left.decidedAt!);
            return byDecision != 0 ? byDecision : left.id.compareTo(right.id);
          });
    final List<Payment> approvedInPeriod = decided
        .where((Payment payment) {
          final DateTime decidedAt = payment.decidedAt!;
          return payment.status == PaymentStatus.approved &&
              payment.currency == reportingCurrency &&
              !decidedAt.isBefore(periodStart) &&
              decidedAt.isBefore(periodEnd);
        })
        .toList(growable: false);
    final double approvedAmount = approvedInPeriod.fold<double>(
      0,
      (double total, Payment payment) => total + payment.amount,
    );

    return PaymentsCollection(
      payments: <Payment>[
        ...decided,
        ...source.where(
          (Payment payment) => payment.status == PaymentStatus.pending,
        ),
      ],
      summary: approvedInPeriod.isEmpty
          ? PaymentSummary.empty()
          : PaymentSummary(
              approvedAmount: approvedAmount,
              approvedCount: approvedInPeriod.length,
            ),
      reportingPeriodStartUtc: periodStart,
      reportingTimeZone: reportingTimeZone,
      reportingCurrency: reportingCurrency,
    );
  }

  Payment? get activeRequest {
    for (final Payment payment in payments) {
      if (payment.status == PaymentStatus.pending) {
        return payment;
      }
    }
    return null;
  }

  List<Payment> get decidedPayments => List<Payment>.unmodifiable(
    payments.where(
      (Payment payment) => payment.status != PaymentStatus.pending,
    ),
  );

  Payment? paymentById(String id) {
    for (final Payment payment in payments) {
      if (payment.id == id) {
        return payment;
      }
    }
    return null;
  }
}
