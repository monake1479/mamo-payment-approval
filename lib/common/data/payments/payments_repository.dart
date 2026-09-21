import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/payments/data_sources/payments_remote_data_source.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/result/models/result.dart';

@lazySingleton
class PaymentsRepository {
  const PaymentsRepository(this._remoteDataSource);

  final PaymentsRemoteDataSource _remoteDataSource;

  String get reportingTimeZone => _remoteDataSource.reportingTimeZone;

  String get reportingCurrency => _remoteDataSource.currency;

  Future<Result<PaymentsFailure, List<Payment>>> load() =>
      _remoteDataSource.load();

  Future<Result<PaymentsFailure, Payment>> createRequest() =>
      _remoteDataSource.createRequest();

  Future<Result<PaymentsFailure, Payment>> decide({
    required String paymentId,
    required PaymentDecision decision,
  }) => _remoteDataSource.decide(paymentId: paymentId, decision: decision);
}
