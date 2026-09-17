import 'dart:async';

import 'package:mamo_payment_approval_challenge/features/payments/data/payment_record_codec.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_operations.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';
import 'package:timezone/data/latest.dart' as time_zone_data;
import 'package:timezone/timezone.dart' as time_zone;

final class InMemoryPaymentsRepository implements PaymentsRepository {
  InMemoryPaymentsRepository({
    required List<Payment> initialPayments,
    required this.clock,
    this.operationDelay = Duration.zero,
    this.reportingTimeZone = 'Asia/Dubai',
  }) : _records = initialPayments
           .map(PaymentRecordCodec.encode)
           .map(Map<String, Object?>.from)
           .toList();

  InMemoryPaymentsRepository.fromRecords({
    required List<Map<String, Object?>> records,
    required this.clock,
    this.operationDelay = Duration.zero,
    this.reportingTimeZone = 'Asia/Dubai',
  }) : _records = records.map(Map<String, Object?>.from).toList();

  factory InMemoryPaymentsRepository.seeded({
    required DateTime Function() clock,
    Duration operationDelay = Duration.zero,
  }) {
    DateTime utcClock() => clock().toUtc();
    return InMemoryPaymentsRepository(
      initialPayments: _demoSeed(utcClock()),
      clock: utcClock,
      operationDelay: operationDelay,
    );
  }

  final DateTime Function() clock;
  final Duration operationDelay;
  final String reportingTimeZone;
  final List<Map<String, Object?>> _records;
  int _nextRequestSequence = 1;

  @override
  Future<PaymentsResult<Payment>> createRequest() async {
    await _delay();
    try {
      final PaymentsResult<List<Payment>> currentResult = _readAll();
      if (currentResult case PaymentsError<List<Payment>>(:final failure)) {
        return PaymentsError<Payment>(failure);
      }
      final List<Payment> current =
          (currentResult as PaymentsSuccess<List<Payment>>).value;
      if (current.any(
        (Payment payment) => payment.status == PaymentStatus.pending,
      )) {
        return const PaymentsError<Payment>(DuplicateRequestFailure());
      }

      String id;
      do {
        id = 'request-${_nextRequestSequence.toString().padLeft(4, '0')}';
        _nextRequestSequence += 1;
      } while (current.any((Payment payment) => payment.id == id));

      final int requestIndex = _nextRequestSequence - 2;
      final List<double> amounts = <double>[125.75, 842.30, 2199.00];
      final List<String> counterparties = <String>[
        'Crescent Supplies',
        'Harbour Services',
        'Palm Trading',
      ];
      final Payment payment = Payment(
        id: id,
        counterparty: counterparties[requestIndex % counterparties.length],
        amount: amounts[requestIndex % amounts.length],
        reference: 'INV-${(requestIndex + 1).toString().padLeft(4, '0')}',
        createdAt: clock().toUtc(),
        status: PaymentStatus.pending,
      );
      final InvalidPaymentFailure? failure = payment.validate();
      if (failure != null) {
        return PaymentsError<Payment>(failure);
      }
      _records.add(PaymentRecordCodec.encode(payment));
      return PaymentsSuccess<Payment>(payment);
    } on Exception {
      return const PaymentsError<Payment>(StorageFailure());
    }
  }

