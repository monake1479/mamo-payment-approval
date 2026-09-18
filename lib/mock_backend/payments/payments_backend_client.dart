abstract interface class PaymentsBackendClient {
  String get reportingTimeZone;

  String get currency;

  Future<List<Map<String, Object?>>> loadPayments();

  Future<Map<String, Object?>> createPaymentRequest();

  Future<Map<String, Object?>> decidePayment({
    required String paymentId,
    required String decision,
  });
}
