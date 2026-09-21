import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/payments/data_sources/payments_remote_data_source.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/data/payments/models/payments_search_criteria.dart';
import 'package:mamo_approval/common/result/models/result.dart';

@lazySingleton
class PaymentsRepository {
  const PaymentsRepository(this._remoteDataSource);

  final PaymentsRemoteDataSource _remoteDataSource;

  String get reportingTimeZone => _remoteDataSource.reportingTimeZone;

  String get reportingCurrency => _remoteDataSource.currency;

  Future<Result<PaymentsFailure, List<Payment>>> load() =>
      _remoteDataSource.load();

  /// Decided-history search; typed failures come from the data source, which
  /// owns the backend exception mapping for every payment operation.
  Future<Result<PaymentsFailure, List<Payment>>> searchPayments(
    PaymentsSearchCriteria criteria,
  ) => _remoteDataSource.search(criteria);

  Future<Result<PaymentsFailure, Payment>> createRequest() =>
      _remoteDataSource.createRequest();

  Future<Result<PaymentsFailure, Payment>> decide({
    required String paymentId,
    required PaymentDecision decision,
  }) => _remoteDataSource.decide(paymentId: paymentId, decision: decision);
}
