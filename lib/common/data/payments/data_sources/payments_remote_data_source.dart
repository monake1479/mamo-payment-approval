import 'package:injectable/injectable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/dtos/payment_dto.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/mock_backend/payments/payments_backend_client.dart';
import 'package:mamo_payment_approval_challenge/mock_backend/payments/payments_backend_exception.dart';

@lazySingleton
final class PaymentsRemoteDataSource {
  const PaymentsRemoteDataSource(this._backendClient);

  final PaymentsBackendClient _backendClient;

  String get reportingTimeZone => _backendClient.reportingTimeZone;

  String get currency => _backendClient.currency;

  Future<Result<PaymentsFailure, List<Payment>>> load() async {
    try {
      final List<Map<String, Object?>> records = await _backendClient
          .loadPayments();
      return _decodeCollection(records);
    } on PaymentsBackendException catch (exception) {
      return Failure<PaymentsFailure, List<Payment>>(
        _mapBackendFailure(exception),
      );
    } on Exception {
      return const Failure<PaymentsFailure, List<Payment>>(
        PaymentsUnavailableFailure(),
      );
    }
  }

  Future<Result<PaymentsFailure, Payment>> createRequest() async {
    try {
      final Map<String, Object?> record = await _backendClient
          .createPaymentRequest();
      return _decode(record);
    } on PaymentsBackendException catch (exception) {
      return Failure<PaymentsFailure, Payment>(_mapBackendFailure(exception));
    } on Exception {
      return const Failure<PaymentsFailure, Payment>(
        PaymentsUnavailableFailure(),
      );
    }
  }

  Future<Result<PaymentsFailure, Payment>> decide({
    required String paymentId,
    required PaymentDecision decision,
  }) async {
    try {
      final Map<String, Object?> record = await _backendClient.decidePayment(
        paymentId: paymentId,
        decision: switch (decision) {
          PaymentDecision.approve => PaymentStatus.approved.name,
          PaymentDecision.reject => PaymentStatus.rejected.name,
        },
      );
      return _decode(record);
    } on PaymentsBackendException catch (exception) {
      return Failure<PaymentsFailure, Payment>(_mapBackendFailure(exception));
    } on Exception {
      return const Failure<PaymentsFailure, Payment>(
        PaymentsUnavailableFailure(),
      );
    }
  }

  static Result<PaymentsFailure, List<Payment>> _decodeCollection(
    List<Map<String, Object?>> records,
  ) {
    final List<Payment> payments = <Payment>[];
    final Set<String> ids = <String>{};
    int pendingCount = 0;
    for (final Map<String, Object?> record in records) {
      final Result<PaymentsFailure, Payment> result = _decode(record);
      if (result case Failure<PaymentsFailure, Payment>(:final failure)) {
        return Failure<PaymentsFailure, List<Payment>>(failure);
      }
      final Payment payment =
          (result as Success<PaymentsFailure, Payment>).value;
      if (!ids.add(payment.id)) {
        return _malformedCollection();
      }
      if (payment.status == PaymentStatus.pending && ++pendingCount > 1) {
        return _malformedCollection();
      }
      payments.add(payment);
    }
    return Success<PaymentsFailure, List<Payment>>(
      List<Payment>.unmodifiable(payments),
    );
  }

  static Result<PaymentsFailure, Payment> _decode(Map<String, Object?> record) {
    try {
      final PaymentDto dto = PaymentDto.fromJson(record);
      final InvalidPaymentFailure? failure = dto.validate();
      return failure == null
          ? Success<PaymentsFailure, Payment>(dto.toModel())
          : Failure<PaymentsFailure, Payment>(failure);
    } on FormatException {
      return _malformedPayment();
    } on CheckedFromJsonException {
      return _malformedPayment();
    }
  }

  static PaymentsFailure _mapBackendFailure(
    PaymentsBackendException exception,
  ) {
    return switch (exception.code) {
      PaymentsBackendErrorCode.duplicateRequest =>
        const DuplicateRequestFailure(),
      PaymentsBackendErrorCode.paymentNotFound =>
        const PaymentNotFoundFailure(),
      PaymentsBackendErrorCode.paymentAlreadyDecided =>
        const PaymentAlreadyDecidedFailure(),
      PaymentsBackendErrorCode.unavailable =>
        const PaymentsUnavailableFailure(),
    };
  }

  static Failure<PaymentsFailure, Payment> _malformedPayment() {
    return const Failure<PaymentsFailure, Payment>(
      InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
    );
  }

  static Failure<PaymentsFailure, List<Payment>> _malformedCollection() {
    return const Failure<PaymentsFailure, List<Payment>>(
      InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
    );
  }
}
