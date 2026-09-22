import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/data/payments/models/payments_search_criteria.dart';
import 'package:mamo_approval/common/data/payments/payments_repository.dart';
import 'package:mamo_approval/common/result/models/result.dart';

/// Finds decided payments for [PaymentsSearchCriteria]: a free-text query over
/// the visible counterparty/reference fields, an optional status set, an
/// optional decision-date window, and the requested order. The backend owns
/// filtering and ordering; this operation only normalises the query text.
@lazySingleton
class SearchPaymentsUseCase {
  const SearchPaymentsUseCase(this._repository);

  final PaymentsRepository _repository;

  Future<Result<PaymentsFailure, List<Payment>>> call(
    PaymentsSearchCriteria criteria,
  ) {
    return _repository.searchPayments(
      criteria.copyWith(query: criteria.query.trim()),
    );
  }
}
