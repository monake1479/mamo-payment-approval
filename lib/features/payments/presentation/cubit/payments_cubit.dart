import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_money.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_operations.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';

enum PaymentsLoadStatus { initial, loading, success, failure }

final class PaymentsState {
  PaymentsState({
    required this.status,
    required List<Payment> payments,
    required this.summary,
    required this.reportingPeriodStartUtc,
    required this.reportingTimeZone,
    required this.hasLoaded,
    required this.failure,
    required this.isCreatingRequest,
    required Set<String> decidingPaymentIds,
  }) : payments = List<Payment>.unmodifiable(payments),
       decidingPaymentIds = Set<String>.unmodifiable(decidingPaymentIds);

  factory PaymentsState.initial({
    required String reportingTimeZone,
    required DateTime reportingPeriodStartUtc,
  }) {
    return PaymentsState(
      status: PaymentsLoadStatus.initial,
      payments: const <Payment>[],
      summary: PaymentSummary.empty,
      reportingPeriodStartUtc: reportingPeriodStartUtc,
      reportingTimeZone: reportingTimeZone,
      hasLoaded: false,
      failure: null,
      isCreatingRequest: false,
      decidingPaymentIds: const <String>{},
    );
  }

  final PaymentsLoadStatus status;
  final List<Payment> payments;
  final PaymentSummary summary;
  final DateTime reportingPeriodStartUtc;
  final String reportingTimeZone;
  final bool hasLoaded;
  final PaymentsFailure? failure;
  final bool isCreatingRequest;
  final Set<String> decidingPaymentIds;

  bool get canCreateRequest =>
      hasLoaded && !isCreatingRequest && activeRequest == null;

  Payment? get activeRequest {
    for (final Payment payment in payments) {
      if (payment.status == PaymentStatus.pending) {
        return payment;
      }
    }
    return null;
  }

  List<Payment> get decidedPayments => List<Payment>.unmodifiable(
    payments.where(
      (Payment payment) => payment.status != PaymentStatus.pending,
    ),
  );

  Payment? paymentById(String id) {
    for (final Payment payment in payments) {
      if (payment.id == id) {
        return payment;
      }
    }
    return null;
  }

  PaymentsState copyWith({
    PaymentsLoadStatus? status,
    List<Payment>? payments,
    PaymentSummary? summary,
    DateTime? reportingPeriodStartUtc,
    bool? hasLoaded,
    Object? failure = _unchanged,
    bool? isCreatingRequest,
    Set<String>? decidingPaymentIds,
  }) {
    return PaymentsState(
      status: status ?? this.status,
      payments: payments ?? this.payments,
      summary: summary ?? this.summary,
      reportingPeriodStartUtc:
          reportingPeriodStartUtc ?? this.reportingPeriodStartUtc,
      reportingTimeZone: reportingTimeZone,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      failure: identical(failure, _unchanged)
          ? this.failure
          : failure as PaymentsFailure?,
      isCreatingRequest: isCreatingRequest ?? this.isCreatingRequest,
      decidingPaymentIds: decidingPaymentIds ?? this.decidingPaymentIds,
    );
  }

  static const Object _unchanged = Object();
}

final class PaymentsCubit extends Cubit<PaymentsState> {
  factory PaymentsCubit({
    required PaymentsRepository repository,
    required PaymentOperations operations,
    required DateTime Function() clock,
  }) {
    return PaymentsCubit._(
      repository,
      operations,
      clock,
      operations.reportingTimeZone,
      operations.currentMonthStartUtc(clock()),
    );
  }

  PaymentsCubit._(
    this._repository,
    this._operations,
    this._clock,
    String reportingTimeZone,
    DateTime reportingPeriodStartUtc,
  ) : super(
        PaymentsState.initial(
          reportingTimeZone: reportingTimeZone,
          reportingPeriodStartUtc: reportingPeriodStartUtc,
        ),
      );

  final PaymentsRepository _repository;
  final PaymentOperations _operations;
  final DateTime Function() _clock;
  int _latestLoad = 0;
  int _mutationVersion = 0;

  Future<PaymentsResult<void>> load() async {
    if (isClosed) {
      return const PaymentsError<void>(StorageFailure());
    }
    final int loadId = ++_latestLoad;
    final int startingMutationVersion = _mutationVersion;
    emit(state.copyWith(status: PaymentsLoadStatus.loading, failure: null));
    final PaymentsResult<List<Payment>> result = await _repository.load();
    if (isClosed) {
      return const PaymentsError<void>(StorageFailure());
    }
    if (loadId != _latestLoad || startingMutationVersion != _mutationVersion) {
      return const PaymentsSuccess<void>(null);
    }
    if (state.isCreatingRequest || state.decidingPaymentIds.isNotEmpty) {
      return const PaymentsSuccess<void>(null);
    }
    return switch (result) {
      PaymentsError<List<Payment>>(:final failure) => _loadFailed(failure),
      PaymentsSuccess<List<Payment>>(:final value) => _loadSucceeded(value),
    };
  }

