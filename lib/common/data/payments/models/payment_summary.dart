import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_summary.freezed.dart';

@freezed
abstract class PaymentSummary with _$PaymentSummary {
  const factory PaymentSummary({
    required double approvedAmount,
    required int approvedCount,
  }) = _PaymentSummary;

  factory PaymentSummary.empty() =>
      const PaymentSummary(approvedAmount: 0, approvedCount: 0);
}
