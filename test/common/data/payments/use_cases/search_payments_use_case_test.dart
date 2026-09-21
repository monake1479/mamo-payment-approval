import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/data/payments/models/payments_date_range.dart';
import 'package:mamo_approval/common/data/payments/models/payments_search_criteria.dart';
import 'package:mamo_approval/common/data/payments/models/payments_sort.dart';
import 'package:mamo_approval/common/data/payments/use_cases/search_payments_use_case.dart';
import 'package:mamo_approval/common/result/models/result.dart';

import '../../../../support/payments_test_support.dart';

void main() {
  group('SearchPaymentsUseCase', () {
    test(
      'trims the query and forwards every other criterion untouched',
      () async {
        final Payment older = approvedPayment(
          id: 'b-older',
          decidedAt: DateTime.utc(2026, 9, 15, 8),
        );
        final Payment newest = rejectedPayment(
          id: 'z-newest',
          decidedAt: DateTime.utc(2026, 9, 17, 8),
        );
        final StubPaymentsRepository repository = StubPaymentsRepository(
          onLoad: () async =>
              const Success<PaymentsFailure, List<Payment>>(<Payment>[]),
          onSearch: (PaymentsSearchCriteria criteria) async =>
              Success<PaymentsFailure, List<Payment>>(<Payment>[older, newest]),
        );
        final PaymentsDateRange window = PaymentsDateRange(
          startUtc: DateTime.utc(2026, 9),
          endUtc: DateTime.utc(2026, 10),
        );
        const PaymentsSort byAmount = PaymentsSort(
          field: PaymentsSortField.amount,
          direction: SortDirection.ascending,
        );

        final Result<PaymentsFailure, List<Payment>> result =
            await SearchPaymentsUseCase(repository)(
              PaymentsSearchCriteria(
                query: '  po ',
                statuses: const <PaymentStatus>{PaymentStatus.approved},
                dateRange: window,
                sort: byAmount,
              ),
            );

        expect(repository.searches, <PaymentsSearchCriteria>[
          PaymentsSearchCriteria(
            query: 'po',
            statuses: const <PaymentStatus>{PaymentStatus.approved},
            dateRange: window,
            sort: byAmount,
          ),
        ]);
        // The backend owns filtering and ordering; the use case returns its
        // list untouched.
        final List<Payment> payments =
            (result as Success<PaymentsFailure, List<Payment>>).value;
        expect(payments.map((Payment payment) => payment.id), <String>[
          'b-older',
          'z-newest',
        ]);
      },
    );

    test('preserves the repository failure', () async {
      final StubPaymentsRepository repository = StubPaymentsRepository(
        onLoad: () async =>
            const Success<PaymentsFailure, List<Payment>>(<Payment>[]),
        onSearch: (PaymentsSearchCriteria criteria) async =>
            const Failure<PaymentsFailure, List<Payment>>(
              InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
            ),
      );

      final Result<PaymentsFailure, List<Payment>> result =
          await SearchPaymentsUseCase(repository)(
            const PaymentsSearchCriteria(query: 'x'),
          );

      expect(
        (result as Failure<PaymentsFailure, List<Payment>>).failure,
        const InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
      );
    });
  });
}
