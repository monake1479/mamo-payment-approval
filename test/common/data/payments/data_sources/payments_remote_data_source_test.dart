import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/data_sources/payments_remote_data_source.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/dtos/payment_dto.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/mock_backend/payments/payments_backend_client.dart';
import 'package:mamo_payment_approval_challenge/mock_backend/payments/payments_backend_exception.dart';

import '../../../../support/payments_test_support.dart';

void main() {
  group('PaymentsRemoteDataSource.search', () {
    test(
      'forwards the query and only decided statuses to the backend',
      () async {
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
              query: 'atlas',
              statuses: const <PaymentStatus>{
                PaymentStatus.pending,
                PaymentStatus.approved,
              },
            );

        expect(backend.queries, <String>['atlas']);
        expect(backend.statuses, <List<String>>[
          <String>['approved'],
        ]);
        expect(
          (result as Success<PaymentsFailure, List<Payment>>).value.single.id,
          approvedPayment().id,
        );
      },
    );

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
          .search(query: '', statuses: const <PaymentStatus>{});

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
          .search(query: 'x', statuses: const <PaymentStatus>{});

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
          .search(query: 'x', statuses: const <PaymentStatus>{});

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
          .search(query: '', statuses: const <PaymentStatus>{});

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
  final List<String> queries = <String>[];
  final List<List<String>> statuses = <List<String>>[];

  @override
  String get currency => 'AED';

  @override
  String get reportingTimeZone => 'Asia/Dubai';

  @override
  Future<List<Map<String, Object?>>> searchPayments({
    required String query,
    required List<String> statuses,
  }) async {
    queries.add(query);
    this.statuses.add(statuses);
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
