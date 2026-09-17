import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_money.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';

abstract final class PaymentRecordCodec {
  static PaymentsResult<Payment> decode(Map<String, Object?> record) {
    try {
      final Object? rawId = record['id'];
      final Object? rawCounterparty = record['counterparty'];
      final Object? rawAmount = record['amount'];
      final Object? rawCurrency = record['currency'];
      final Object? rawReference = record['reference'];
      final Object? rawCreatedAt = record['createdAt'];
      final Object? rawStatus = record['status'];
      final Object? rawDecidedAt = record['decidedAt'];
      if (rawId is! String ||
          rawCounterparty is! String ||
          rawAmount is! String ||
          rawCurrency != PaymentMoney.currencyCode ||
          rawReference is! String ||
          rawCreatedAt is! String ||
          rawStatus is! String ||
          (rawDecidedAt != null && rawDecidedAt is! String)) {
        return _malformed();
      }
      final PaymentsResult<double> amountResult = PaymentMoney.parse(rawAmount);
      if (amountResult case PaymentsError<double>(:final failure)) {
        return PaymentsError<Payment>(failure);
      }
      final double amount = (amountResult as PaymentsSuccess<double>).value;
      final DateTime? createdAt = _parseUtc(rawCreatedAt);
      final DateTime? decidedAt = rawDecidedAt == null
          ? null
          : _parseUtc(rawDecidedAt as String);
      final PaymentStatus? status = _parseStatus(rawStatus);
      if (createdAt == null ||
          status == null ||
          (rawDecidedAt != null && decidedAt == null)) {
        return _malformed();
      }
      final Payment payment = Payment(
        id: rawId,
        counterparty: rawCounterparty,
        amount: amount,
        reference: rawReference,
        createdAt: createdAt,
        status: status,
        decidedAt: decidedAt,
      );
      final InvalidPaymentFailure? validationFailure = payment.validate();
      if (validationFailure != null) {
        return PaymentsError<Payment>(validationFailure);
      }
      return PaymentsSuccess<Payment>(payment);
    } on FormatException {
      return _malformed();
    }
  }

  static Map<String, Object?> encode(Payment payment) {
    final InvalidPaymentFailure? validationFailure = payment.validate();
    if (validationFailure != null) {
      throw ArgumentError.value(payment, 'payment', validationFailure.code);
    }
    return <String, Object?>{
      'id': payment.id,
      'counterparty': payment.counterparty,
      'amount': PaymentMoney.serialize(payment.amount),
      'currency': PaymentMoney.currencyCode,
      'reference': payment.reference,
      'createdAt': payment.createdAt.toIso8601String(),
      'status': payment.status.name,
      'decidedAt': payment.decidedAt?.toIso8601String(),
    };
  }

  static PaymentsError<Payment> _malformed() {
    return const PaymentsError<Payment>(
      InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
    );
  }

  static DateTime? _parseUtc(String value) {
    if (!value.endsWith('Z')) {
      return null;
    }
    final DateTime? parsed = DateTime.tryParse(value);
    return parsed?.isUtc == true ? parsed : null;
  }

  static PaymentStatus? _parseStatus(String value) {
    for (final PaymentStatus status in PaymentStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
    return null;
  }
}
