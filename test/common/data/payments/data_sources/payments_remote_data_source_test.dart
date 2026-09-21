import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/common/data/payments/data_sources/payments_remote_data_source.dart';
import 'package:mamo_approval/common/data/payments/dtos/payment_dto.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/data/payments/models/payments_date_range.dart';
import 'package:mamo_approval/common/data/payments/models/payments_search_criteria.dart';
import 'package:mamo_approval/common/data/payments/models/payments_sort.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:mamo_approval/mock_backend/payments/payments_backend_client.dart';
import 'package:mamo_approval/mock_backend/payments/payments_backend_exception.dart';

import '../../../../support/payments_test_support.dart';

void main() {
  group('PaymentsRemoteDataSource.search', () {
    test('maps the criteria to transport parameters', () async {
      final _RecordingBackend backend = _RecordingBackend(
        records: <Map<String, Object?>>[
          PaymentDto.fromModel(approvedPayment()).toJson(),
        ],
      );
      final PaymentsRemoteDataSource dataSource = PaymentsRemoteDataSource(
        backend,
      );

      final Result<PaymentsFailure, List<Payment>> result = await dataSource
          .search(
            PaymentsSearchCriteria(
              query: 'atlas',
              statuses: const <PaymentStatus>{
                PaymentStatus.pending,
                PaymentStatus.approved,
              },
              dateRange: PaymentsDateRange(
                startUtc: DateTime.utc(2026, 9),
                endUtc: DateTime.utc(2026, 10),
              ),
              sort: const PaymentsSort(
                field: PaymentsSortField.amount,
                direction: SortDirection.ascending,
              ),
            ),
          );

      expect(backend.calls, <String>[
        'query=atlas statuses=[approved] sort=amount asc '
            'from=2026-09-01T00:00:00.000Z to=2026-10-01T00:00:00.000Z',
      ]);
      expect(
        (result as Success<PaymentsFailure, List<Payment>>).value.single.id,
        approvedPayment().id,
      );
    });

    test('omits the date bounds when no window is set', () async {
      final _RecordingBackend backend = _RecordingBackend();
      final PaymentsRemoteDataSource dataSource = PaymentsRemoteDataSource(
        backend,
      );

      await dataSource.search(const PaymentsSearchCriteria(query: 'x'));

      expect(backend.calls, <String>[
        'query=x statuses=[] sort=decidedAt desc from=null to=null',
      ]);
    });

    test('drops a pending record even if the backend returned one', () async {
      final _RecordingBackend backend = _RecordingBackend(
        records: <Map<String, Object?>>[
          PaymentDto.fromModel(rejectedPayment()).toJson(),
          PaymentDto.fromModel(pendingPayment()).toJson(),
        ],
      );
      final PaymentsRemoteDataSource dataSource = PaymentsRemoteDataSource(
        backend,
      );

      final Result<PaymentsFailure, List<Payment>> result = await dataSource
          .search(PaymentsSearchCriteria.none);

      final List<Payment> payments =
          (result as Success<PaymentsFailure, List<Payment>>).value;
      expect(payments.map((Payment payment) => payment.id), <String>[
        rejectedPayment().id,
      ]);
      expect(
        payments.any(
          (Payment payment) => payment.status == PaymentStatus.pending,
        ),
        isFalse,
      );
      expect(() => payments.add(approvedPayment()), throwsUnsupportedError);
    });

    test('maps backend exceptions to typed failures', () async {
      final _RecordingBackend backend = _RecordingBackend(
        error: const PaymentsBackendException(
          PaymentsBackendErrorCode.unavailable,
        ),
      );
      final PaymentsRemoteDataSource dataSource = PaymentsRemoteDataSource(
        backend,
      );

      final Result<PaymentsFailure, List<Payment>> result = await dataSource
          .search(const PaymentsSearchCriteria(query: 'x'));

      expect(
        (result as Failure<PaymentsFailure, List<Payment>>).failure,
        const PaymentsUnavailableFailure(),
      );
    });

    test('maps unexpected transport exceptions to unavailable', () async {
      final _RecordingBackend backend = _RecordingBackend(
        error: const FormatException('transport'),
      );
      final PaymentsRemoteDataSource dataSource = PaymentsRemoteDataSource(
        backend,
      );

      final Result<PaymentsFailure, List<Payment>> result = await dataSource
          .search(const PaymentsSearchCriteria(query: 'x'));

      expect(
        (result as Failure<PaymentsFailure, List<Payment>>).failure,
        const PaymentsUnavailableFailure(),
      );
    });

    test('rejects malformed search records as invalid payment data', () async {
      final _RecordingBackend backend = _RecordingBackend(
        records: <Map<String, Object?>>[
          <String, Object?>{'id': 'incomplete'},
        ],
      );
      final PaymentsRemoteDataSource dataSource = PaymentsRemoteDataSource(
        backend,
      );

      final Result<PaymentsFailure, List<Payment>> result = await dataSource
          .search(PaymentsSearchCriteria.none);

      expect(
        (result as Failure<PaymentsFailure, List<Payment>>).failure,
        const InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
      );
    });
  });
}

final class _RecordingBackend implements PaymentsBackendClient {
  _RecordingBackend({
    this.records = const <Map<String, Object?>>[],
    this.error,
  });

  final List<Map<String, Object?>> records;
  final Exception? error;
  final List<String> calls = <String>[];

  @override
  String get currency => 'AED';

  @override
  String get reportingTimeZone => 'Asia/Dubai';

  @override
  Future<List<Map<String, Object?>>> searchPayments({
    required String query,
    required List<String> statuses,
    required String sortBy,
    required String sortDirection,
    String? decidedFrom,
    String? decidedTo,
  }) async {
    calls.add(
      'query=$query statuses=$statuses sort=$sortBy $sortDirection '
      'from=$decidedFrom to=$decidedTo',
    );
    if (error != null) {
      throw error!;
    }
    return records;
  }

  @override
  Future<List<Map<String, Object?>>> loadPayments() =>
      throw UnimplementedError();

  @override
  Future<Map<String, Object?>> createPaymentRequest() =>
      throw UnimplementedError();

  @override
  Future<Map<String, Object?>> decidePayment({
    required String paymentId,
    required String decision,
  }) => throw UnimplementedError();
}
