import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/data/payments/models/payments_sort.dart';
import 'package:mamo_approval/common/data/payments/payments_repository.dart';
import 'package:mamo_approval/common/result/models/result.dart';

/// Finds decided payments matching a free-text query over the visible
/// counterparty/reference fields and an optional status filter. The backend
/// returns them in the history order (newest decision first).
@lazySingleton
class SearchPaymentsUseCase {
  const SearchPaymentsUseCase(this._repository);

  final PaymentsRepository _repository;

  Future<Result<PaymentsFailure, List<Payment>>> call({
    required String query,
    required Set<PaymentStatus> statuses,
  }) {
    return _repository.searchPayments(
      query: query.trim(),
      statuses: statuses,
      sort: PaymentsSort.decidedAtNewestFirst,
    );
  }
}
