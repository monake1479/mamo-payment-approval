import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/data/payments/models/payment_mutation.dart';
import 'package:mamo_approval/common/data/payments/models/payments_collection.dart';
import 'package:mamo_approval/common/data/payments/use_cases/create_payment_request_use_case.dart';
import 'package:mamo_approval/common/data/payments/use_cases/decide_payment_use_case.dart';
import 'package:mamo_approval/common/data/payments/use_cases/load_payments_use_case.dart';
import 'package:mamo_approval/common/data/payments/use_cases/refresh_payments_use_case.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:mamo_approval/common/result/models/unit.dart';
import 'package:mamo_approval/features/payments/states/payments/payments_state.dart';

final class PaymentsCubit extends Cubit<PaymentsState> {
  factory PaymentsCubit({
    required LoadPaymentsUseCase loadPayments,
    required CreatePaymentRequestUseCase createPaymentRequest,
    required DecidePaymentUseCase decidePayment,
    required RefreshPaymentsUseCase refreshPayments,
  }) {
    return PaymentsCubit._(
      loadPayments,
      createPaymentRequest,
      decidePayment,
      refreshPayments,
      refreshPayments.reportingTimeZone,
      refreshPayments.reportingCurrency,
      refreshPayments.currentPeriodStartUtc,
    );
  }

  PaymentsCubit._(
    this._loadPayments,
    this._createPaymentRequest,
    this._decidePayment,
    this._refreshPayments,
    String reportingTimeZone,
    String reportingCurrency,
    DateTime reportingPeriodStartUtc,
  ) : super(
        PaymentsState.initial(
          reportingTimeZone: reportingTimeZone,
          reportingCurrency: reportingCurrency,
          reportingPeriodStartUtc: reportingPeriodStartUtc,
        ),
      );

  final LoadPaymentsUseCase _loadPayments;
  final CreatePaymentRequestUseCase _createPaymentRequest;
  final DecidePaymentUseCase _decidePayment;
  final RefreshPaymentsUseCase _refreshPayments;
  int _latestLoad = 0;
  int _mutationVersion = 0;

  Future<Result<PaymentsFailure, Unit>> load() async {
    if (isClosed) {
      return const Failure<PaymentsFailure, Unit>(OperationCancelledFailure());
    }
    final int loadId = ++_latestLoad;
    final int startingMutationVersion = _mutationVersion;
    emit(state.copyWith(status: PaymentsLoadStatus.loading, failure: null));
    final Result<PaymentsFailure, PaymentsCollection> result =
        await _loadPayments();
    if (isClosed) {
      return const Failure<PaymentsFailure, Unit>(OperationCancelledFailure());
    }
    if (loadId != _latestLoad || startingMutationVersion != _mutationVersion) {
      return const Success<PaymentsFailure, Unit>(unit);
    }
    if (state.isCreatingRequest || state.decidingPaymentIds.isNotEmpty) {
      return const Success<PaymentsFailure, Unit>(unit);
    }
    return switch (result) {
      Failure<PaymentsFailure, PaymentsCollection>(:final failure) =>
        _loadFailed(failure),
      Success<PaymentsFailure, PaymentsCollection>(:final value) =>
        _loadSucceeded(value),
    };
  }

  Future<Result<PaymentsFailure, Payment>> createRequest() async {
    if (isClosed) {
      return const Failure<PaymentsFailure, Payment>(
        OperationCancelledFailure(),
      );
    }
    if (!state.hasLoaded) {
      return const Failure<PaymentsFailure, Payment>(PaymentBusyFailure());
    }
    if (state.isCreatingRequest) {
      return const Failure<PaymentsFailure, Payment>(PaymentBusyFailure());
    }
    _mutationVersion += 1;
    emit(state.copyWith(isCreatingRequest: true, failure: null));
    final Result<PaymentsFailure, PaymentMutation> result =
        await _createPaymentRequest(currentPayments: state.payments);
    if (isClosed) {
      return const Failure<PaymentsFailure, Payment>(
        OperationCancelledFailure(),
      );
    }
    return switch (result) {
      Failure<PaymentsFailure, PaymentMutation>(:final failure) =>
        _creationFailed(failure),
      Success<PaymentsFailure, PaymentMutation>(:final value) =>
        _creationSucceeded(value),
    };
  }

