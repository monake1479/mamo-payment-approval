import 'package:mamo_payment_approval_challenge/common/data/device_authentication/device_authenticator.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/models/device_authentication_cancellation_result.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/create_payment_request_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/decide_payment_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/load_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/refresh_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/device_authentication_failure.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/unit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';

final DateTime fixedNow = DateTime.utc(2026, 9, 17, 8);

const Result<DeviceAuthenticationFailure, Unit> authenticationSucceeded =
    Result<DeviceAuthenticationFailure, Unit>.success(unit);
const Result<DeviceAuthenticationFailure, Unit> authenticationCancelled =
    Result<DeviceAuthenticationFailure, Unit>.failure(
      DeviceAuthenticationFailure.cancelled(),
    );
const Result<DeviceAuthenticationFailure, Unit> authenticationUnavailable =
    Result<DeviceAuthenticationFailure, Unit>.failure(
      DeviceAuthenticationFailure.unavailable(),
    );
const Result<DeviceAuthenticationFailure, Unit> authenticationFailed =
    Result<DeviceAuthenticationFailure, Unit>.failure(
      DeviceAuthenticationFailure.failed(),
    );

final class StubDeviceAuthenticator implements DeviceAuthenticator {
  StubDeviceAuthenticator({
    this.result = authenticationUnavailable,
    this.cancellationResult =
        DeviceAuthenticationCancellationResult.noActiveAttempt,
  });

  Result<DeviceAuthenticationFailure, Unit> result;
  DeviceAuthenticationCancellationResult cancellationResult;
  int authenticateCalls = 0;
  int cancelCalls = 0;

  @override
  Future<Result<DeviceAuthenticationFailure, Unit>> authenticate({
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

  @override
  String get reportingCurrency => 'AED';

  @override
  String get reportingTimeZone => 'Asia/Dubai';
}

PaymentsCubit createPaymentsCubit(
  StubPaymentsRepository repository, {
  DateTime Function()? clock,
}) {
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
  DateTime? decidedAt,
}) {
  final DateTime decision = decidedAt ?? DateTime.utc(2026, 9, 16, 8);
  return Payment(
    id: id,
    counterparty: counterparty,
    amount: amount,
    currency: 'AED',
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
    currency: 'AED',
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
