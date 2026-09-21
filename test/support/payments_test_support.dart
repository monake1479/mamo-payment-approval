import 'package:mamo_payment_approval_challenge/common/data/payments/data_sources/payments_remote_data_source.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/create_payment_request_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/decide_payment_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/load_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/refresh_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
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

Payment pendingPayment({
  String id = 'pending-payment',
  String counterparty = 'Café Services',
  double amount = 88.25,
  String reference = 'INV-2048',
}) => Payment(
  id: id,
  counterparty: counterparty,
  amount: amount,
  currency: 'AED',
  reference: reference,
  createdAt: DateTime.utc(2026, 9, 17, 7),
  status: PaymentStatus.pending,
);

/// Repository-level payments double for the approval-flow integration tests,
/// which drive create and decide outcomes the load-only [StubPaymentsBackend]
/// does not model. Overrides bypass the injected data source.
final class StubPaymentsRepository extends PaymentsRepository {
  StubPaymentsRepository({
    required this.onLoad,
    this.onCreateRequest,
    this.onDecide,
  }) : super(const PaymentsRemoteDataSource(_UnusedBackendClient()));

  final Future<Result<PaymentsFailure, List<Payment>>> Function() onLoad;
  final Future<Result<PaymentsFailure, Payment>> Function()? onCreateRequest;
  final Future<Result<PaymentsFailure, Payment>> Function(
    String paymentId,
    PaymentDecision decision,
  )?
  onDecide;
  int loadCalls = 0;
  int createCalls = 0;
  int decideCalls = 0;

  @override
  String get reportingTimeZone => 'Asia/Dubai';

  @override
  String get reportingCurrency => 'AED';

  @override
  Future<Result<PaymentsFailure, List<Payment>>> load() {
    loadCalls += 1;
    return onLoad();
  }

  @override
  Future<Result<PaymentsFailure, Payment>> createRequest() async {
    createCalls += 1;
    return onCreateRequest?.call() ??
        const Failure<PaymentsFailure, Payment>(PaymentsUnavailableFailure());
  }

  @override
  Future<Result<PaymentsFailure, Payment>> decide({
    required String paymentId,
    required PaymentDecision decision,
  }) async {
    decideCalls += 1;
    return onDecide?.call(paymentId, decision) ??
        const Failure<PaymentsFailure, Payment>(PaymentsUnavailableFailure());
  }
}

final class _UnusedBackendClient implements PaymentsBackendClient {
  const _UnusedBackendClient();

  @override
  String get currency => 'AED';

  @override
  String get reportingTimeZone => 'Asia/Dubai';

  @override
  Future<Map<String, Object?>> createPaymentRequest() =>
      throw UnimplementedError();

  @override
  Future<Map<String, Object?>> decidePayment({
    required String paymentId,
    required String decision,
  }) => throw UnimplementedError();

  @override
  Future<List<Map<String, Object?>>> loadPayments() =>
      throw UnimplementedError();
}

PaymentsCubit createPaymentsCubitFromRepository(
  StubPaymentsRepository repository, {
  DateTime Function()? clock,
}) {
  final DateTime Function() effectiveClock = clock ?? (() => fixedNow);
  return PaymentsCubit(
    loadPayments: LoadPaymentsUseCase(repository, clock: effectiveClock),
    createPaymentRequest: CreatePaymentRequestUseCase(
      repository,
      clock: effectiveClock,
    ),
    decidePayment: DecidePaymentUseCase(repository, clock: effectiveClock),
    refreshPayments: RefreshPaymentsUseCase(repository, clock: effectiveClock),
  );
}
