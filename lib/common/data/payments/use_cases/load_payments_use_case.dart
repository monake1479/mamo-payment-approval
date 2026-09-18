import 'package:injectable/injectable.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payments_collection.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';

@lazySingleton
class LoadPaymentsUseCase {
  LoadPaymentsUseCase(
    this._repository, {
    @ignoreParam DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final PaymentsRepository _repository;
  final DateTime Function() _clock;

  Future<Result<PaymentsFailure, PaymentsCollection>> call() async {
    final Result<PaymentsFailure, List<Payment>> result = await _repository
        .load();
    return switch (result) {
      Failure<PaymentsFailure, List<Payment>>(:final failure) =>
        Failure<PaymentsFailure, PaymentsCollection>(failure),
      Success<PaymentsFailure, List<Payment>>(:final value) =>
        Success<PaymentsFailure, PaymentsCollection>(
          PaymentsCollection.fromPayments(
            payments: value,
            now: _clock(),
            reportingTimeZone: _repository.reportingTimeZone,
            reportingCurrency: _repository.reportingCurrency,
          ),
        ),
    };
  }
}
