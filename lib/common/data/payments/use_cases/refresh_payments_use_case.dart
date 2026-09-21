import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/data/payments/models/payments_collection.dart';
import 'package:mamo_approval/common/data/payments/payments_repository.dart';
import 'package:mamo_approval/common/result/models/result.dart';

@lazySingleton
class RefreshPaymentsUseCase {
  RefreshPaymentsUseCase(
    this._repository, {
    @ignoreParam DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final PaymentsRepository _repository;
  final DateTime Function() _clock;

  String get reportingTimeZone => _repository.reportingTimeZone;

  String get reportingCurrency => _repository.reportingCurrency;

  DateTime get currentPeriodStartUtc =>
      _project(const <Payment>[]).reportingPeriodStartUtc;

  Result<PaymentsFailure, PaymentsCollection> call({
    required List<Payment> payments,
  }) {
    return Success<PaymentsFailure, PaymentsCollection>(_project(payments));
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
