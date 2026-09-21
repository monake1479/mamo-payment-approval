import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment_summary.dart';

part 'payments_state.freezed.dart';

enum PaymentsLoadStatus { initial, loading, success, failure }

@freezed
abstract class PaymentsState with _$PaymentsState {
  const PaymentsState._();

  const factory PaymentsState({
    required PaymentsLoadStatus status,
    required List<Payment> payments,
    required PaymentSummary summary,
    required DateTime reportingPeriodStartUtc,
    required String reportingTimeZone,
    required String reportingCurrency,
    required bool hasLoaded,
    required PaymentsFailure? failure,
    required bool isCreatingRequest,
    required Set<String> decidingPaymentIds,
  }) = _PaymentsState;

  factory PaymentsState.initial({
    required String reportingTimeZone,
    required String reportingCurrency,
    required DateTime reportingPeriodStartUtc,
  }) {
    return PaymentsState(
      status: PaymentsLoadStatus.initial,
      payments: const <Payment>[],
      summary: PaymentSummary.empty(),
      reportingPeriodStartUtc: reportingPeriodStartUtc,
      reportingTimeZone: reportingTimeZone,
      reportingCurrency: reportingCurrency,
      hasLoaded: false,
      failure: null,
      isCreatingRequest: false,
      decidingPaymentIds: const <String>{},
    );
  }

  bool get canCreateRequest =>
      hasLoaded && !isCreatingRequest && activeRequest == null;

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
