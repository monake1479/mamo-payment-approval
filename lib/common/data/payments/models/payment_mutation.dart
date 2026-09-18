import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payments_collection.dart';

part 'payment_mutation.freezed.dart';

@freezed
abstract class PaymentMutation with _$PaymentMutation {
  const factory PaymentMutation({
    required Payment payment,
    required PaymentsCollection collection,
  }) = _PaymentMutation;
}
