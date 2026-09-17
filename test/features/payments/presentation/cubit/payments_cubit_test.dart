import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_operations.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_result.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/payments_cubit.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 9, 17, 8);

  PaymentsCubit buildCubit(_FakePaymentsRepository repository) {
    return PaymentsCubit(
      repository: repository,
      operations: PaymentOperations(reportingTimeZone: 'Asia/Dubai'),
      clock: () => now,
    );
  }

  group('PaymentsCubit', () {
    test(
      'loads one canonical ordered collection and approved-only summary',
      () async {
        final _FakePaymentsRepository repository = _FakePaymentsRepository();
        repository.loadHandler = () async =>
            PaymentsSuccess<List<Payment>>(<Payment>[
              _payment(
                id: 'rejected',
                status: PaymentStatus.rejected,
                decidedAt: DateTime.utc(2026, 9, 16),
              ),
              _payment(id: 'pending', status: PaymentStatus.pending),
              _payment(
                id: 'approved',
                amount: 20.25,
                status: PaymentStatus.approved,
                decidedAt: DateTime.utc(2026, 9, 17),
              ),
            ]);
        final PaymentsCubit cubit = buildCubit(repository);
        addTearDown(cubit.close);

        final PaymentsResult<void> result = await cubit.load();

        expect(result, isA<PaymentsSuccess<void>>());
        expect(cubit.state.status, PaymentsLoadStatus.success);
        expect(
          cubit.state.decidedPayments.map((Payment payment) => payment.id),
          <String>['approved', 'rejected'],
        );
        expect(cubit.state.activeRequest?.id, 'pending');
        expect(
          cubit.state.summary,
          const PaymentSummary(approvedAmount: 20.25, approvedCount: 1),
        );
        expect(cubit.state.reportingTimeZone, 'Asia/Dubai');
      },
    );

    test('ignores a stale load after request creation mutates state', () async {
      final Completer<PaymentsResult<List<Payment>>> loadCompleter =
          Completer<PaymentsResult<List<Payment>>>();
      final Payment request = _payment(
        id: 'request',
        status: PaymentStatus.pending,
      );
      final _FakePaymentsRepository repository = _FakePaymentsRepository()
        ..createHandler = (() async => PaymentsSuccess<Payment>(request));
      final PaymentsCubit cubit = buildCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();
      repository.loadHandler = () => loadCompleter.future;

      final Future<PaymentsResult<void>> pendingLoad = cubit.load();
      final PaymentsResult<Payment> creation = await cubit.createRequest();
      loadCompleter.complete(
        PaymentsSuccess<List<Payment>>(<Payment>[
          _payment(
            id: 'stale',
            status: PaymentStatus.approved,
            decidedAt: DateTime.utc(2026, 9),
          ),
        ]),
      );
      await pendingLoad;

      expect(creation, isA<PaymentsSuccess<Payment>>());
      expect(cubit.state.activeRequest, request);
      expect(
        cubit.state.payments,
        isNot(
          contains(
            _payment(
              id: 'stale',
              status: PaymentStatus.approved,
              decidedAt: DateTime.utc(2026, 9),
            ),
          ),
        ),
      );
    });

    test('only the latest overlapping load may replace state', () async {
      final Completer<PaymentsResult<List<Payment>>> first =
          Completer<PaymentsResult<List<Payment>>>();
      final Completer<PaymentsResult<List<Payment>>> second =
          Completer<PaymentsResult<List<Payment>>>();
      final List<Completer<PaymentsResult<List<Payment>>>> loads =
          <Completer<PaymentsResult<List<Payment>>>>[first, second];
      final _FakePaymentsRepository repository = _FakePaymentsRepository()
        ..loadHandler = () => loads.removeAt(0).future;
      final PaymentsCubit cubit = buildCubit(repository);
      addTearDown(cubit.close);

      final Future<PaymentsResult<void>> firstLoad = cubit.load();
      final Future<PaymentsResult<void>> secondLoad = cubit.load();
      final Payment latest = _payment(
        id: 'latest',
        status: PaymentStatus.approved,
        decidedAt: DateTime.utc(2026, 9, 17),
      );
      second.complete(PaymentsSuccess<List<Payment>>(<Payment>[latest]));
      await secondLoad;
      first.complete(
        PaymentsSuccess<List<Payment>>(<Payment>[
          _payment(
            id: 'old',
            status: PaymentStatus.approved,
            decidedAt: DateTime.utc(2026, 9),
          ),
        ]),
      );
      await firstLoad;

      expect(cubit.state.payments, <Payment>[latest]);
    });

    test(
      'blocks duplicate request creation while in flight and after success',
      () async {
        final Completer<PaymentsResult<Payment>> completer =
            Completer<PaymentsResult<Payment>>();
        final Payment request = _payment(
          id: 'request',
          status: PaymentStatus.pending,
        );
        final _FakePaymentsRepository repository = _FakePaymentsRepository()
          ..createHandler = () => completer.future;
        final PaymentsCubit cubit = buildCubit(repository);
        addTearDown(cubit.close);
        await cubit.load();

        bool canonicalWhenReturned = false;
        final Future<PaymentsResult<Payment>> first = cubit
            .createRequest()
            .then((PaymentsResult<Payment> result) {
              canonicalWhenReturned = cubit.state.activeRequest == request;
              return result;
            });
        final PaymentsResult<Payment> inFlightDuplicate = await cubit
            .createRequest();
        completer.complete(PaymentsSuccess<Payment>(request));
        final PaymentsResult<Payment> created = await first;
        final PaymentsResult<Payment> activeDuplicate = await cubit
            .createRequest();

        expect(repository.createCalls, 1);
        expect(
          (inFlightDuplicate as PaymentsError<Payment>).failure,
          const PaymentBusyFailure(),
        );
        expect(created, isA<PaymentsSuccess<Payment>>());
        expect(cubit.state.activeRequest, request);
        expect(canonicalWhenReturned, isTrue);
        expect(
          (activeDuplicate as PaymentsError<Payment>).failure,
          const DuplicateRequestFailure(),
        );
      },
    );

    test(
      'accepts create success already observed by an overlapping load',
      () async {
        final Payment request = _payment(
          id: 'request',
          status: PaymentStatus.pending,
        );
        final Completer<PaymentsResult<Payment>> creationCompleter =
            Completer<PaymentsResult<Payment>>();
        final _FakePaymentsRepository repository = _FakePaymentsRepository()
          ..createHandler = (() => creationCompleter.future);
        final PaymentsCubit cubit = buildCubit(repository);
        addTearDown(cubit.close);
        await cubit.load();
        repository.loadHandler = () async =>
            PaymentsSuccess<List<Payment>>(<Payment>[request]);

        final Future<PaymentsResult<Payment>> creation = cubit.createRequest();
        await cubit.load();
        creationCompleter.complete(PaymentsSuccess<Payment>(request));

        expect(await creation, isA<PaymentsSuccess<Payment>>());
        expect(cubit.state.payments, <Payment>[request]);
        expect(cubit.state.isCreatingRequest, isFalse);
      },
    );

    test(
      'blocks creation until initial load establishes canonical state',
      () async {
        final Completer<PaymentsResult<List<Payment>>> loadCompleter =
            Completer<PaymentsResult<List<Payment>>>();
        final Payment seeded = _payment(
          id: 'seeded',
          status: PaymentStatus.approved,
          decidedAt: DateTime.utc(2026, 9, 10),
        );
        final _FakePaymentsRepository repository = _FakePaymentsRepository()
          ..loadHandler = () => loadCompleter.future;
        final PaymentsCubit cubit = buildCubit(repository);
        addTearDown(cubit.close);

        final Future<PaymentsResult<void>> load = cubit.load();
        final PaymentsResult<Payment> creation = await cubit.createRequest();
        expect(cubit.state.canCreateRequest, isFalse);
        loadCompleter.complete(
          PaymentsSuccess<List<Payment>>(<Payment>[seeded]),
        );
        await load;

        expect(
          (creation as PaymentsError<Payment>).failure,
          const PaymentBusyFailure(),
        );
        expect(repository.createCalls, 0);
        expect(cubit.state.payments, <Payment>[seeded]);
        expect(cubit.state.hasLoaded, isTrue);
        expect(cubit.state.canCreateRequest, isTrue);
        expect(cubit.state.paymentById(seeded.id), seeded);
      },
    );

    test('updates canonical state before decision success returns', () async {
      final Payment pending = _payment(
        id: 'request',
        amount: 10.10,
        status: PaymentStatus.pending,
      );
      final Payment approved = pending.copyWith(
        status: PaymentStatus.approved,
        decidedAt: now,
      );
      final Completer<PaymentsResult<Payment>> completer =
          Completer<PaymentsResult<Payment>>();
      final _FakePaymentsRepository repository = _FakePaymentsRepository()
        ..loadHandler = (() async =>
            PaymentsSuccess<List<Payment>>(<Payment>[pending]))
        ..decideHandler = (({
          required String paymentId,
          required PaymentDecision decision,
        }) => completer.future);
      final PaymentsCubit cubit = buildCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();
      bool canonicalWhenReturned = false;

      final Future<PaymentsResult<Payment>> first = cubit
          .decide(paymentId: pending.id, decision: PaymentDecision.approve)
          .then((PaymentsResult<Payment> result) {
            canonicalWhenReturned =
                cubit.state.activeRequest == null &&
                cubit.state.decidedPayments.single == approved;
            return result;
          });
      final PaymentsResult<Payment> duplicate = await cubit.decide(
        paymentId: pending.id,
        decision: PaymentDecision.reject,
      );
      completer.complete(PaymentsSuccess<Payment>(approved));
      final PaymentsResult<Payment> result = await first;

      expect(repository.decideCalls, 1);
      expect(
        (duplicate as PaymentsError<Payment>).failure,
        const PaymentBusyFailure(),
      );
      expect(result, isA<PaymentsSuccess<Payment>>());
      expect(canonicalWhenReturned, isTrue);
      expect(
        cubit.state.summary,
        const PaymentSummary(approvedAmount: 10.10, approvedCount: 1),
      );
    });

    test(
      'ignores a load during decision and preserves the full collection',
      () async {
        final Payment history = _payment(
          id: 'history',
          status: PaymentStatus.approved,
          decidedAt: DateTime.utc(2026, 8, 20),
        );
        final Payment pending = _payment(
          id: 'request',
          status: PaymentStatus.pending,
        );
        final Payment rejected = pending.copyWith(
          status: PaymentStatus.rejected,
          decidedAt: now,
        );
        final Completer<PaymentsResult<Payment>> decisionCompleter =
            Completer<PaymentsResult<Payment>>();
        final _FakePaymentsRepository repository = _FakePaymentsRepository()
          ..loadHandler = (() async =>
              PaymentsSuccess<List<Payment>>(<Payment>[history, pending]))
          ..decideHandler = (({
            required String paymentId,
            required PaymentDecision decision,
          }) => decisionCompleter.future);
        final PaymentsCubit cubit = buildCubit(repository);
        addTearDown(cubit.close);
        await cubit.load();

        final Future<PaymentsResult<Payment>> decision = cubit.decide(
          paymentId: pending.id,
          decision: PaymentDecision.reject,
        );
        repository.loadHandler = () async =>
            const PaymentsSuccess<List<Payment>>(<Payment>[]);
        await cubit.load();
        decisionCompleter.complete(PaymentsSuccess<Payment>(rejected));
        await decision;

        expect(cubit.state.paymentById(history.id), history);
        expect(cubit.state.paymentById(rejected.id), rejected);
        expect(cubit.state.decidedPayments, hasLength(2));
      },
    );

    test(
      'refreshes summary and reporting period from one injected instant',
      () async {
        DateTime mutableNow = DateTime.utc(2026, 9, 30, 19);
        final Payment september = _payment(
          id: 'september',
          amount: 2,
          status: PaymentStatus.approved,
          decidedAt: DateTime.utc(2026, 9, 30, 19),
        );
        final Payment october = _payment(
          id: 'october',
          amount: 3,
          status: PaymentStatus.approved,
          decidedAt: DateTime.utc(2026, 9, 30, 20),
        );
        final _FakePaymentsRepository repository = _FakePaymentsRepository()
          ..loadHandler = () async =>
              PaymentsSuccess<List<Payment>>(<Payment>[september, october]);
        final PaymentsCubit cubit = PaymentsCubit(
          repository: repository,
          operations: PaymentOperations(reportingTimeZone: 'Asia/Dubai'),
          clock: () => mutableNow,
        );
        addTearDown(cubit.close);
        await cubit.load();

        expect(cubit.state.summary.approvedAmount, 2);
        expect(
          cubit.state.reportingPeriodStartUtc,
          DateTime.utc(2026, 8, 31, 20),
        );

        mutableNow = DateTime.utc(2026, 9, 30, 21);
        final PaymentsResult<void> result = cubit.refreshDerivedState();

        expect(result, isA<PaymentsSuccess<void>>());
        expect(cubit.state.summary.approvedAmount, 3);
        expect(
          cubit.state.reportingPeriodStartUtc,
          DateTime.utc(2026, 9, 30, 20),
        );
      },
    );

    test('preserves canonical data when loads and writes fail', () async {
      final Payment pending = _payment(
        id: 'request',
        status: PaymentStatus.pending,
      );
      final _FakePaymentsRepository repository = _FakePaymentsRepository()
        ..loadHandler = () async =>
            PaymentsSuccess<List<Payment>>(<Payment>[pending]);
      final PaymentsCubit cubit = buildCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();
      final List<Payment> canonical = cubit.state.payments;

      repository.loadHandler = () async =>
          const PaymentsError<List<Payment>>(StorageFailure());
      await cubit.load();
      expect(cubit.state.payments, canonical);
      expect(cubit.state.status, PaymentsLoadStatus.failure);
      expect(cubit.state.failure, const StorageFailure());

      repository.decideHandler = ({
        required String paymentId,
        required PaymentDecision decision,
      }) async => const PaymentsError<Payment>(StorageFailure());
      await cubit.decide(
        paymentId: pending.id,
        decision: PaymentDecision.reject,
      );
      expect(cubit.state.payments, canonical);
      expect(cubit.state.activeRequest, pending);
      expect(cubit.state.failure, const StorageFailure());
    });

    test('preserves decided history when request creation fails', () async {
      final Payment decided = _payment(
        id: 'decided',
        status: PaymentStatus.approved,
        decidedAt: now,
      );
      final _FakePaymentsRepository repository = _FakePaymentsRepository()
        ..loadHandler = (() async =>
            PaymentsSuccess<List<Payment>>(<Payment>[decided]))
        ..createHandler = (() async =>
            const PaymentsError<Payment>(StorageFailure()));
      final PaymentsCubit cubit = buildCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();

      final PaymentsResult<Payment> result = await cubit.createRequest();

      expect(
        (result as PaymentsError<Payment>).failure,
        const StorageFailure(),
      );
      expect(cubit.state.payments, <Payment>[decided]);
      expect(cubit.state.summary.approvedCount, 1);
      expect(cubit.state.failure, const StorageFailure());
    });

    test(
      'rejects a repository decision that differs from the request',
      () async {
        final Payment pending = _payment(
          id: 'request',
          status: PaymentStatus.pending,
        );
        final Payment wrongDecision = pending.copyWith(
          status: PaymentStatus.rejected,
          decidedAt: now,
        );
        final _FakePaymentsRepository repository = _FakePaymentsRepository()
          ..loadHandler = (() async =>
              PaymentsSuccess<List<Payment>>(<Payment>[pending]))
          ..decideHandler = (({
            required String paymentId,
            required PaymentDecision decision,
          }) async => PaymentsSuccess<Payment>(wrongDecision));
        final PaymentsCubit cubit = buildCubit(repository);
        addTearDown(cubit.close);
        await cubit.load();

        final PaymentsResult<Payment> result = await cubit.decide(
          paymentId: pending.id,
          decision: PaymentDecision.approve,
        );

        expect(result, isA<PaymentsError<Payment>>());
        expect(cubit.state.activeRequest, pending);
      },
    );

    test('ignores a load completion after disposal', () async {
      final Completer<PaymentsResult<List<Payment>>> completer =
          Completer<PaymentsResult<List<Payment>>>();
      final _FakePaymentsRepository repository = _FakePaymentsRepository()
        ..loadHandler = () => completer.future;
      final PaymentsCubit cubit = buildCubit(repository);

      final Future<PaymentsResult<void>> load = cubit.load();
      await cubit.close();
      completer.complete(const PaymentsSuccess<List<Payment>>(<Payment>[]));

      expect(
        (await load as PaymentsError<void>).failure,
        const StorageFailure(),
      );
    });
  });
}

