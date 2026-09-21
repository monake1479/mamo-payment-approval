import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_payment_approval_challenge/common/converters/utc_datetime_json_converter.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/converters/payment_amount_json_converter.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';

part 'payment_dto.freezed.dart';
part 'payment_dto.g.dart';

@freezed
abstract class PaymentDto with _$PaymentDto {
  const PaymentDto._();

  const factory PaymentDto({
    required String id,
    required String counterparty,
    @PaymentAmountJsonConverter() required double amount,
    required String currency,
    required String reference,
    @UtcDateTimeJsonConverter() required DateTime createdAt,
    required PaymentStatus status,
    @UtcDateTimeJsonConverter() DateTime? decidedAt,
  }) = _PaymentDto;

  factory PaymentDto.fromJson(Map<String, Object?> json) =>
      _$PaymentDtoFromJson(json);

  factory PaymentDto.fromModel(Payment payment) => PaymentDto(
    id: payment.id,
    counterparty: payment.counterparty,
    amount: payment.amount,
    currency: payment.currency,
    reference: payment.reference,
    createdAt: payment.createdAt,
    status: payment.status,
    decidedAt: payment.decidedAt,
  );

  InvalidPaymentFailure? validate() {
    if (id.trim().isEmpty) {
      return const InvalidPaymentFailure(InvalidPaymentReason.emptyId);
    }
    if (counterparty.trim().isEmpty) {
      return const InvalidPaymentFailure(
        InvalidPaymentReason.emptyCounterparty,
      );
    }
    if (reference.trim().isEmpty) {
      return const InvalidPaymentFailure(InvalidPaymentReason.emptyReference);
    }
    if (!amount.isFinite ||
        amount <= 0 ||
        !_hasAtMostTwoDecimalPlaces(amount)) {
      return const InvalidPaymentFailure(InvalidPaymentReason.invalidAmount);
    }
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      return const InvalidPaymentFailure(InvalidPaymentReason.invalidCurrency);
    }
    if (!createdAt.isUtc || (decidedAt != null && !decidedAt!.isUtc)) {
      return const InvalidPaymentFailure(InvalidPaymentReason.invalidTimestamp);
    }
    final bool pendingTimeline =
        status == PaymentStatus.pending && decidedAt == null;
    final bool decidedTimeline =
        status != PaymentStatus.pending &&
        decidedAt != null &&
        !decidedAt!.isBefore(createdAt);
    if (!pendingTimeline && !decidedTimeline) {
      return const InvalidPaymentFailure(
        InvalidPaymentReason.invalidStatusTimeline,
      );
    }
    return null;
  }

  Payment toModel() => Payment(
    id: id,
    counterparty: counterparty,
    amount: amount,
    currency: currency,
    reference: reference,
    createdAt: createdAt,
    status: status,
    decidedAt: decidedAt,
  );

  static bool _hasAtMostTwoDecimalPlaces(double amount) {
    final String text = amount.toString().toLowerCase();
    final List<String> exponentParts = text.split('e');
    final String coefficient = exponentParts.first;
    final int exponent = exponentParts.length == 2
        ? int.parse(exponentParts.last)
        : 0;
    final int decimalIndex = coefficient.indexOf('.');
    final int coefficientDecimalPlaces = decimalIndex < 0
        ? 0
        : coefficient.length - decimalIndex - 1;
    return coefficientDecimalPlaces - exponent <= 2;
  }
}
