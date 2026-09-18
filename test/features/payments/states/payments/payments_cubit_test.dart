import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/data_sources/payments_remote_data_source.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment_summary.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/create_payment_request_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/decide_payment_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/load_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/refresh_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/unit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_state.dart';
import 'package:mamo_payment_approval_challenge/mock_backend/payments/mock_payments_backend.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 9, 17, 8);

  PaymentsCubit buildCubit(_FakePaymentsRepository repository) {
    return PaymentsCubit(
      loadPayments: LoadPaymentsUseCase(repository, clock: () => now),
      createPaymentRequest: CreatePaymentRequestUseCase(
        repository,
        clock: () => now,
      ),
      decidePayment: DecidePaymentUseCase(repository, clock: () => now),
      refreshPayments: RefreshPaymentsUseCase(repository, clock: () => now),
    );
  }

  group('PaymentsCubit', () {
    test(
      'loads one canonical ordered collection and approved-only summary',
      () async {
        final _FakePaymentsRepository repository = _FakePaymentsRepository();
        repository.loadHandler = () async =>
            Success<PaymentsFailure, List<Payment>>(<Payment>[
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

        final Result<PaymentsFailure, Unit> result = await cubit.load();

        expect(result, isA<Success<PaymentsFailure, Unit>>());
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
        expect(cubit.state.reportingCurrency, 'AED');
      },
    );

    test('ignores a stale load after request creation mutates state', () async {
      final Completer<Result<PaymentsFailure, List<Payment>>> loadCompleter =
          Completer<Result<PaymentsFailure, List<Payment>>>();
      final Payment request = _payment(
        id: 'request',
        status: PaymentStatus.pending,
      );
      final _FakePaymentsRepository repository = _FakePaymentsRepository()
        ..createHandler = (() async =>
            Success<PaymentsFailure, Payment>(request));
      final PaymentsCubit cubit = buildCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();
      repository.loadHandler = () => loadCompleter.future;

      final Future<Result<PaymentsFailure, Unit>> pendingLoad = cubit.load();
      final Result<PaymentsFailure, Payment> creation = await cubit
          .createRequest();
      loadCompleter.complete(
        Success<PaymentsFailure, List<Payment>>(<Payment>[
          _payment(
            id: 'stale',
            status: PaymentStatus.approved,
            decidedAt: DateTime.utc(2026, 9),
          ),
        ]),
      );
      await pendingLoad;

      expect(creation, isA<Success<PaymentsFailure, Payment>>());
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

    test('does not let an older load clear a creation failure', () async {
      final Completer<Result<PaymentsFailure, List<Payment>>> loadCompleter =
          Completer<Result<PaymentsFailure, List<Payment>>>();
      final _FakePaymentsRepository repository = _FakePaymentsRepository()
        ..createHandler = () async => const Failure<PaymentsFailure, Payment>(
          PaymentsUnavailableFailure(),
        );
      final PaymentsCubit cubit = buildCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();
      repository.loadHandler = () => loadCompleter.future;

      final Future<Result<PaymentsFailure, Unit>> pendingLoad = cubit.load();
      await cubit.createRequest();
      loadCompleter.complete(
        const Success<PaymentsFailure, List<Payment>>(<Payment>[]),
      );
      await pendingLoad;

      expect(cubit.state.status, PaymentsLoadStatus.success);
      expect(cubit.state.failure, const PaymentsUnavailableFailure());
    });

    test('does not let an older load clear a decision failure', () async {
      final Payment pending = _payment(
        id: 'request',
        status: PaymentStatus.pending,
      );
      final Completer<Result<PaymentsFailure, List<Payment>>> loadCompleter =
          Completer<Result<PaymentsFailure, List<Payment>>>();
      final _FakePaymentsRepository repository = _FakePaymentsRepository()
        ..loadHandler = (() async =>
            Success<PaymentsFailure, List<Payment>>(<Payment>[pending]))
        ..decideHandler =
            ({
              required String paymentId,
              required PaymentDecision decision,
            }) async => const Failure<PaymentsFailure, Payment>(
              PaymentsUnavailableFailure(),
            );
      final PaymentsCubit cubit = buildCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();
      repository.loadHandler = () => loadCompleter.future;

      final Future<Result<PaymentsFailure, Unit>> pendingLoad = cubit.load();
      await cubit.decide(
        paymentId: pending.id,
        decision: PaymentDecision.reject,
      );
      loadCompleter.complete(
        Success<PaymentsFailure, List<Payment>>(<Payment>[pending]),
      );
      await pendingLoad;

      expect(cubit.state.status, PaymentsLoadStatus.success);
      expect(cubit.state.activeRequest, pending);
      expect(cubit.state.failure, const PaymentsUnavailableFailure());
    });

    test('only the latest overlapping load may replace state', () async {
      final Completer<Result<PaymentsFailure, List<Payment>>> first =
          Completer<Result<PaymentsFailure, List<Payment>>>();
      final Completer<Result<PaymentsFailure, List<Payment>>> second =
          Completer<Result<PaymentsFailure, List<Payment>>>();
      final List<Completer<Result<PaymentsFailure, List<Payment>>>> loads =
          <Completer<Result<PaymentsFailure, List<Payment>>>>[first, second];
      final _FakePaymentsRepository repository = _FakePaymentsRepository()
        ..loadHandler = () => loads.removeAt(0).future;
      final PaymentsCubit cubit = buildCubit(repository);
      addTearDown(cubit.close);

      final Future<Result<PaymentsFailure, Unit>> firstLoad = cubit.load();
      final Future<Result<PaymentsFailure, Unit>> secondLoad = cubit.load();
      final Payment latest = _payment(
        id: 'latest',
        status: PaymentStatus.approved,
        decidedAt: DateTime.utc(2026, 9, 17),
      );
      second.complete(
        Success<PaymentsFailure, List<Payment>>(<Payment>[latest]),
      );
      await secondLoad;
      first.complete(
        Success<PaymentsFailure, List<Payment>>(<Payment>[
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
        final Completer<Result<PaymentsFailure, Payment>> completer =
            Completer<Result<PaymentsFailure, Payment>>();
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
        final Future<Result<PaymentsFailure, Payment>> first = cubit
            .createRequest()
            .then((Result<PaymentsFailure, Payment> result) {
              canonicalWhenReturned = cubit.state.activeRequest == request;
              return result;
            });
        final Result<PaymentsFailure, Payment> inFlightDuplicate = await cubit
            .createRequest();
        completer.complete(Success<PaymentsFailure, Payment>(request));
        final Result<PaymentsFailure, Payment> created = await first;
        final Result<PaymentsFailure, Payment> activeDuplicate = await cubit
            .createRequest();

        expect(repository.createCalls, 1);
        expect(
          (inFlightDuplicate as Failure<PaymentsFailure, Payment>).failure,
          const PaymentBusyFailure(),
        );
        expect(created, isA<Success<PaymentsFailure, Payment>>());
        expect(cubit.state.activeRequest, request);
        expect(canonicalWhenReturned, isTrue);
        expect(
          (activeDuplicate as Failure<PaymentsFailure, Payment>).failure,
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
        final Completer<Result<PaymentsFailure, Payment>> creationCompleter =
            Completer<Result<PaymentsFailure, Payment>>();
        final _FakePaymentsRepository repository = _FakePaymentsRepository()
          ..createHandler = (() => creationCompleter.future);
        final PaymentsCubit cubit = buildCubit(repository);
        addTearDown(cubit.close);
        await cubit.load();
        repository.loadHandler = () async =>
            Success<PaymentsFailure, List<Payment>>(<Payment>[request]);

        final Future<Result<PaymentsFailure, Payment>> creation = cubit
            .createRequest();
        await cubit.load();
        creationCompleter.complete(Success<PaymentsFailure, Payment>(request));

        expect(await creation, isA<Success<PaymentsFailure, Payment>>());
        expect(cubit.state.payments, <Payment>[request]);
        expect(cubit.state.isCreatingRequest, isFalse);
      },
    );

    test(
      'blocks creation until initial load establishes canonical state',
      () async {
        final Completer<Result<PaymentsFailure, List<Payment>>> loadCompleter =
            Completer<Result<PaymentsFailure, List<Payment>>>();
        final Payment seeded = _payment(
          id: 'seeded',
          status: PaymentStatus.approved,
          decidedAt: DateTime.utc(2026, 9, 10),
        );
        final _FakePaymentsRepository repository = _FakePaymentsRepository()
          ..loadHandler = () => loadCompleter.future;
        final PaymentsCubit cubit = buildCubit(repository);
        addTearDown(cubit.close);

        final Future<Result<PaymentsFailure, Unit>> load = cubit.load();
        final Result<PaymentsFailure, Payment> creation = await cubit
            .createRequest();
        expect(cubit.state.canCreateRequest, isFalse);
        loadCompleter.complete(
          Success<PaymentsFailure, List<Payment>>(<Payment>[seeded]),
        );
        await load;

        expect(
          (creation as Failure<PaymentsFailure, Payment>).failure,
          const PaymentBusyFailure(),
        );
        expect(repository.createCalls, 0);
        expect(cubit.state.payments, <Payment>[seeded]);
        expect(cubit.state.hasLoaded, isTrue);
        expect(cubit.state.canCreateRequest, isTrue);
        expect(cubit.state.paymentById(seeded.id), seeded);
      },
    );

    test(
      'blocks decisions until initial load establishes canonical state',
      () async {
        final _FakePaymentsRepository repository = _FakePaymentsRepository();
        final PaymentsCubit cubit = buildCubit(repository);
        addTearDown(cubit.close);

        final Result<PaymentsFailure, Payment> result = await cubit.decide(
          paymentId: 'request',
          decision: PaymentDecision.reject,
        );

        expect(
          (result as Failure<PaymentsFailure, Payment>).failure,
          const PaymentBusyFailure(),
        );
        expect(repository.decideCalls, 0);
        expect(cubit.state.status, PaymentsLoadStatus.initial);
        expect(cubit.state.hasLoaded, isFalse);
        expect(cubit.state.failure, isNull);
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
      final Completer<Result<PaymentsFailure, Payment>> completer =
          Completer<Result<PaymentsFailure, Payment>>();
      final _FakePaymentsRepository repository = _FakePaymentsRepository()
        ..loadHandler = (() async =>
            Success<PaymentsFailure, List<Payment>>(<Payment>[pending]))
        ..decideHandler = (({
          required String paymentId,
          required PaymentDecision decision,
        }) => completer.future);
      final PaymentsCubit cubit = buildCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();
      bool canonicalWhenReturned = false;

      final Future<Result<PaymentsFailure, Payment>> first = cubit
          .decide(paymentId: pending.id, decision: PaymentDecision.approve)
          .then((Result<PaymentsFailure, Payment> result) {
            canonicalWhenReturned =
                cubit.state.activeRequest == null &&
                cubit.state.decidedPayments.single == approved;
            return result;
          });
      final Result<PaymentsFailure, Payment> duplicate = await cubit.decide(
        paymentId: pending.id,
        decision: PaymentDecision.reject,
      );
      completer.complete(Success<PaymentsFailure, Payment>(approved));
      final Result<PaymentsFailure, Payment> result = await first;

      expect(repository.decideCalls, 1);
      expect(
        (duplicate as Failure<PaymentsFailure, Payment>).failure,
        const PaymentBusyFailure(),
      );
      expect(result, isA<Success<PaymentsFailure, Payment>>());
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
        final Completer<Result<PaymentsFailure, Payment>> decisionCompleter =
            Completer<Result<PaymentsFailure, Payment>>();
        final _FakePaymentsRepository repository = _FakePaymentsRepository()
          ..loadHandler = (() async => Success<PaymentsFailure, List<Payment>>(
            <Payment>[history, pending],
          ))
          ..decideHandler = (({
            required String paymentId,
            required PaymentDecision decision,
          }) => decisionCompleter.future);
        final PaymentsCubit cubit = buildCubit(repository);
        addTearDown(cubit.close);
        await cubit.load();

        final Future<Result<PaymentsFailure, Payment>> decision = cubit.decide(
          paymentId: pending.id,
          decision: PaymentDecision.reject,
        );
        repository.loadHandler = () async =>
            const Success<PaymentsFailure, List<Payment>>(<Payment>[]);
        await cubit.load();
        decisionCompleter.complete(Success<PaymentsFailure, Payment>(rejected));
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
          ..loadHandler = () async => Success<PaymentsFailure, List<Payment>>(
            <Payment>[september, october],
          );
        final PaymentsCubit cubit = PaymentsCubit(
          loadPayments: LoadPaymentsUseCase(
            repository,
            clock: () => mutableNow,
          ),
          createPaymentRequest: CreatePaymentRequestUseCase(
            repository,
            clock: () => mutableNow,
          ),
          decidePayment: DecidePaymentUseCase(
            repository,
            clock: () => mutableNow,
          ),
          refreshPayments: RefreshPaymentsUseCase(
            repository,
            clock: () => mutableNow,
          ),
        );
        addTearDown(cubit.close);
        await cubit.load();

        expect(cubit.state.summary.approvedAmount, 2);
        expect(
          cubit.state.reportingPeriodStartUtc,
          DateTime.utc(2026, 8, 31, 20),
        );

        mutableNow = DateTime.utc(2026, 9, 30, 21);
        final Result<PaymentsFailure, Unit> result = cubit
            .refreshDerivedState();

        expect(result, isA<Success<PaymentsFailure, Unit>>());
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
            Success<PaymentsFailure, List<Payment>>(<Payment>[pending]);
      final PaymentsCubit cubit = buildCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();
      final List<Payment> canonical = cubit.state.payments;

      repository.loadHandler = () async =>
          const Failure<PaymentsFailure, List<Payment>>(
            PaymentsUnavailableFailure(),
          );
      await cubit.load();
      expect(cubit.state.payments, canonical);
      expect(cubit.state.status, PaymentsLoadStatus.failure);
      expect(cubit.state.failure, const PaymentsUnavailableFailure());

      repository.decideHandler =
          ({
            required String paymentId,
            required PaymentDecision decision,
          }) async => const Failure<PaymentsFailure, Payment>(
            PaymentsUnavailableFailure(),
          );
      await cubit.decide(
        paymentId: pending.id,
        decision: PaymentDecision.reject,
      );
      expect(cubit.state.payments, canonical);
      expect(cubit.state.activeRequest, pending);
      expect(cubit.state.failure, const PaymentsUnavailableFailure());
    });

    test('derived refresh preserves a failed reload state', () async {
      final Payment approved = _payment(
        id: 'approved',
        status: PaymentStatus.approved,
        decidedAt: now,
      );
      final _FakePaymentsRepository repository = _FakePaymentsRepository()
        ..loadHandler = () async =>
            Success<PaymentsFailure, List<Payment>>(<Payment>[approved]);
      final PaymentsCubit cubit = buildCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();
      repository.loadHandler = () async =>
          const Failure<PaymentsFailure, List<Payment>>(
            PaymentsUnavailableFailure(),
          );
      await cubit.load();

      final Result<PaymentsFailure, Unit> result = cubit.refreshDerivedState();

      expect(result, isA<Success<PaymentsFailure, Unit>>());
      expect(cubit.state.status, PaymentsLoadStatus.failure);
      expect(cubit.state.failure, const PaymentsUnavailableFailure());
      expect(cubit.state.payments, <Payment>[approved]);
    });

    test('preserves decided history when request creation fails', () async {
      final Payment decided = _payment(
        id: 'decided',
        status: PaymentStatus.approved,
        decidedAt: now,
      );
      final _FakePaymentsRepository repository = _FakePaymentsRepository()
        ..loadHandler = (() async =>
            Success<PaymentsFailure, List<Payment>>(<Payment>[decided]))
        ..createHandler = (() async => const Failure<PaymentsFailure, Payment>(
          PaymentsUnavailableFailure(),
        ));
      final PaymentsCubit cubit = buildCubit(repository);
      addTearDown(cubit.close);
      await cubit.load();

      final Result<PaymentsFailure, Payment> result = await cubit
          .createRequest();

      expect(
        (result as Failure<PaymentsFailure, Payment>).failure,
        const PaymentsUnavailableFailure(),
      );
      expect(cubit.state.payments, <Payment>[decided]);
      expect(cubit.state.summary.approvedCount, 1);
      expect(cubit.state.failure, const PaymentsUnavailableFailure());
    });

    test(
      'stores a use-case failure for a mismatched repository decision',
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
              Success<PaymentsFailure, List<Payment>>(<Payment>[pending]))
          ..decideHandler = (({
            required String paymentId,
            required PaymentDecision decision,
          }) async => Success<PaymentsFailure, Payment>(wrongDecision));
        final PaymentsCubit cubit = buildCubit(repository);
        addTearDown(cubit.close);
        await cubit.load();

        final Result<PaymentsFailure, Payment> result = await cubit.decide(
          paymentId: pending.id,
          decision: PaymentDecision.approve,
        );

        expect(result, isA<Failure<PaymentsFailure, Payment>>());
        expect(cubit.state.activeRequest, pending);
      },
    );

    test('ignores a load completion after disposal', () async {
      final Completer<Result<PaymentsFailure, List<Payment>>> completer =
          Completer<Result<PaymentsFailure, List<Payment>>>();
      final _FakePaymentsRepository repository = _FakePaymentsRepository()
        ..loadHandler = () => completer.future;
      final PaymentsCubit cubit = buildCubit(repository);

      final Future<Result<PaymentsFailure, Unit>> load = cubit.load();
      await cubit.close();
      completer.complete(
        const Success<PaymentsFailure, List<Payment>>(<Payment>[]),
      );

      expect(
        (await load as Failure<PaymentsFailure, Unit>).failure,
        const OperationCancelledFailure(),
      );
    });

    test(
      'returns cancellation when request creation completes after disposal',
      () async {
        final Payment request = _payment(
          id: 'request',
          status: PaymentStatus.pending,
        );
        final Completer<Result<PaymentsFailure, Payment>> completer =
            Completer<Result<PaymentsFailure, Payment>>();
        final _FakePaymentsRepository repository = _FakePaymentsRepository()
          ..createHandler = () => completer.future;
        final PaymentsCubit cubit = buildCubit(repository);
        await cubit.load();

        final Future<Result<PaymentsFailure, Payment>> creation = cubit
            .createRequest();
        await cubit.close();
        completer.complete(Success<PaymentsFailure, Payment>(request));

        expect(
          (await creation as Failure<PaymentsFailure, Payment>).failure,
          const OperationCancelledFailure(),
        );
      },
    );

    test(
      'returns cancellation when a decision completes after disposal',
      () async {
        final Payment pending = _payment(
          id: 'request',
          status: PaymentStatus.pending,
        );
        final Payment rejected = pending.copyWith(
          status: PaymentStatus.rejected,
          decidedAt: now,
        );
        final Completer<Result<PaymentsFailure, Payment>> completer =
            Completer<Result<PaymentsFailure, Payment>>();
        final _FakePaymentsRepository repository = _FakePaymentsRepository()
          ..loadHandler = (() async =>
              Success<PaymentsFailure, List<Payment>>(<Payment>[pending]))
          ..decideHandler = ({
            required String paymentId,
            required PaymentDecision decision,
          }) => completer.future;
        final PaymentsCubit cubit = buildCubit(repository);
        await cubit.load();

        final Future<Result<PaymentsFailure, Payment>> decision = cubit.decide(
          paymentId: pending.id,
          decision: PaymentDecision.reject,
        );
        await cubit.close();
        completer.complete(Success<PaymentsFailure, Payment>(rejected));

        expect(
          (await decision as Failure<PaymentsFailure, Payment>).failure,
          const OperationCancelledFailure(),
        );
      },
    );
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
    currency: 'AED',
    reference: 'Reference',
    createdAt: DateTime.utc(2026, 8),
    status: status,
    decidedAt: decidedAt,
  );
}

typedef _DecisionHandler = Future<Result<PaymentsFailure, Payment>> Function({
  required String paymentId,
  required PaymentDecision decision,
});

final class _FakePaymentsRepository extends PaymentsRepository {
  _FakePaymentsRepository()
    : super(
        PaymentsRemoteDataSource(
          MockPaymentsBackend(
            initialRecords: const <Map<String, Object?>>[],
            clock: () => DateTime.utc(2026, 9, 17, 8),
          ),
        ),
      );

  Future<Result<PaymentsFailure, List<Payment>>> Function() loadHandler =
      () async => const Success<PaymentsFailure, List<Payment>>(<Payment>[]);
  Future<Result<PaymentsFailure, Payment>> Function() createHandler =
      () async =>
          const Failure<PaymentsFailure, Payment>(PaymentsUnavailableFailure());
  _DecisionHandler decideHandler =
      ({required String paymentId, required PaymentDecision decision}) async =>
          const Failure<PaymentsFailure, Payment>(PaymentsUnavailableFailure());

  int createCalls = 0;
  int decideCalls = 0;

  @override
  Future<Result<PaymentsFailure, Payment>> createRequest() {
    createCalls += 1;
    return createHandler();
  }

  @override
  Future<Result<PaymentsFailure, Payment>> decide({
    required String paymentId,
    required PaymentDecision decision,
  }) {
    decideCalls += 1;
    return decideHandler(paymentId: paymentId, decision: decision);
  }

  @override
  Future<Result<PaymentsFailure, List<Payment>>> load() => loadHandler();
}