Payment _payment({
  required String id,
  required PaymentStatus status,
  double amount = 1,
  DateTime? decidedAt,
}) {
  return Payment(
    id: id,
    counterparty: 'Counterparty',
    amount: amount,
    reference: 'Reference',
    createdAt: DateTime.utc(2026, 8),
    status: status,
    decidedAt: decidedAt,
  );
}

typedef _DecisionHandler = Future<PaymentsResult<Payment>> Function({
  required String paymentId,
  required PaymentDecision decision,
});

final class _FakePaymentsRepository implements PaymentsRepository {
  Future<PaymentsResult<List<Payment>>> Function() loadHandler = () async =>
      const PaymentsSuccess<List<Payment>>(<Payment>[]);
  Future<PaymentsResult<Payment>> Function() createHandler = () async =>
      const PaymentsError<Payment>(StorageFailure());
  _DecisionHandler decideHandler = ({
    required String paymentId,
    required PaymentDecision decision,
  }) async => const PaymentsError<Payment>(StorageFailure());

  int createCalls = 0;
  int decideCalls = 0;

  @override
  Future<PaymentsResult<Payment>> createRequest() {
    createCalls += 1;
    return createHandler();
  }

  @override
  Future<PaymentsResult<Payment>> decide({
    required String paymentId,
    required PaymentDecision decision,
  }) {
    decideCalls += 1;
    return decideHandler(paymentId: paymentId, decision: decision);
  }

  @override
  Future<PaymentsResult<List<Payment>>> load() => loadHandler();
}