  Future<PaymentsResult<Payment>> createRequest() async {
    if (isClosed) {
      return const PaymentsError<Payment>(StorageFailure());
    }
    if (!state.hasLoaded) {
      return const PaymentsError<Payment>(PaymentBusyFailure());
    }
    if (state.isCreatingRequest) {
      return const PaymentsError<Payment>(PaymentBusyFailure());
    }
    if (state.activeRequest != null) {
      return const PaymentsError<Payment>(DuplicateRequestFailure());
    }
    emit(state.copyWith(isCreatingRequest: true, failure: null));
    final PaymentsResult<Payment> result = await _repository.createRequest();
    if (isClosed) {
      return const PaymentsError<Payment>(StorageFailure());
    }
    return switch (result) {
      PaymentsError<Payment>(:final failure) => _creationFailed(failure),
      PaymentsSuccess<Payment>(:final value) => _creationSucceeded(value),
    };
  }

  Future<PaymentsResult<Payment>> decide({
    required String paymentId,
    required PaymentDecision decision,
  }) async {
    if (isClosed) {
      return const PaymentsError<Payment>(StorageFailure());
    }
    if (state.decidingPaymentIds.contains(paymentId)) {
      return const PaymentsError<Payment>(PaymentBusyFailure());
    }
    final Payment? current = _findPayment(paymentId);
    if (current == null) {
      return const PaymentsError<Payment>(PaymentNotFoundFailure());
    }
    if (current.status != PaymentStatus.pending) {
      return const PaymentsError<Payment>(PaymentAlreadyDecidedFailure());
    }
    final Set<String> deciding = <String>{
      ...state.decidingPaymentIds,
      paymentId,
    };
    emit(state.copyWith(decidingPaymentIds: deciding, failure: null));
    final PaymentsResult<Payment> result = await _repository.decide(
      paymentId: paymentId,
      decision: decision,
    );
    if (isClosed) {
      return const PaymentsError<Payment>(StorageFailure());
    }
    return switch (result) {
      PaymentsError<Payment>(:final failure) => _decisionFailed(
        paymentId,
        failure,
      ),
      PaymentsSuccess<Payment>(:final value) => _decisionSucceeded(
        current,
        value,
        decision,
      ),
    };
  }

  PaymentsResult<void> refreshDerivedState() {
    if (isClosed) {
      return const PaymentsError<void>(StorageFailure());
    }
    final PaymentsResult<_Projection> projection = _project(state.payments);
    if (projection case PaymentsError<_Projection>(:final failure)) {
      emit(state.copyWith(failure: failure));
      return PaymentsError<void>(failure);
    }
    final _Projection value =
        (projection as PaymentsSuccess<_Projection>).value;
    emit(
      state.copyWith(
        payments: value.payments,
        summary: value.summary,
        reportingPeriodStartUtc: value.reportingPeriodStartUtc,
        failure: null,
      ),
    );
    return const PaymentsSuccess<void>(null);
  }

  PaymentsResult<Payment> _creationFailed(PaymentsFailure failure) {
    emit(
      state.copyWith(
        status: PaymentsLoadStatus.success,
        failure: failure,
        isCreatingRequest: false,
      ),
    );
    return PaymentsError<Payment>(failure);
  }

  PaymentsResult<Payment> _creationSucceeded(Payment payment) {
    final Payment? existing = _findPayment(payment.id);
    if (payment.status != PaymentStatus.pending ||
        (existing != null && existing != payment)) {
      return _creationFailed(
        const InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
      );
    }
    final PaymentsResult<_Projection> projection = _project(
      existing == null ? <Payment>[...state.payments, payment] : state.payments,
    );
    if (projection case PaymentsError<_Projection>(:final failure)) {
      return _creationFailed(failure);
    }
    final _Projection value =
        (projection as PaymentsSuccess<_Projection>).value;
    _mutationVersion += 1;
    emit(
      state.copyWith(
        status: PaymentsLoadStatus.success,
        payments: value.payments,
        summary: value.summary,
        reportingPeriodStartUtc: value.reportingPeriodStartUtc,
        failure: null,
        isCreatingRequest: false,
      ),
    );
    return PaymentsSuccess<Payment>(payment);
  }

  PaymentsResult<Payment> _decisionFailed(
    String paymentId,
    PaymentsFailure failure,
  ) {
    final Set<String> deciding = <String>{...state.decidingPaymentIds}
      ..remove(paymentId);
    emit(
      state.copyWith(
        status: PaymentsLoadStatus.success,
        decidingPaymentIds: deciding,
        failure: failure,
      ),
    );
    return PaymentsError<Payment>(failure);
  }