  @override
  Future<PaymentsResult<Payment>> decide({
    required String paymentId,
    required PaymentDecision decision,
  }) async {
    await _delay();
    try {
      final PaymentsResult<List<Payment>> currentResult = _readAll();
      if (currentResult case PaymentsError<List<Payment>>(:final failure)) {
        return PaymentsError<Payment>(failure);
      }
      final List<Payment> current =
          (currentResult as PaymentsSuccess<List<Payment>>).value;
      final int index = current.indexWhere(
        (Payment payment) => payment.id == paymentId,
      );
      if (index < 0) {
        return const PaymentsError<Payment>(PaymentNotFoundFailure());
      }
      final Payment existing = current[index];
      if (existing.status != PaymentStatus.pending) {
        return const PaymentsError<Payment>(PaymentAlreadyDecidedFailure());
      }
      final Payment decided = existing.copyWith(
        status: switch (decision) {
          PaymentDecision.approve => PaymentStatus.approved,
          PaymentDecision.reject => PaymentStatus.rejected,
        },
        decidedAt: clock().toUtc(),
      );
      final InvalidPaymentFailure? failure = decided.validate();
      if (failure != null) {
        return PaymentsError<Payment>(failure);
      }
      final List<Payment> updated = <Payment>[
        for (
          int paymentIndex = 0;
          paymentIndex < current.length;
          paymentIndex += 1
        )
          paymentIndex == index ? decided : current[paymentIndex],
      ];
      final PaymentsResult<PaymentSummary> summary = PaymentOperations(
        reportingTimeZone: reportingTimeZone,
      ).tryCurrentMonthSummary(payments: updated, now: decided.decidedAt!);
      if (summary case PaymentsError<PaymentSummary>(:final failure)) {
        return PaymentsError<Payment>(failure);
      }
      _records[index] = PaymentRecordCodec.encode(decided);
      return PaymentsSuccess<Payment>(decided);
    } on Exception {
      return const PaymentsError<Payment>(StorageFailure());
    }
  }

  @override
  Future<PaymentsResult<List<Payment>>> load() async {
    await _delay();
    try {
      return _readAll();
    } on Exception {
      return const PaymentsError<List<Payment>>(StorageFailure());
    }
  }

  Future<void> _delay() {
    if (operationDelay == Duration.zero) {
      return Future<void>.value();
    }
    return Future<void>.delayed(operationDelay);
  }

  PaymentsResult<List<Payment>> _readAll() {
    final List<Payment> payments = <Payment>[];
    final Set<String> ids = <String>{};
    int pendingCount = 0;
    for (final Map<String, Object?> record in _records) {
      final PaymentsResult<Payment> result = PaymentRecordCodec.decode(record);
      if (result case PaymentsError<Payment>(:final failure)) {
        return PaymentsError<List<Payment>>(failure);
      }
      final Payment payment = (result as PaymentsSuccess<Payment>).value;
      if (!ids.add(payment.id)) {
        return const PaymentsError<List<Payment>>(
          InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
        );
      }
      if (payment.status == PaymentStatus.pending) {
        pendingCount += 1;
        if (pendingCount > 1) {
          return const PaymentsError<List<Payment>>(
            InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
          );
        }
      }
      payments.add(payment);
    }
    return PaymentsSuccess<List<Payment>>(List<Payment>.unmodifiable(payments));
  }

  static List<Payment> _demoSeed(DateTime now) {
    time_zone_data.initializeTimeZones();
    final time_zone.Location location = time_zone.getLocation('Asia/Dubai');
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
    return <Payment>[
      Payment(
        id: 'seed-approved-current',
        counterparty: 'Atlas Office Supplies',
        amount: 1240.50,
        reference: 'PO-1042',
        createdAt: currentDecision.subtract(const Duration(days: 2)),
        status: PaymentStatus.approved,
        decidedAt: currentDecision,
      ),
      Payment(
        id: 'seed-rejected-current',
        counterparty: 'Marina Logistics',
        amount: 315.25,
        reference: 'SHIP-778',
        createdAt: currentDecision.subtract(const Duration(days: 3)),
        status: PaymentStatus.rejected,
        decidedAt: currentDecision,
      ),
      Payment(
        id: 'seed-approved-previous',
        counterparty: 'Desert Technology',
        amount: 89.90,
        reference: 'SUB-221',
        createdAt: previousDecision.subtract(const Duration(days: 1)),
        status: PaymentStatus.approved,
        decidedAt: previousDecision,
      ),
    ];
  }
}