  Future<Result<PaymentsFailure, Payment>> decide({
    required String paymentId,
    required PaymentDecision decision,
  }) async {
    if (isClosed) {
      return const Failure<PaymentsFailure, Payment>(
        OperationCancelledFailure(),
      );
    }
    if (!state.hasLoaded) {
      return const Failure<PaymentsFailure, Payment>(PaymentBusyFailure());
    }
    if (state.decidingPaymentIds.contains(paymentId)) {
      return const Failure<PaymentsFailure, Payment>(PaymentBusyFailure());
    }
    _mutationVersion += 1;
    final Set<String> deciding = <String>{
      ...state.decidingPaymentIds,
      paymentId,
    };
    emit(state.copyWith(decidingPaymentIds: deciding, failure: null));
    final Result<PaymentsFailure, PaymentMutation> result =
        await _decidePayment(
          currentPayments: state.payments,
          paymentId: paymentId,
          decision: decision,
        );
    if (isClosed) {
      return const Failure<PaymentsFailure, Payment>(
        OperationCancelledFailure(),
      );
    }
    return switch (result) {
      Failure<PaymentsFailure, PaymentMutation>(:final failure) =>
        _decisionFailed(paymentId, failure),
      Success<PaymentsFailure, PaymentMutation>(:final value) =>
        _decisionSucceeded(paymentId, value),
    };
  }

  Result<PaymentsFailure, Unit> refreshDerivedState() {
    if (isClosed) {
      return const Failure<PaymentsFailure, Unit>(OperationCancelledFailure());
    }
    final Result<PaymentsFailure, PaymentsCollection> result = _refreshPayments(
      payments: state.payments,
    );
    if (result case Failure<PaymentsFailure, PaymentsCollection>(
      :final failure,
    )) {
      emit(state.copyWith(failure: failure));
      return Failure<PaymentsFailure, Unit>(failure);
    }
    _emitCollection(
      (result as Success<PaymentsFailure, PaymentsCollection>).value,
    );
    return const Success<PaymentsFailure, Unit>(unit);
  }

  Result<PaymentsFailure, Payment> _creationFailed(PaymentsFailure failure) {
    _mutationVersion += 1;
    emit(
      state.copyWith(
        status: PaymentsLoadStatus.success,
        failure: failure,
        isCreatingRequest: false,
      ),
    );
    return Failure<PaymentsFailure, Payment>(failure);
  }

  Result<PaymentsFailure, Payment> _creationSucceeded(
    PaymentMutation mutation,
  ) {
    _mutationVersion += 1;
    emit(
      state.copyWith(
        status: PaymentsLoadStatus.success,
        payments: mutation.collection.payments,
        summary: mutation.collection.summary,
        reportingPeriodStartUtc: mutation.collection.reportingPeriodStartUtc,
        reportingTimeZone: mutation.collection.reportingTimeZone,
        reportingCurrency: mutation.collection.reportingCurrency,
        failure: null,
        isCreatingRequest: false,
      ),
    );
    return Success<PaymentsFailure, Payment>(mutation.payment);
  }

  Result<PaymentsFailure, Payment> _decisionFailed(
    String paymentId,
    PaymentsFailure failure,
  ) {
    _mutationVersion += 1;
    final Set<String> deciding = <String>{...state.decidingPaymentIds}
      ..remove(paymentId);
    emit(
      state.copyWith(
        status: PaymentsLoadStatus.success,
        decidingPaymentIds: deciding,
        failure: failure,
      ),
    );
    return Failure<PaymentsFailure, Payment>(failure);
  }

  Result<PaymentsFailure, Payment> _decisionSucceeded(
    String paymentId,
    PaymentMutation mutation,
  ) {
    final Set<String> deciding = <String>{...state.decidingPaymentIds}
      ..remove(paymentId);
    _mutationVersion += 1;
    emit(
      state.copyWith(
        status: PaymentsLoadStatus.success,
        payments: mutation.collection.payments,
        summary: mutation.collection.summary,
        reportingPeriodStartUtc: mutation.collection.reportingPeriodStartUtc,
        reportingTimeZone: mutation.collection.reportingTimeZone,
        reportingCurrency: mutation.collection.reportingCurrency,
        failure: null,
        decidingPaymentIds: deciding,
      ),
    );
    return Success<PaymentsFailure, Payment>(mutation.payment);
  }

  Result<PaymentsFailure, Unit> _loadFailed(PaymentsFailure failure) {
    emit(state.copyWith(status: PaymentsLoadStatus.failure, failure: failure));
    return Failure<PaymentsFailure, Unit>(failure);
  }

  Result<PaymentsFailure, Unit> _loadSucceeded(PaymentsCollection collection) {
    emit(
      state.copyWith(
        status: PaymentsLoadStatus.success,
        payments: collection.payments,
        summary: collection.summary,
        reportingPeriodStartUtc: collection.reportingPeriodStartUtc,
        reportingTimeZone: collection.reportingTimeZone,
        reportingCurrency: collection.reportingCurrency,
        hasLoaded: true,
        failure: null,
      ),
    );
    return const Success<PaymentsFailure, Unit>(unit);
  }

  void _emitCollection(PaymentsCollection collection) {
    emit(
      state.copyWith(
        payments: collection.payments,
        summary: collection.summary,
        reportingPeriodStartUtc: collection.reportingPeriodStartUtc,
        reportingTimeZone: collection.reportingTimeZone,
        reportingCurrency: collection.reportingCurrency,
      ),
    );
  }
}
