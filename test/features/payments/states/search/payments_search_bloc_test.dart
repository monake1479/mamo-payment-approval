import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/data/payments/models/payments_date_range.dart';
import 'package:mamo_approval/common/data/payments/models/payments_search_criteria.dart';
import 'package:mamo_approval/common/data/payments/models/payments_sort.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_bloc.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_event.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_state.dart';

import '../../../../support/payments_test_support.dart';

void main() {
  final Payment approved = approvedPayment();
  final Payment rejected = rejectedPayment();
  const Set<PaymentStatus> approvedOnly = <PaymentStatus>{
    PaymentStatus.approved,
  };
  const PaymentsSearchCriteria approvedCriteria = PaymentsSearchCriteria(
    statuses: approvedOnly,
  );
  const PaymentsSort oldestFirst = PaymentsSort(
    field: PaymentsSortField.decidedAt,
    direction: SortDirection.ascending,
  );
  final PaymentsDateRange september = PaymentsDateRange(
    startUtc: DateTime.utc(2026, 9),
    endUtc: DateTime.utc(2026, 10),
  );

  StubPaymentsRepository repositoryReturning(
    Result<PaymentsFailure, List<Payment>> result,
  ) {
    return StubPaymentsRepository(
      onLoad: () async =>
          const Success<PaymentsFailure, List<Payment>>(<Payment>[]),
      onSearch: (PaymentsSearchCriteria criteria) async => result,
    );
  }

  group('PaymentsSearchBloc', () {
    late StubPaymentsRepository repository;

    blocTest<PaymentsSearchBloc, PaymentsSearchState>(
      'query edit moves through loading to results',
      setUp: () {
        repository = repositoryReturning(
          Success<PaymentsFailure, List<Payment>>(<Payment>[approved]),
        );
      },
      build: () => createPaymentsSearchBlocFromRepository(repository),
      act: (PaymentsSearchBloc bloc) =>
          bloc.add(const PaymentsSearchEvent.queryChanged('  Atlas ')),
      wait: Duration.zero,
      expect: () => <PaymentsSearchState>[
        const PaymentsSearchState.loading(
          criteria: PaymentsSearchCriteria(query: 'Atlas'),
        ),
        PaymentsSearchState.results(
          criteria: const PaymentsSearchCriteria(query: 'Atlas'),
          payments: <Payment>[approved],
        ),
      ],
      verify: (PaymentsSearchBloc _) {
        expect(repository.searches, <PaymentsSearchCriteria>[
          const PaymentsSearchCriteria(query: 'Atlas'),
        ]);
      },
    );

    blocTest<PaymentsSearchBloc, PaymentsSearchState>(
      'no match becomes the empty state',
      setUp: () {
        repository = repositoryReturning(
          const Success<PaymentsFailure, List<Payment>>(<Payment>[]),
        );
      },
      build: () => createPaymentsSearchBlocFromRepository(repository),
      act: (PaymentsSearchBloc bloc) =>
          bloc.add(const PaymentsSearchEvent.queryChanged('nobody')),
      wait: Duration.zero,
      expect: () => const <PaymentsSearchState>[
        PaymentsSearchState.loading(
          criteria: PaymentsSearchCriteria(query: 'nobody'),
        ),
        PaymentsSearchState.empty(
          criteria: PaymentsSearchCriteria(query: 'nobody'),
        ),
      ],
    );

    blocTest<PaymentsSearchBloc, PaymentsSearchState>(
      'typed failure becomes the error state and keeps the criteria',
      setUp: () {
        repository = repositoryReturning(
          const Failure<PaymentsFailure, List<Payment>>(
            PaymentsUnavailableFailure(),
          ),
        );
      },
      build: () => createPaymentsSearchBlocFromRepository(repository),
      act: (PaymentsSearchBloc bloc) =>
          bloc.add(const PaymentsSearchEvent.statusFilterChanged(approvedOnly)),
      expect: () => const <PaymentsSearchState>[
        PaymentsSearchState.loading(criteria: approvedCriteria),
        PaymentsSearchState.error(
          criteria: approvedCriteria,
          failure: PaymentsUnavailableFailure(),
        ),
      ],
    );

    blocTest<PaymentsSearchBloc, PaymentsSearchState>(
      'each criterion change keeps the others',
      setUp: () {
        repository = repositoryReturning(
          Success<PaymentsFailure, List<Payment>>(<Payment>[approved]),
        );
      },
      build: () => createPaymentsSearchBlocFromRepository(repository),
      act: (PaymentsSearchBloc bloc) async {
        bloc.add(const PaymentsSearchEvent.queryChanged('PO'));
        await pumpEventQueue();
        bloc.add(const PaymentsSearchEvent.statusFilterChanged(approvedOnly));
        await pumpEventQueue();
        bloc.add(PaymentsSearchEvent.dateRangeChanged(september));
        await pumpEventQueue();
        bloc.add(const PaymentsSearchEvent.sortChanged(oldestFirst));
        await pumpEventQueue();
        bloc.add(const PaymentsSearchEvent.queryChanged('PO-1'));
      },
      wait: Duration.zero,
      verify: (PaymentsSearchBloc bloc) {
        expect(repository.searches, <PaymentsSearchCriteria>[
          const PaymentsSearchCriteria(query: 'PO'),
          const PaymentsSearchCriteria(query: 'PO', statuses: approvedOnly),
          PaymentsSearchCriteria(
            query: 'PO',
            statuses: approvedOnly,
            dateRange: september,
          ),
          PaymentsSearchCriteria(
            query: 'PO',
            statuses: approvedOnly,
            dateRange: september,
            sort: oldestFirst,
          ),
          PaymentsSearchCriteria(
            query: 'PO-1',
            statuses: approvedOnly,
            dateRange: september,
            sort: oldestFirst,
          ),
        ]);
        expect(bloc.state.criteria.query, 'PO-1');
        expect(bloc.state.criteria.sort, oldestFirst);
      },
    );

    blocTest<PaymentsSearchBloc, PaymentsSearchState>(
      'a sort other than the history order is an active criterion',
      setUp: () {
        repository = repositoryReturning(
          Success<PaymentsFailure, List<Payment>>(<Payment>[
            rejected,
            approved,
          ]),
        );
      },
      build: () => createPaymentsSearchBlocFromRepository(repository),
      act: (PaymentsSearchBloc bloc) =>
          bloc.add(const PaymentsSearchEvent.sortChanged(oldestFirst)),
      expect: () => <PaymentsSearchState>[
        const PaymentsSearchState.loading(
          criteria: PaymentsSearchCriteria(sort: oldestFirst),
        ),
        PaymentsSearchState.results(
          criteria: const PaymentsSearchCriteria(sort: oldestFirst),
          payments: <Payment>[rejected, approved],
        ),
      ],
    );

    blocTest<PaymentsSearchBloc, PaymentsSearchState>(
      'restoring the history order with no other criterion returns to idle',
      setUp: () {
        repository = repositoryReturning(
          Success<PaymentsFailure, List<Payment>>(<Payment>[approved]),
        );
      },
      build: () => createPaymentsSearchBlocFromRepository(repository),
      seed: () => PaymentsSearchState.results(
        criteria: const PaymentsSearchCriteria(sort: oldestFirst),
        payments: <Payment>[approved],
      ),
      act: (PaymentsSearchBloc bloc) => bloc.add(
        const PaymentsSearchEvent.sortChanged(
          PaymentsSort.decidedAtNewestFirst,
        ),
      ),
      expect: () => const <PaymentsSearchState>[PaymentsSearchState.idle()],
      verify: (PaymentsSearchBloc _) => expect(repository.searches, isEmpty),
    );

    blocTest<PaymentsSearchBloc, PaymentsSearchState>(
      'removing the date window with no other criterion returns to idle',
      setUp: () {
        repository = repositoryReturning(
          Success<PaymentsFailure, List<Payment>>(<Payment>[approved]),
        );
      },
      build: () => createPaymentsSearchBlocFromRepository(repository),
      seed: () => PaymentsSearchState.empty(
        criteria: PaymentsSearchCriteria(dateRange: september),
      ),
      act: (PaymentsSearchBloc bloc) =>
          bloc.add(const PaymentsSearchEvent.dateRangeChanged(null)),
      expect: () => const <PaymentsSearchState>[PaymentsSearchState.idle()],
      verify: (PaymentsSearchBloc _) => expect(repository.searches, isEmpty),
    );

    blocTest<PaymentsSearchBloc, PaymentsSearchState>(
      'blank query without a filter returns to idle without searching',
      setUp: () {
        repository = repositoryReturning(
          Success<PaymentsFailure, List<Payment>>(<Payment>[approved]),
        );
      },
      build: () => createPaymentsSearchBlocFromRepository(repository),
      seed: () => PaymentsSearchState.results(
        criteria: const PaymentsSearchCriteria(query: 'Atlas'),
        payments: <Payment>[approved],
      ),
      act: (PaymentsSearchBloc bloc) =>
          bloc.add(const PaymentsSearchEvent.queryChanged('   ')),
      wait: Duration.zero,
      expect: () => const <PaymentsSearchState>[PaymentsSearchState.idle()],
      verify: (PaymentsSearchBloc _) => expect(repository.searches, isEmpty),
    );

    blocTest<PaymentsSearchBloc, PaymentsSearchState>(
      'filtersCleared drops the filters and the order but keeps the query',
      setUp: () {
        repository = repositoryReturning(
          Success<PaymentsFailure, List<Payment>>(<Payment>[approved]),
        );
      },
      build: () => createPaymentsSearchBlocFromRepository(repository),
      seed: () => PaymentsSearchState.empty(
        criteria: PaymentsSearchCriteria(
          query: 'Atlas',
          statuses: approvedOnly,
          dateRange: september,
          sort: oldestFirst,
        ),
      ),
      act: (PaymentsSearchBloc bloc) =>
          bloc.add(const PaymentsSearchEvent.filtersCleared()),
      expect: () => <PaymentsSearchState>[
        const PaymentsSearchState.loading(
          criteria: PaymentsSearchCriteria(query: 'Atlas'),
        ),
        PaymentsSearchState.results(
          criteria: const PaymentsSearchCriteria(query: 'Atlas'),
          payments: <Payment>[approved],
        ),
      ],
    );

    blocTest<PaymentsSearchBloc, PaymentsSearchState>(
      'filtersCleared with no query returns to idle without searching',
      setUp: () {
        repository = repositoryReturning(
          Success<PaymentsFailure, List<Payment>>(<Payment>[approved]),
        );
      },
      build: () => createPaymentsSearchBlocFromRepository(repository),
      seed: () => const PaymentsSearchState.empty(criteria: approvedCriteria),
      act: (PaymentsSearchBloc bloc) =>
          bloc.add(const PaymentsSearchEvent.filtersCleared()),
      expect: () => const <PaymentsSearchState>[PaymentsSearchState.idle()],
      verify: (PaymentsSearchBloc _) => expect(repository.searches, isEmpty),
    );

    blocTest<PaymentsSearchBloc, PaymentsSearchState>(
      'refresh is ignored while idle',
      setUp: () {
        repository = repositoryReturning(
          Success<PaymentsFailure, List<Payment>>(<Payment>[approved]),
        );
      },
      build: () => createPaymentsSearchBlocFromRepository(repository),
      act: (PaymentsSearchBloc bloc) =>
          bloc.add(const PaymentsSearchEvent.refreshRequested()),
      expect: () => const <PaymentsSearchState>[],
      verify: (PaymentsSearchBloc _) => expect(repository.searches, isEmpty),
    );

    blocTest<PaymentsSearchBloc, PaymentsSearchState>(
      'refresh re-runs the active criteria',
      setUp: () {
        repository = repositoryReturning(
          Success<PaymentsFailure, List<Payment>>(<Payment>[rejected]),
        );
      },
      build: () => createPaymentsSearchBlocFromRepository(repository),
      seed: () => const PaymentsSearchState.error(
        criteria: PaymentsSearchCriteria(
          query: 'Marina',
          statuses: approvedOnly,
        ),
        failure: PaymentsUnavailableFailure(),
      ),
      act: (PaymentsSearchBloc bloc) =>
          bloc.add(const PaymentsSearchEvent.refreshRequested()),
      expect: () => <PaymentsSearchState>[
        const PaymentsSearchState.loading(
          criteria: PaymentsSearchCriteria(
            query: 'Marina',
            statuses: approvedOnly,
          ),
        ),
        PaymentsSearchState.results(
          criteria: const PaymentsSearchCriteria(
            query: 'Marina',
            statuses: approvedOnly,
          ),
          payments: <Payment>[rejected],
        ),
      ],
      verify: (PaymentsSearchBloc _) {
        expect(repository.searches, <PaymentsSearchCriteria>[
          const PaymentsSearchCriteria(query: 'Marina', statuses: approvedOnly),
        ]);
      },
    );

    test('debounces rapid query edits into one search for the final text', () {
      fakeAsync((FakeAsync async) {
        final StubPaymentsRepository repository = repositoryReturning(
          Success<PaymentsFailure, List<Payment>>(<Payment>[approved]),
        );
        final PaymentsSearchBloc bloc = createPaymentsSearchBlocFromRepository(
          repository,
          debounceDuration: const Duration(milliseconds: 300),
        );
        final List<PaymentsSearchState> states = <PaymentsSearchState>[];
        final StreamSubscription<PaymentsSearchState> subscription = bloc.stream
            .listen(states.add);

        bloc.add(const PaymentsSearchEvent.queryChanged('A'));
        async.elapse(const Duration(milliseconds: 100));
        bloc.add(const PaymentsSearchEvent.queryChanged('At'));
        async.elapse(const Duration(milliseconds: 100));
        bloc.add(const PaymentsSearchEvent.queryChanged('Atl'));
        async.elapse(const Duration(milliseconds: 299));

        expect(repository.searches, isEmpty);
        expect(states, isEmpty);

        async.elapse(const Duration(milliseconds: 1));

        expect(repository.searches, <PaymentsSearchCriteria>[
          const PaymentsSearchCriteria(query: 'Atl'),
        ]);
        expect(states, <PaymentsSearchState>[
          const PaymentsSearchState.loading(
            criteria: PaymentsSearchCriteria(query: 'Atl'),
          ),
          PaymentsSearchState.results(
            criteria: const PaymentsSearchCriteria(query: 'Atl'),
            payments: <Payment>[approved],
          ),
        ]);

        unawaited(subscription.cancel());
        unawaited(bloc.close());
        async.flushMicrotasks();
      });
    });

    test('a newer event cancels the search still in flight', () async {
      final Completer<Result<PaymentsFailure, List<Payment>>> slow =
          Completer<Result<PaymentsFailure, List<Payment>>>();
      final StubPaymentsRepository repository = StubPaymentsRepository(
        onLoad: () async =>
            const Success<PaymentsFailure, List<Payment>>(<Payment>[]),
        onSearch: (PaymentsSearchCriteria criteria) =>
            criteria.statuses.contains(PaymentStatus.approved)
            ? slow.future
            : Future<Result<PaymentsFailure, List<Payment>>>.value(
                Success<PaymentsFailure, List<Payment>>(<Payment>[rejected]),
              ),
      );
      final PaymentsSearchBloc bloc = createPaymentsSearchBlocFromRepository(
        repository,
      );
      addTearDown(bloc.close);
      final List<PaymentsSearchState> states = <PaymentsSearchState>[];
      final StreamSubscription<PaymentsSearchState> subscription = bloc.stream
          .listen(states.add);
      addTearDown(subscription.cancel);
      const PaymentsSearchCriteria rejectedCriteria = PaymentsSearchCriteria(
        statuses: <PaymentStatus>{PaymentStatus.rejected},
      );

      bloc.add(const PaymentsSearchEvent.statusFilterChanged(approvedOnly));
      await Future<void>.delayed(Duration.zero);
      bloc.add(
        const PaymentsSearchEvent.statusFilterChanged(<PaymentStatus>{
          PaymentStatus.rejected,
        }),
      );
      await Future<void>.delayed(Duration.zero);
      slow.complete(
        Success<PaymentsFailure, List<Payment>>(<Payment>[approved]),
      );
      await Future<void>.delayed(Duration.zero);

      expect(states, <PaymentsSearchState>[
        const PaymentsSearchState.loading(criteria: approvedCriteria),
        const PaymentsSearchState.loading(criteria: rejectedCriteria),
        PaymentsSearchState.results(
          criteria: rejectedCriteria,
          payments: <Payment>[rejected],
        ),
      ]);
    });

    test('a sort change cancels a query search still in flight', () async {
      final Completer<Result<PaymentsFailure, List<Payment>>> slow =
          Completer<Result<PaymentsFailure, List<Payment>>>();
      final StubPaymentsRepository repository = StubPaymentsRepository(
        onLoad: () async =>
            const Success<PaymentsFailure, List<Payment>>(<Payment>[]),
        onSearch: (PaymentsSearchCriteria criteria) =>
            criteria.sort == PaymentsSort.decidedAtNewestFirst
            ? slow.future
            : Future<Result<PaymentsFailure, List<Payment>>>.value(
                Success<PaymentsFailure, List<Payment>>(<Payment>[rejected]),
              ),
      );
      final PaymentsSearchBloc bloc = createPaymentsSearchBlocFromRepository(
        repository,
      );
      addTearDown(bloc.close);
      final List<PaymentsSearchState> states = <PaymentsSearchState>[];
      final StreamSubscription<PaymentsSearchState> subscription = bloc.stream
          .listen(states.add);
      addTearDown(subscription.cancel);

      bloc.add(const PaymentsSearchEvent.queryChanged('Marina'));
      await pumpEventQueue();
      bloc.add(const PaymentsSearchEvent.sortChanged(oldestFirst));
      await pumpEventQueue();
      slow.complete(
        Success<PaymentsFailure, List<Payment>>(<Payment>[approved]),
      );
      await pumpEventQueue();

      // The stale query search completed after the sort search; a different
      // handler type cannot restart it, so the sequence guard drops it.
      expect(states.last, isA<PaymentsSearchResults>());
      expect((states.last as PaymentsSearchResults).payments, <Payment>[
        rejected,
      ]);
      expect(bloc.state.criteria.sort, oldestFirst);
    });

    test('closing with a pending query edit leaves no timer behind', () {
      fakeAsync((FakeAsync async) {
        final StubPaymentsRepository repository = repositoryReturning(
          const Success<PaymentsFailure, List<Payment>>(<Payment>[]),
        );
        final PaymentsSearchBloc bloc = createPaymentsSearchBlocFromRepository(
          repository,
          debounceDuration: const Duration(milliseconds: 300),
        );

        bloc.add(const PaymentsSearchEvent.queryChanged('Atlas'));
        async.flushMicrotasks();
        unawaited(bloc.close());
        async.flushMicrotasks();

        expect(async.pendingTimers, isEmpty);
        async.elapse(const Duration(seconds: 1));
        expect(repository.searches, isEmpty);
      });
    });
  });
}
