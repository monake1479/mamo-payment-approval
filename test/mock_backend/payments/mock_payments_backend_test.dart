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

    test('search matches visible fields case-insensitively', () async {
      final MockPaymentsBackend backend = MockPaymentsBackend(clock: () => now);

      final List<Map<String, Object?>> byCounterparty = await backend
          .searchPayments(
            sortBy: 'decidedAt',
            sortDirection: 'desc',
            query: '  atlas ',
            statuses: const <String>[],
          );
      final List<Map<String, Object?>> byReference = await backend
          .searchPayments(
            sortBy: 'decidedAt',
            sortDirection: 'desc',
            query: 'ship-7',
            statuses: const <String>[],
          );
      final List<Map<String, Object?>> none = await backend.searchPayments(
        sortBy: 'decidedAt',
        sortDirection: 'desc',
        query: 'nobody',
        statuses: const <String>[],
      );

      expect(byCounterparty.map((r) => r['id']), <String>[
        'seed-approved-current',
      ]);
      expect(byReference.map((r) => r['id']), <String>[
        'seed-rejected-current',
      ]);
      expect(none, isEmpty);
    });

    test(
      'search filters by decided status and never returns pending',
      () async {
        final MockPaymentsBackend backend = MockPaymentsBackend(
          initialRecords: const <Map<String, Object?>>[],
          clock: () => now,
        );
        final Map<String, Object?> pending = await backend
            .createPaymentRequest();
        expect(pending['status'], 'pending');

        final List<Map<String, Object?>> everything = await backend
            .searchPayments(
              sortBy: 'decidedAt',
              sortDirection: 'desc',
              query: '',
              statuses: const <String>[],
            );
        final List<Map<String, Object?>> pendingRequested = await backend
            .searchPayments(
              sortBy: 'decidedAt',
              sortDirection: 'desc',
              query: '',
              statuses: const <String>['pending'],
            );
        final List<Map<String, Object?>> byVisibleText = await backend
            .searchPayments(
              sortBy: 'decidedAt',
              sortDirection: 'desc',
              query: pending['counterparty']! as String,
              statuses: const <String>[],
            );
        expect(everything, isEmpty);
        expect(pendingRequested, isEmpty);
        expect(byVisibleText, isEmpty);

        await backend.decidePayment(
          paymentId: pending['id']! as String,
          decision: 'rejected',
        );
        final List<Map<String, Object?>> rejected = await backend
            .searchPayments(
              sortBy: 'decidedAt',
              sortDirection: 'desc',
              query: '',
              statuses: const <String>['rejected'],
            );
        final List<Map<String, Object?>> approved = await backend
            .searchPayments(
              sortBy: 'decidedAt',
              sortDirection: 'desc',
              query: '',
              statuses: const <String>['approved'],
            );
        expect(rejected.map((r) => r['id']), <Object?>[pending['id']]);
        expect(approved, isEmpty);
      },
    );

    test(
      'search orders results by the requested field and direction',
      () async {
        final MockPaymentsBackend backend = MockPaymentsBackend(
          clock: () => now,
        );
        Future<List<Object?>> idsSortedBy(
          String field,
          String direction,
        ) async {
          final List<Map<String, Object?>> records = await backend
              .searchPayments(
                query: '',
                statuses: const <String>[],
                sortBy: field,
                sortDirection: direction,
              );
          return records.map((r) => r['id']).toList(growable: false);
        }

        // Equal decision times fall back to the identifier.
        expect(await idsSortedBy('decidedAt', 'desc'), <String>[
          'seed-approved-current',
          'seed-rejected-current',
          'seed-approved-previous',
        ]);
        expect(await idsSortedBy('decidedAt', 'asc'), <String>[
          'seed-approved-previous',
          'seed-approved-current',
          'seed-rejected-current',
        ]);
        expect(await idsSortedBy('amount', 'asc'), <String>[
          'seed-approved-previous',
          'seed-rejected-current',
          'seed-approved-current',
        ]);
        expect(await idsSortedBy('counterparty', 'asc'), <String>[
          'seed-approved-current',
          'seed-approved-previous',
          'seed-rejected-current',
        ]);
        await expectLater(
          backend.searchPayments(
            query: '',
            statuses: const <String>[],
            sortBy: 'reference',
            sortDirection: 'asc',
          ),
          throwsArgumentError,
        );
      },
    );

    test('search returns copies of the authoritative records', () async {
      final MockPaymentsBackend backend = MockPaymentsBackend(clock: () => now);

      final List<Map<String, Object?>> results = await backend.searchPayments(
        sortBy: 'decidedAt',
        sortDirection: 'desc',
        query: '',
        statuses: const <String>[],
      );
      results.first['counterparty'] = 'Tampered';

      final List<Map<String, Object?>> reloaded = await backend.loadPayments();
      expect(
        reloaded.map((r) => r['counterparty']),
        isNot(contains('Tampered')),
      );
      expect(results, hasLength(3));
    });

    test('search shares the deterministic failure schedule', () async {
      final MockPaymentsBackend backend = MockPaymentsBackend(
        clock: () => now,
        simulatedFailureInterval: 2,
      );

      await backend.searchPayments(
        sortBy: 'decidedAt',
        sortDirection: 'desc',
        query: '',
        statuses: const <String>[],
      );
      await expectLater(
        backend.searchPayments(
          sortBy: 'decidedAt',
          sortDirection: 'desc',
          query: '',
          statuses: const <String>[],
        ),
        throwsA(_backendError(PaymentsBackendErrorCode.unavailable)),
      );
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
