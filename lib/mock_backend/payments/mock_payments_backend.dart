import 'dart:async';

import 'package:mamo_payment_approval_challenge/mock_backend/payments/payments_backend_client.dart';
import 'package:mamo_payment_approval_challenge/mock_backend/payments/payments_backend_exception.dart';
import 'package:timezone/data/latest.dart' as time_zone_data;
import 'package:timezone/timezone.dart' as time_zone;

final class MockPaymentsBackend implements PaymentsBackendClient {
  factory MockPaymentsBackend({
    List<Map<String, Object?>>? initialRecords,
    DateTime Function()? clock,
    Duration operationDelay = _defaultOperationDelay,
    String reportingTimeZone = _defaultReportingTimeZone,
    String currency = _defaultCurrency,
    int simulatedFailureInterval = _defaultFailureInterval,
  }) {
    return MockPaymentsBackend._(
      initialRecords: initialRecords,
      clock: clock,
      operationDelay: operationDelay,
      reportingTimeZone: _validateReportingTimeZone(reportingTimeZone),
      currency: _validateCurrency(currency),
      simulatedFailureInterval: simulatedFailureInterval,
    );
  }

  MockPaymentsBackend._({
    required List<Map<String, Object?>>? initialRecords,
    required DateTime Function()? clock,
    required this.operationDelay,
    required this.reportingTimeZone,
    required this.currency,
    required this.simulatedFailureInterval,
  }) : assert(simulatedFailureInterval >= 0),
       clock = clock == null
           ? (() => DateTime.now().toUtc())
           : (() => clock().toUtc()),
       _records = initialRecords == null
           ? _demoSeed(
               now: (clock == null ? DateTime.now() : clock()).toUtc(),
               reportingTimeZone: reportingTimeZone,
               currency: currency,
             )
           : initialRecords.map(Map<String, Object?>.from).toList();

  static const Duration _defaultOperationDelay = Duration.zero;
  static const String _defaultReportingTimeZone = 'Asia/Dubai';
  static const String _defaultCurrency = 'AED';
  static const int _defaultFailureInterval = 0;

  final DateTime Function() clock;
  final Duration operationDelay;
  @override
  final String reportingTimeZone;
  @override
  final String currency;
  final int simulatedFailureInterval;
  final List<Map<String, Object?>> _records;
  int _nextRequestSequence = 1;
  int _operationSequence = 0;

  @override
  Future<List<Map<String, Object?>>> loadPayments() async {
    await _beforeOperation();
    return _records.map(Map<String, Object?>.from).toList(growable: false);
  }

  @override
  Future<Map<String, Object?>> createPaymentRequest() async {
    await _beforeOperation();
    if (_records.any((record) => record['status'] == 'pending')) {
      throw const PaymentsBackendException(
        PaymentsBackendErrorCode.duplicateRequest,
      );
    }

    String id;
    do {
      id = 'request-${_nextRequestSequence.toString().padLeft(4, '0')}';
      _nextRequestSequence += 1;
    } while (_records.any((record) => record['id'] == id));

    final int requestIndex = _nextRequestSequence - 2;
    const List<double> amounts = <double>[125.75, 842.30, 2199.00];
    const List<String> counterparties = <String>[
      'Crescent Supplies',
      'Harbour Services',
      'Palm Trading',
    ];
    final Map<String, Object?> record = _record(
      id: id,
      counterparty: counterparties[requestIndex % counterparties.length],
      amount: amounts[requestIndex % amounts.length],
      currency: currency,
      reference: 'INV-${(requestIndex + 1).toString().padLeft(4, '0')}',
      createdAt: clock(),
      status: 'pending',
    );
    _records.add(record);
    return Map<String, Object?>.from(record);
  }

  @override
  Future<Map<String, Object?>> decidePayment({
    required String paymentId,
    required String decision,
  }) async {
    await _beforeOperation();
    final int index = _records.indexWhere(
      (record) => record['id'] == paymentId,
    );
    if (index < 0) {
      throw const PaymentsBackendException(
        PaymentsBackendErrorCode.paymentNotFound,
      );
    }
    final Map<String, Object?> existing = _records[index];
    if (existing['status'] != 'pending') {
      throw const PaymentsBackendException(
        PaymentsBackendErrorCode.paymentAlreadyDecided,
      );
    }
    final Map<String, Object?> decided = <String, Object?>{
      ...existing,
      'status': decision,
      'decidedAt': clock().toIso8601String(),
    };
    _records[index] = decided;
    return Map<String, Object?>.from(decided);
  }

  Future<void> _beforeOperation() async {
    if (operationDelay != Duration.zero) {
      await Future<void>.delayed(operationDelay);
    } else {
      await Future<void>.value();
    }
    if (simulatedFailureInterval == 0) {
      return;
    }
    _operationSequence += 1;
    if (_operationSequence % simulatedFailureInterval == 0) {
      throw const PaymentsBackendException(
        PaymentsBackendErrorCode.unavailable,
      );
    }
  }

  static List<Map<String, Object?>> _demoSeed({
    required DateTime now,
    required String reportingTimeZone,
    required String currency,
  }) {
    time_zone_data.initializeTimeZones();
    final time_zone.Location location = time_zone.getLocation(
      reportingTimeZone,
    );
    final time_zone.TZDateTime localNow = time_zone.TZDateTime.from(
      now,
      location,
    );
    final DateTime monthStart = time_zone.TZDateTime(
      location,
      localNow.year,
      localNow.month,
    ).toUtc();
    final DateTime currentDecision =
        now.isAfter(monthStart.add(const Duration(hours: 1)))
        ? now.subtract(const Duration(hours: 1))
        : now;
    final DateTime previousDecision = monthStart.subtract(
      const Duration(hours: 1),
    );
    return <Map<String, Object?>>[
      _record(
        id: 'seed-approved-current',
        counterparty: 'Atlas Office Supplies',
        amount: 1240.50,
        currency: currency,
        reference: 'PO-1042',
        createdAt: currentDecision.subtract(const Duration(days: 2)),
        status: 'approved',
        decidedAt: currentDecision,
      ),
      _record(
        id: 'seed-rejected-current',
        counterparty: 'Marina Logistics',
        amount: 315.25,
        currency: currency,
        reference: 'SHIP-778',
        createdAt: currentDecision.subtract(const Duration(days: 3)),
        status: 'rejected',
        decidedAt: currentDecision,
      ),
      _record(
        id: 'seed-approved-previous',
        counterparty: 'Desert Technology',
        amount: 89.90,
        currency: currency,
        reference: 'SUB-221',
        createdAt: previousDecision.subtract(const Duration(days: 1)),
        status: 'approved',
        decidedAt: previousDecision,
      ),
    ];
  }

  static String _validateReportingTimeZone(String value) {
    time_zone_data.initializeTimeZones();
    try {
      time_zone.getLocation(value);
    } on time_zone.LocationNotFoundException {
      throw ArgumentError.value(value, 'reportingTimeZone');
    }
    return value;
  }

  static String _validateCurrency(String value) {
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(value)) {
      throw ArgumentError.value(value, 'currency');
    }
    return value;
  }

  static Map<String, Object?> _record({
    required String id,
    required String counterparty,
    required double amount,
    required String currency,
    required String reference,
    required DateTime createdAt,
    required String status,
    DateTime? decidedAt,
  }) {
    return <String, Object?>{
      'id': id,
      'counterparty': counterparty,
      'amount': amount.toString(),
      'currency': currency,
      'reference': reference,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'decidedAt': decidedAt?.toIso8601String(),
    };
  }
}
