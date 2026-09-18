import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';

enum PaymentStatus { pending, approved, rejected }

enum PaymentDecision { approve, reject }

@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String counterparty,
    required double amount,
    required String currency,
    required String reference,
    required DateTime createdAt,
    required PaymentStatus status,
    DateTime? decidedAt,
  }) = _Payment;
}
