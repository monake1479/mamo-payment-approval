import 'package:injectable/injectable.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment_mutation.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payments_collection.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';

@lazySingleton
class DecidePaymentUseCase {
  DecidePaymentUseCase(
    this._repository, {
    @ignoreParam DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final PaymentsRepository _repository;
  final DateTime Function() _clock;

  Future<Result<PaymentsFailure, PaymentMutation>> call({
    required List<Payment> currentPayments,
    required String paymentId,
    required PaymentDecision decision,
  }) async {
    final PaymentsCollection current = _project(currentPayments);
    final Payment? previous = current.paymentById(paymentId);
    if (previous == null) {
      return const Failure<PaymentsFailure, PaymentMutation>(
        PaymentNotFoundFailure(),
      );
    }
    if (previous.status != PaymentStatus.pending) {
      return const Failure<PaymentsFailure, PaymentMutation>(
        PaymentAlreadyDecidedFailure(),
      );
    }

    final PaymentStatus expectedStatus = switch (decision) {
      PaymentDecision.approve => PaymentStatus.approved,
      PaymentDecision.reject => PaymentStatus.rejected,
    };
    final Result<PaymentsFailure, Payment> result = await _repository.decide(
      paymentId: paymentId,
      decision: decision,
    );
    if (result case Failure<PaymentsFailure, Payment>(:final failure)) {
      return Failure<PaymentsFailure, PaymentMutation>(failure);
    }
    final Payment decided = (result as Success<PaymentsFailure, Payment>).value;
    if (!_isValidDecision(previous, decided, expectedStatus)) {
      return const Failure<PaymentsFailure, PaymentMutation>(
        InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
      );
    }
    return Success<PaymentsFailure, PaymentMutation>(
      PaymentMutation(
        payment: decided,
        collection: _project(_replace(current.payments, decided)),
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

  static List<Payment> _replace(List<Payment> payments, Payment replacement) {
    return <Payment>[
      for (final Payment payment in payments)
        payment.id == replacement.id ? replacement : payment,
    ];
  }

  static bool _isValidDecision(
    Payment previous,
    Payment decided,
    PaymentStatus expectedStatus,
  ) {
    final DateTime? decidedAt = decided.decidedAt;
    return decided.id == previous.id &&
        decided.counterparty == previous.counterparty &&
        decided.amount == previous.amount &&
        decided.currency == previous.currency &&
        decided.reference == previous.reference &&
        decided.createdAt == previous.createdAt &&
        decided.status == expectedStatus &&
        decidedAt != null &&
        decidedAt.isUtc &&
        !decidedAt.isBefore(decided.createdAt);
  }
}
