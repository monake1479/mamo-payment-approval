enum InvalidPaymentReason {
  emptyId,
  emptyCounterparty,
  emptyReference,
  invalidAmount,
  invalidTimestamp,
  invalidStatusTimeline,
  malformedRecord,
}

sealed class PaymentsFailure {
  const PaymentsFailure();

  String get code;
}

final class InvalidPaymentFailure extends PaymentsFailure {
  const InvalidPaymentFailure(this.reason);

  final InvalidPaymentReason reason;

  @override
  String get code => switch (reason) {
    InvalidPaymentReason.emptyId => 'payment.empty_id',
    InvalidPaymentReason.emptyCounterparty => 'payment.empty_counterparty',
    InvalidPaymentReason.emptyReference => 'payment.empty_reference',
    InvalidPaymentReason.invalidAmount => 'payment.invalid_amount',
    InvalidPaymentReason.invalidTimestamp => 'payment.invalid_timestamp',
    InvalidPaymentReason.invalidStatusTimeline =>
      'payment.invalid_status_timeline',
    InvalidPaymentReason.malformedRecord => 'payment.malformed_record',
  };

  @override
  bool operator ==(Object other) =>
      other is InvalidPaymentFailure && other.reason == reason;

  @override
  int get hashCode => reason.hashCode;
}

final class DuplicateRequestFailure extends PaymentsFailure {
  const DuplicateRequestFailure();

  @override
  String get code => 'payment.duplicate_request';

  @override
  bool operator ==(Object other) => other is DuplicateRequestFailure;

  @override
  int get hashCode => code.hashCode;
}

final class PaymentNotFoundFailure extends PaymentsFailure {
  const PaymentNotFoundFailure();

  @override
  String get code => 'payment.not_found';

  @override
  bool operator ==(Object other) => other is PaymentNotFoundFailure;

  @override
  int get hashCode => code.hashCode;
}

final class PaymentAlreadyDecidedFailure extends PaymentsFailure {
  const PaymentAlreadyDecidedFailure();

  @override
  String get code => 'payment.already_decided';

  @override
  bool operator ==(Object other) => other is PaymentAlreadyDecidedFailure;

  @override
  int get hashCode => code.hashCode;
}

final class PaymentBusyFailure extends PaymentsFailure {
  const PaymentBusyFailure();

  @override
  String get code => 'payment.busy';

  @override
  bool operator ==(Object other) => other is PaymentBusyFailure;

  @override
  int get hashCode => code.hashCode;
}

final class StorageFailure extends PaymentsFailure {
  const StorageFailure();

  @override
  String get code => 'payment.storage';

  @override
  bool operator ==(Object other) => other is StorageFailure;

  @override
  int get hashCode => code.hashCode;
}
