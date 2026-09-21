abstract interface class PaymentsBackendClient {
  String get reportingTimeZone;

  String get currency;

  Future<List<Map<String, Object?>>> loadPayments();

  /// Returns the decided records whose counterparty or reference contains
  /// [query] (case-insensitive) and whose status is one of [statuses]. An
  /// empty [statuses] list accepts every decided status. Pending requests are
  /// never returned because their details are masked until authentication.
  Future<List<Map<String, Object?>>> searchPayments({
    required String query,
    required List<String> statuses,
  });

  Future<Map<String, Object?>> createPaymentRequest();

  Future<Map<String, Object?>> decidePayment({
    required String paymentId,
    required String decision,
  });
}
