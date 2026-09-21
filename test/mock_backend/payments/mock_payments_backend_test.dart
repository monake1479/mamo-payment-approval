import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/mock_backend/payments/mock_payments_backend.dart';
import 'package:mamo_approval/mock_backend/payments/payments_backend_exception.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 9, 17, 8);

  group('MockPaymentsBackend', () {
    test('returns deterministic transport-shaped records', () async {
      final MockPaymentsBackend first = MockPaymentsBackend(clock: () => now);
      final MockPaymentsBackend second = MockPaymentsBackend(clock: () => now);

      final List<Map<String, Object?>> firstRecords = await first
          .loadPayments();
      final List<Map<String, Object?>> secondRecords = await second
          .loadPayments();

      expect(firstRecords, secondRecords);
      expect(firstRecords, hasLength(3));
      expect(firstRecords.first['amount'], isA<String>());
      expect(firstRecords.first['currency'], 'AED');
      expect(firstRecords.first['createdAt'], endsWith('Z'));
    });

    test('owns duplicate and final-decision backend guarantees', () async {
      final MockPaymentsBackend backend = MockPaymentsBackend(
        initialRecords: const <Map<String, Object?>>[],
        clock: () => now,
      );
      final Map<String, Object?> request = await backend.createPaymentRequest();

      await expectLater(
        backend.createPaymentRequest(),
        throwsA(_backendError(PaymentsBackendErrorCode.duplicateRequest)),
      );
      final Map<String, Object?> approved = await backend.decidePayment(
        paymentId: request['id']! as String,
        decision: 'approved',
      );
      expect(approved['status'], 'approved');
      expect(approved['decidedAt'], now.toIso8601String());
      await expectLater(
        backend.decidePayment(
          paymentId: request['id']! as String,
          decision: 'rejected',
        ),
        throwsA(_backendError(PaymentsBackendErrorCode.paymentAlreadyDecided)),
      );
    });

    test('simulates failures at a deterministic request interval', () async {
      final MockPaymentsBackend backend = MockPaymentsBackend(
        clock: () => now,
        simulatedFailureInterval: 2,
      );

      await backend.loadPayments();
      await expectLater(
        backend.loadPayments(),
        throwsA(_backendError(PaymentsBackendErrorCode.unavailable)),
      );
      expect(await backend.loadPayments(), hasLength(3));
    });

    test('owns and validates account reporting configuration', () {
      expect(
        () => MockPaymentsBackend(
          initialRecords: const <Map<String, Object?>>[],
          reportingTimeZone: 'Invalid/Zone',
        ),
        throwsArgumentError,
      );
      expect(
        () => MockPaymentsBackend(
          initialRecords: const <Map<String, Object?>>[],
          currency: 'aed',
        ),
        throwsArgumentError,
      );

      final MockPaymentsBackend backend = MockPaymentsBackend(
        initialRecords: const <Map<String, Object?>>[],
        reportingTimeZone: 'America/New_York',
        currency: 'USD',
      );

      expect(backend.reportingTimeZone, 'America/New_York');
      expect(backend.currency, 'USD');
    });
  });
}

Matcher _backendError(PaymentsBackendErrorCode code) {
  return isA<PaymentsBackendException>().having(
    (exception) => exception.code,
    'code',
    code,
  );
}
