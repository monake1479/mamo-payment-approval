import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';

abstract interface class PaymentsRepository {
  Future<PaymentsResult<List<Payment>>> load();

  Future<PaymentsResult<Payment>> createRequest();

  Future<PaymentsResult<Payment>> decide({
    required String paymentId,
    required PaymentDecision decision,
  });
}
