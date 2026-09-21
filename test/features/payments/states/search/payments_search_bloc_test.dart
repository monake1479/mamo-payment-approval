import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
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

  StubPaymentsRepository repositoryReturning(
    Result<PaymentsFailure, List<Payment>> result,
  ) {
    return StubPaymentsRepository(
      onLoad: () async =>
          const Success<PaymentsFailure, List<Payment>>(<Payment>[]),
      onSearch: (
        String query,
        Set<PaymentStatus> statuses,
        PaymentsSort sort,
      ) async => result,
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
          query: 'Atlas',
          statuses: <PaymentStatus>{},
        ),
        PaymentsSearchState.results(
          query: 'Atlas',
          statuses: const <PaymentStatus>{},
          payments: <Payment>[approved],
        ),
      ],
      verify: (PaymentsSearchBloc _) {
        expect(repository.searchQueries, <String>['Atlas']);
        expect(repository.searchStatuses, <Set<PaymentStatus>>[
          <PaymentStatus>{},
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
          query: 'nobody',
          statuses: <PaymentStatus>{},
        ),
        PaymentsSearchState.empty(query: 'nobody', statuses: <PaymentStatus>{}),
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
        PaymentsSearchState.loading(query: '', statuses: approvedOnly),
        PaymentsSearchState.error(
          query: '',
          statuses: approvedOnly,
          failure: PaymentsUnavailableFailure(),
        ),
      ],
    );

    blocTest<PaymentsSearchBloc, PaymentsSearchState>(
      'status filter keeps the current query and query keeps the filter',
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
        bloc.add(const PaymentsSearchEvent.queryChanged('PO-1'));
      },
      wait: Duration.zero,
      verify: (PaymentsSearchBloc bloc) {
        expect(repository.searchQueries, <String>['PO', 'PO', 'PO-1']);
        expect(repository.searchStatuses, <Set<PaymentStatus>>[
          <PaymentStatus>{},
          approvedOnly,
          approvedOnly,
        ]);
        expect(bloc.state.query, 'PO-1');
        expect(bloc.state.statuses, approvedOnly);
      },
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
        query: 'Atlas',
        statuses: const <PaymentStatus>{},
        payments: <Payment>[approved],
      ),
      act: (PaymentsSearchBloc bloc) =>
          bloc.add(const PaymentsSearchEvent.queryChanged('   ')),
      wait: Duration.zero,
      expect: () => const <PaymentsSearchState>[PaymentsSearchState.idle()],
      verify: (PaymentsSearchBloc _) =>
          expect(repository.searchQueries, isEmpty),
    );

    blocTest<PaymentsSearchBloc, PaymentsSearchState>(
      'cleared drops the query and the filter',
      setUp: () {
        repository = repositoryReturning(
          Success<PaymentsFailure, List<Payment>>(<Payment>[approved]),
        );
      },
      build: () => createPaymentsSearchBlocFromRepository(repository),
      seed: () =>
          const PaymentsSearchState.empty(query: 'x', statuses: approvedOnly),
      act: (PaymentsSearchBloc bloc) =>
          bloc.add(const PaymentsSearchEvent.cleared()),
      expect: () => const <PaymentsSearchState>[PaymentsSearchState.idle()],
      verify: (PaymentsSearchBloc _) =>
          expect(repository.searchQueries, isEmpty),
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
      verify: (PaymentsSearchBloc _) =>
          expect(repository.searchQueries, isEmpty),
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
        query: 'Marina',
        statuses: approvedOnly,
        failure: PaymentsUnavailableFailure(),
      ),
      act: (PaymentsSearchBloc bloc) =>
          bloc.add(const PaymentsSearchEvent.refreshRequested()),
      expect: () => <PaymentsSearchState>[
        const PaymentsSearchState.loading(
          query: 'Marina',
          statuses: approvedOnly,
        ),
        PaymentsSearchState.results(
          query: 'Marina',
          statuses: approvedOnly,
          payments: <Payment>[rejected],
        ),
      ],
      verify: (PaymentsSearchBloc _) {
        expect(repository.searchQueries, <String>['Marina']);
        expect(repository.searchStatuses, <Set<PaymentStatus>>[approvedOnly]);
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

        expect(repository.searchQueries, isEmpty);
        expect(states, isEmpty);

        async.elapse(const Duration(milliseconds: 1));

        expect(repository.searchQueries, <String>['Atl']);
        expect(repository.searchStatuses, <Set<PaymentStatus>>[
          <PaymentStatus>{},
        ]);
        expect(states, <PaymentsSearchState>[
          const PaymentsSearchState.loading(
            query: 'Atl',
            statuses: <PaymentStatus>{},
          ),
          PaymentsSearchState.results(
            query: 'Atl',
            statuses: const <PaymentStatus>{},
            payments: <Payment>[approved],
          ),
        ]);

        unawaited(subscription.cancel());
        unawaited(bloc.close());
        async.flushMicrotasks();
      });
    });

    test('cleared discards a query edit still waiting for its debounce', () {
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

        bloc.add(const PaymentsSearchEvent.statusFilterChanged(approvedOnly));
        async.flushMicrotasks();
        bloc.add(const PaymentsSearchEvent.queryChanged('Atlas'));
        async.elapse(const Duration(milliseconds: 100));
        bloc.add(const PaymentsSearchEvent.cleared());
        async.elapse(const Duration(seconds: 1));

        expect(repository.searchQueries, <String>['']);
        expect(repository.searchStatuses, <Set<PaymentStatus>>[approvedOnly]);
        expect(states.last, const PaymentsSearchState.idle());
        expect(
          states.whereType<PaymentsSearchLoading>().map(
            (PaymentsSearchLoading state) => state.query,
          ),
          isNot(contains('Atlas')),
        );

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
        onSearch:
            (String query, Set<PaymentStatus> statuses, PaymentsSort sort) =>
                statuses.contains(PaymentStatus.approved)
                ? slow.future
                : Future<Result<PaymentsFailure, List<Payment>>>.value(
                    Success<PaymentsFailure, List<Payment>>(<Payment>[
                      rejected,
                    ]),
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
      const Set<PaymentStatus> rejectedOnly = <PaymentStatus>{
        PaymentStatus.rejected,
      };

      bloc.add(const PaymentsSearchEvent.statusFilterChanged(approvedOnly));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const PaymentsSearchEvent.statusFilterChanged(rejectedOnly));
      await Future<void>.delayed(Duration.zero);
      slow.complete(
        Success<PaymentsFailure, List<Payment>>(<Payment>[approved]),
      );
      await Future<void>.delayed(Duration.zero);

      expect(states, <PaymentsSearchState>[
        const PaymentsSearchState.loading(query: '', statuses: approvedOnly),
        const PaymentsSearchState.loading(query: '', statuses: rejectedOnly),
        PaymentsSearchState.results(
          query: '',
          statuses: rejectedOnly,
          payments: <Payment>[rejected],
        ),
      ]);
      expect(bloc.state.statuses, rejectedOnly);
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
        expect(repository.searchQueries, isEmpty);
      });
    });
  });
}
