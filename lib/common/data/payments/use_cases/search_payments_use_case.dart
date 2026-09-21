import 'package:injectable/injectable.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/decided_payment_order.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';

/// Finds decided payments matching a free-text query over the visible
/// counterparty/reference fields and an optional status filter, returned in
/// the same newest-decision-first order as the history list.
@lazySingleton
class SearchPaymentsUseCase {
  const SearchPaymentsUseCase(this._repository);

  final PaymentsRepository _repository;

  Future<Result<PaymentsFailure, List<Payment>>> call({
    required String query,
    required Set<PaymentStatus> statuses,
  }) async {
    final Result<PaymentsFailure, List<Payment>> result = await _repository
        .searchPayments(query: query.trim(), statuses: statuses);
    return switch (result) {
      Failure<PaymentsFailure, List<Payment>>(:final failure) =>
        Failure<PaymentsFailure, List<Payment>>(failure),
      Success<PaymentsFailure, List<Payment>>(:final value) =>
        Success<PaymentsFailure, List<Payment>>(
          List<Payment>.unmodifiable(
            value.toList(growable: false)
              ..sort(DecidedPaymentOrder.newestFirst),
          ),
        ),
    };
  }
}
