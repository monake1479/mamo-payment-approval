import 'package:mamo_payment_approval_challenge/common/data/payments/data_sources/payments_remote_data_source.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/create_payment_request_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/decide_payment_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/load_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/refresh_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/mock_backend/payments/payments_backend_client.dart';
import 'package:mamo_payment_approval_challenge/mock_backend/payments/payments_backend_exception.dart';

final DateTime fixedNow = DateTime.utc(2026, 9, 17, 8);

final class StubPaymentsBackend implements PaymentsBackendClient {
  StubPaymentsBackend({required this.onLoad});

  final Future<List<Payment>> Function() onLoad;
  int loadCalls = 0;

  @override
  String get currency => 'AED';

  @override
  String get reportingTimeZone => 'Asia/Dubai';

  @override
  Future<List<Map<String, Object?>>> loadPayments() async {
    loadCalls += 1;
    return (await onLoad()).map(_record).toList(growable: false);
  }

  @override
  Future<Map<String, Object?>> createPaymentRequest() async =>
      throw const PaymentsBackendException(
        PaymentsBackendErrorCode.unavailable,
      );

  @override
  Future<Map<String, Object?>> decidePayment({
    required String paymentId,
    required String decision,
  }) async => throw const PaymentsBackendException(
    PaymentsBackendErrorCode.unavailable,
  );

  static Map<String, Object?> _record(Payment payment) => <String, Object?>{
    'id': payment.id,
    'counterparty': payment.counterparty,
    'amount': payment.amount.toStringAsFixed(2),
    'currency': payment.currency,
    'reference': payment.reference,
    'createdAt': payment.createdAt.toIso8601String(),
    'status': payment.status.name,
    'decidedAt': payment.decidedAt?.toIso8601String(),
  };
}

PaymentsCubit createPaymentsCubit(
  StubPaymentsBackend backend, {
  DateTime Function()? clock,
}) {
  final PaymentsRepository repository = PaymentsRepository(
    PaymentsRemoteDataSource(backend),
  );
  final DateTime Function() resolvedClock = clock ?? (() => fixedNow);
  return PaymentsCubit(
    loadPayments: LoadPaymentsUseCase(repository, clock: resolvedClock),
    createPaymentRequest: CreatePaymentRequestUseCase(
      repository,
      clock: resolvedClock,
    ),
    decidePayment: DecidePaymentUseCase(repository, clock: resolvedClock),
    refreshPayments: RefreshPaymentsUseCase(repository, clock: resolvedClock),
  );
}

Payment approvedPayment({
  String id = 'approved-payment',
  String counterparty = 'Atlas Office Supplies',
  double amount = 1240.50,
  String currency = 'AED',
  DateTime? decidedAt,
}) {
  final DateTime decision = decidedAt ?? DateTime.utc(2026, 9, 16, 8);
  return Payment(
    id: id,
    counterparty: counterparty,
    amount: amount,
    currency: currency,
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
  String currency = 'AED',
  DateTime? decidedAt,
}) {
  final DateTime decision = decidedAt ?? DateTime.utc(2026, 9, 15, 8);
  return Payment(
    id: id,
    counterparty: counterparty,
    amount: amount,
    currency: currency,
    reference: 'SHIP-778',
    createdAt: decision.subtract(const Duration(days: 2)),
    status: PaymentStatus.rejected,
    decidedAt: decision,
  );
}
