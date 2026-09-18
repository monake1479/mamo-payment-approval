enum PaymentsBackendErrorCode {
  duplicateRequest,
  paymentNotFound,
  paymentAlreadyDecided,
  unavailable,
}

final class PaymentsBackendException implements Exception {
  const PaymentsBackendException(this.code);

  final PaymentsBackendErrorCode code;
}
