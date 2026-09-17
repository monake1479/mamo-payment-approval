import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';

sealed class PaymentsResult<T> {
  const PaymentsResult();
}

final class PaymentsSuccess<T> extends PaymentsResult<T> {
  const PaymentsSuccess(this.value);

  final T value;
}

final class PaymentsError<T> extends PaymentsResult<T> {
  const PaymentsError(this.failure);

  final PaymentsFailure failure;
}
