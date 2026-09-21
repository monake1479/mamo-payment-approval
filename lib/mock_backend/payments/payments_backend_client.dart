abstract interface class PaymentsBackendClient {
  String get reportingTimeZone;

  String get currency;

  Future<List<Map<String, Object?>>> loadPayments();

  /// Returns the decided records whose counterparty or reference contains
  /// [query] (case-insensitive), whose status is one of [statuses], and whose
  /// decision time lies in `[decidedFrom, decidedTo)` (ISO 8601 UTC, either
  /// bound optional), ordered by [sortBy] (`decidedAt`, `createdAt`, `amount`,
  /// or `counterparty`) in [sortDirection] (`asc` or `desc`) with the
  /// identifier as tie-breaker. An empty [statuses] list accepts every decided
  /// status. Pending requests are never returned because their details are
  /// masked until authentication.
  Future<List<Map<String, Object?>>> searchPayments({
    required String query,
    required List<String> statuses,
    required String sortBy,
    required String sortDirection,
    String? decidedFrom,
    String? decidedTo,
  });

  Future<Map<String, Object?>> createPaymentRequest();

  Future<Map<String, Object?>> decidePayment({
    required String paymentId,
    required String decision,
  });
}
