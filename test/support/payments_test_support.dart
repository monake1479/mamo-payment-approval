import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_operations.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/payments_cubit.dart';

final DateTime fixedNow = DateTime.utc(2026, 9, 17, 8);

final class StubPaymentsRepository implements PaymentsRepository {
  StubPaymentsRepository({required this.onLoad});

  final Future<PaymentsResult<List<Payment>>> Function() onLoad;
  int loadCalls = 0;

  @override
  Future<PaymentsResult<List<Payment>>> load() {
    loadCalls += 1;
    return onLoad();
  }

  @override
  Future<PaymentsResult<Payment>> createRequest() async =>
      const PaymentsError<Payment>(StorageFailure());

  @override
  Future<PaymentsResult<Payment>> decide({
    required String paymentId,
    required PaymentDecision decision,
  }) async => const PaymentsError<Payment>(StorageFailure());
}

PaymentsCubit createPaymentsCubit(StubPaymentsRepository repository) {
  return PaymentsCubit(
    repository: repository,
    operations: PaymentOperations(reportingTimeZone: 'Asia/Dubai'),
    clock: () => fixedNow,
  );
}

Payment approvedPayment({
  String id = 'approved-payment',
  String counterparty = 'Atlas Office Supplies',
  double amount = 1240.50,
  DateTime? decidedAt,
}) {
  final DateTime decision = decidedAt ?? DateTime.utc(2026, 9, 16, 8);
  return Payment(
    id: id,
    counterparty: counterparty,
    amount: amount,
    reference: 'PO-1042',
    createdAt: decision.subtract(const Duration(days: 2)),
    status: PaymentStatus.approved,
    decidedAt: decision,
  );
}

Payment rejectedPayment({
  String id = 'rejected-payment',
  String counterparty = 'Marina Logistics',
  double amount = 315.25,
  DateTime? decidedAt,
}) {
  final DateTime decision = decidedAt ?? DateTime.utc(2026, 9, 15, 8);
  return Payment(
    id: id,
    counterparty: counterparty,
    amount: amount,
    reference: 'SHIP-778',
    createdAt: decision.subtract(const Duration(days: 2)),
    status: PaymentStatus.rejected,
    decidedAt: decision,
  );
}