  PaymentsResult<Payment> _decisionSucceeded(
    Payment previous,
    Payment decided,
    PaymentDecision requestedDecision,
  ) {
    if (!_isValidDecision(previous, decided, requestedDecision)) {
      return _decisionFailed(
        previous.id,
        const InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
      );
    }
    final bool remainsInCollection = state.payments.any(
      (Payment payment) => payment.id == decided.id,
    );
    final List<Payment> updated = <Payment>[
      ...state.payments.map(
        (Payment payment) => payment.id == decided.id ? decided : payment,
      ),
      if (!remainsInCollection) decided,
    ];
    final PaymentsResult<_Projection> projection = _project(updated);
    if (projection case PaymentsError<_Projection>(:final failure)) {
      return _decisionFailed(previous.id, failure);
    }
    final _Projection value =
        (projection as PaymentsSuccess<_Projection>).value;
    final Set<String> deciding = <String>{...state.decidingPaymentIds}
      ..remove(previous.id);
    _mutationVersion += 1;
    emit(
      state.copyWith(
        status: PaymentsLoadStatus.success,
        payments: value.payments,
        summary: value.summary,
        reportingPeriodStartUtc: value.reportingPeriodStartUtc,
        failure: null,
        decidingPaymentIds: deciding,
      ),
    );
    return PaymentsSuccess<Payment>(decided);
  }

  PaymentsResult<void> _loadFailed(PaymentsFailure failure) {
    emit(state.copyWith(status: PaymentsLoadStatus.failure, failure: failure));
    return PaymentsError<void>(failure);
  }

  PaymentsResult<void> _loadSucceeded(List<Payment> payments) {
    final PaymentsResult<_Projection> projection = _project(payments);
    if (projection case PaymentsError<_Projection>(:final failure)) {
      return _loadFailed(failure);
    }
    final _Projection value =
        (projection as PaymentsSuccess<_Projection>).value;
    emit(
      state.copyWith(
        status: PaymentsLoadStatus.success,
        payments: value.payments,
        summary: value.summary,
        reportingPeriodStartUtc: value.reportingPeriodStartUtc,
        hasLoaded: true,
        failure: null,
      ),
    );
    return const PaymentsSuccess<void>(null);
  }

  Payment? _findPayment(String id) {
    for (final Payment payment in state.payments) {
      if (payment.id == id) {
        return payment;
      }
    }
    return null;
  }

  bool _isValidDecision(
    Payment previous,
    Payment decided,
    PaymentDecision requestedDecision,
  ) {
    final PaymentStatus expectedStatus = switch (requestedDecision) {
      PaymentDecision.approve => PaymentStatus.approved,
      PaymentDecision.reject => PaymentStatus.rejected,
    };
    return decided.id == previous.id &&
        decided.counterparty == previous.counterparty &&
        PaymentMoney.equivalent(decided.amount, previous.amount) &&
        decided.reference == previous.reference &&
        decided.createdAt == previous.createdAt &&
        decided.status == expectedStatus &&
        decided.decidedAt != null;
  }

  PaymentsResult<_Projection> _project(List<Payment> payments) {
    final Set<String> ids = <String>{};
    int pendingCount = 0;
    for (final Payment payment in payments) {
      final InvalidPaymentFailure? failure = payment.validate();
      if (failure != null) {
        return PaymentsError<_Projection>(failure);
      }
      if (!ids.add(payment.id)) {
        return const PaymentsError<_Projection>(
          InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
        );
      }
      if (payment.status == PaymentStatus.pending && ++pendingCount > 1) {
        return const PaymentsError<_Projection>(DuplicateRequestFailure());
      }
    }
    final List<Payment> decided = _operations.decidedHistory(payments);
    final List<Payment> canonical = <Payment>[
      ...decided,
      ...payments.where(
        (Payment payment) => payment.status == PaymentStatus.pending,
      ),
    ];
    final DateTime now = _clock();
    final PaymentsResult<PaymentSummary> summary = _operations
        .tryCurrentMonthSummary(payments: canonical, now: now);
    return switch (summary) {
      PaymentsError<PaymentSummary>(:final failure) =>
        PaymentsError<_Projection>(failure),
      PaymentsSuccess<PaymentSummary>(:final value) =>
        PaymentsSuccess<_Projection>(
          _Projection(
            payments: canonical,
            summary: value,
            reportingPeriodStartUtc: _operations.currentMonthStartUtc(now),
          ),
        ),
    };
  }
}

final class _Projection {
  const _Projection({
    required this.payments,
    required this.summary,
    required this.reportingPeriodStartUtc,
  });

  final List<Payment> payments;
  final PaymentSummary summary;
  final DateTime reportingPeriodStartUtc;
}
