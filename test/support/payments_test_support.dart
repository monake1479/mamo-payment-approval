import 'package:mamo_payment_approval_challenge/features/payments/domain/authentication/device_authenticator.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_operations.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/payments_cubit.dart';

final DateTime fixedNow = DateTime.utc(2026, 9, 17, 8);

final class StubDeviceAuthenticator implements DeviceAuthenticator {
  StubDeviceAuthenticator({
    this.result = const DeviceAuthenticationUnavailable(),
    this.cancellationResult =
        DeviceAuthenticationCancellationResult.noActiveAttempt,
  });

  DeviceAuthenticationResult result;
  DeviceAuthenticationCancellationResult cancellationResult;
  int authenticateCalls = 0;
  int cancelCalls = 0;

  @override
  Future<DeviceAuthenticationResult> authenticate({
    required String localizedReason,
  }) async {
    authenticateCalls += 1;
    return result;
  }

  @override
  Future<DeviceAuthenticationCancellationResult> cancel() async {
    cancelCalls += 1;
    return cancellationResult;
  }
}

final class StubPaymentsRepository implements PaymentsRepository {
  StubPaymentsRepository({
    required this.onLoad,
    this.onCreateRequest,
    this.onDecide,
  });

  final Future<PaymentsResult<List<Payment>>> Function() onLoad;
  final Future<PaymentsResult<Payment>> Function()? onCreateRequest;
  final Future<PaymentsResult<Payment>> Function(
    String paymentId,
    PaymentDecision decision,
  )?
  onDecide;
  int loadCalls = 0;
  int createCalls = 0;
  int decideCalls = 0;

  @override
  Future<PaymentsResult<List<Payment>>> load() {
    loadCalls += 1;
    return onLoad();
  }

  @override
  Future<PaymentsResult<Payment>> createRequest() async {
    createCalls += 1;
    return onCreateRequest?.call() ??
        const PaymentsError<Payment>(StorageFailure());
  }

  @override
  Future<PaymentsResult<Payment>> decide({
    required String paymentId,
    required PaymentDecision decision,
  }) async {
    decideCalls += 1;
    return onDecide?.call(paymentId, decision) ??
        const PaymentsError<Payment>(StorageFailure());
  }
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

Payment pendingPayment({
  String id = 'pending-payment',
  String counterparty = 'Café Services',
  double amount = 88.25,
  String reference = 'INV-2048',
}) => Payment(
  id: id,
  counterparty: counterparty,
  amount: amount,
  reference: reference,
  createdAt: DateTime.utc(2026, 9, 17, 7),
  status: PaymentStatus.pending,
);
