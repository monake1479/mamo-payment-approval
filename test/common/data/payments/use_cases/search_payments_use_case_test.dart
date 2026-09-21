import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/search_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';

import '../../../../support/payments_test_support.dart';

void main() {
  group('SearchPaymentsUseCase', () {
    test(
      'trims the query, forwards statuses, and orders newest first',
      () async {
        final Payment older = approvedPayment(
          id: 'b-older',
          decidedAt: DateTime.utc(2026, 9, 15, 8),
        );
        final Payment newest = rejectedPayment(
          id: 'z-newest',
          decidedAt: DateTime.utc(2026, 9, 17, 8),
        );
        final Payment tieLater = approvedPayment(
          id: 'a-tie',
          decidedAt: DateTime.utc(2026, 9, 17, 8),
        );
        final StubPaymentsRepository repository = StubPaymentsRepository(
          onLoad: () async =>
              const Success<PaymentsFailure, List<Payment>>(<Payment>[]),
          onSearch: (String query, Set<PaymentStatus> statuses) async =>
              Success<PaymentsFailure, List<Payment>>(<Payment>[
                older,
                newest,
                tieLater,
              ]),
        );

        final Result<PaymentsFailure, List<Payment>> result =
            await SearchPaymentsUseCase(repository)(
              query: '  po ',
              statuses: const <PaymentStatus>{PaymentStatus.approved},
            );

        expect(repository.searchQueries, <String>['po']);
        expect(repository.searchStatuses, <Set<PaymentStatus>>[
          <PaymentStatus>{PaymentStatus.approved},
        ]);
        final List<Payment> payments =
            (result as Success<PaymentsFailure, List<Payment>>).value;
        expect(payments.map((Payment payment) => payment.id), <String>[
          'a-tie',
          'z-newest',
          'b-older',
        ]);
        expect(() => payments.clear(), throwsUnsupportedError);
      },
    );

    test('preserves the repository failure', () async {
      final StubPaymentsRepository repository = StubPaymentsRepository(
        onLoad: () async =>
            const Success<PaymentsFailure, List<Payment>>(<Payment>[]),
        onSearch: (String query, Set<PaymentStatus> statuses) async =>
            const Failure<PaymentsFailure, List<Payment>>(
              InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
            ),
      );

      final Result<PaymentsFailure, List<Payment>> result =
          await SearchPaymentsUseCase(repository)(
            query: 'x',
            statuses: const <PaymentStatus>{},
          );

      expect(
        (result as Failure<PaymentsFailure, List<Payment>>).failure,
        const InvalidPaymentFailure(InvalidPaymentReason.malformedRecord),
      );
    });
  });
}
