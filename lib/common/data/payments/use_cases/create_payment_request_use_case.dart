import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/data/payments/models/payment_mutation.dart';
import 'package:mamo_approval/common/data/payments/models/payments_collection.dart';
import 'package:mamo_approval/common/data/payments/payments_repository.dart';
import 'package:mamo_approval/common/result/models/result.dart';

@lazySingleton
class CreatePaymentRequestUseCase {
  CreatePaymentRequestUseCase(
    this._repository, {
    @ignoreParam DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final PaymentsRepository _repository;
  final DateTime Function() _clock;

  Future<Result<PaymentsFailure, PaymentMutation>> call({
    required List<Payment> currentPayments,
  }) async {
    final PaymentsCollection current = _project(currentPayments);
    if (current.activeRequest != null) {
      return const Failure<PaymentsFailure, PaymentMutation>(
        DuplicateRequestFailure(),
      );
    }

    final Result<PaymentsFailure, Payment> result = await _repository
        .createRequest();
    if (result case Failure<PaymentsFailure, Payment>(:final failure)) {
      return Failure<PaymentsFailure, PaymentMutation>(failure);
    }
    final Payment payment = (result as Success<PaymentsFailure, Payment>).value;
    final Payment? existing = current.paymentById(payment.id);
    if (payment.status != PaymentStatus.pending ||
        payment.currency != _repository.reportingCurrency ||
        (existing != null && existing != payment)) {
      return const Failure<PaymentsFailure, PaymentMutation>(
        InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
      );
    }

    return Success<PaymentsFailure, PaymentMutation>(
      PaymentMutation(
        payment: payment,
        collection: _project(
          existing == null
              ? <Payment>[...current.payments, payment]
              : current.payments,
        ),
      ),
    );
  }

  PaymentsCollection _project(Iterable<Payment> payments) {
    return PaymentsCollection.fromPayments(
      payments: payments,
      now: _clock(),
      reportingTimeZone: _repository.reportingTimeZone,
      reportingCurrency: _repository.reportingCurrency,
    );
  }
}
