import 'package:freezed_annotation/freezed_annotation.dart';

part 'payments_failure.freezed.dart';

enum InvalidPaymentReason {
  emptyId,
  emptyCounterparty,
  emptyReference,
  invalidAmount,
  invalidCurrency,
  invalidTimestamp,
  invalidStatusTimeline,
  malformedRecord,
}

@freezed
sealed class PaymentsFailure with _$PaymentsFailure {
  const PaymentsFailure._();

  const factory PaymentsFailure.invalidPayment(InvalidPaymentReason reason) =
      InvalidPaymentFailure;

  const factory PaymentsFailure.duplicateRequest() = DuplicateRequestFailure;

  const factory PaymentsFailure.paymentNotFound() = PaymentNotFoundFailure;

  const factory PaymentsFailure.paymentAlreadyDecided() =
      PaymentAlreadyDecidedFailure;

  const factory PaymentsFailure.paymentBusy() = PaymentBusyFailure;

  const factory PaymentsFailure.operationCancelled() =
      OperationCancelledFailure;

  const factory PaymentsFailure.unavailable() = PaymentsUnavailableFailure;

  String get code => switch (this) {
    InvalidPaymentFailure(:final reason) => switch (reason) {
      InvalidPaymentReason.emptyId => 'payment.empty_id',
      InvalidPaymentReason.emptyCounterparty => 'payment.empty_counterparty',
      InvalidPaymentReason.emptyReference => 'payment.empty_reference',
      InvalidPaymentReason.invalidAmount => 'payment.invalid_amount',
      InvalidPaymentReason.invalidCurrency => 'payment.invalid_currency',
      InvalidPaymentReason.invalidTimestamp => 'payment.invalid_timestamp',
      InvalidPaymentReason.invalidStatusTimeline =>
        'payment.invalid_status_timeline',
      InvalidPaymentReason.malformedRecord => 'payment.malformed_record',
    },
    DuplicateRequestFailure() => 'payment.duplicate_request',
    PaymentNotFoundFailure() => 'payment.not_found',
    PaymentAlreadyDecidedFailure() => 'payment.already_decided',
    PaymentBusyFailure() => 'payment.busy',
    OperationCancelledFailure() => 'payment.operation_cancelled',
    PaymentsUnavailableFailure() => 'payment.unavailable',
  };
}
