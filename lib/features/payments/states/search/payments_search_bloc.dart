import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/common/data/payments/models/payments_search_criteria.dart';
import 'package:mamo_approval/common/data/payments/use_cases/search_payments_use_case.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_event.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_state.dart';
import 'package:stream_transform/stream_transform.dart';

/// Event-driven search over the decided payment history.
///
/// This is deliberately a `Bloc` rather than a `Cubit`: the query input is a
/// stream of discrete events whose timing matters (debounce), and every newer
/// criterion must cancel the search still in flight. Each event has its own
/// handler; the transformers on the query and filter handlers own the timing
/// and restart rules for their event type.
@injectable
final class PaymentsSearchBloc
    extends Bloc<PaymentsSearchEvent, PaymentsSearchState> {
  PaymentsSearchBloc(
    this._searchPayments, {
    @ignoreParam Duration debounceDuration = defaultDebounceDuration,
  }) : super(const PaymentsSearchState.idle()) {
    on<PaymentsSearchQueryChanged>(
      _onQueryChanged,
      transformer: _debouncedRestartable(debounceDuration),
    );
    on<PaymentsSearchStatusFilterChanged>(
      _onStatusFilterChanged,
      transformer: _restartable(),
    );
    on<PaymentsSearchDateRangeChanged>(
      _onDateRangeChanged,
      transformer: _restartable(),
    );
    on<PaymentsSearchSortChanged>(_onSortChanged, transformer: _restartable());
    on<PaymentsSearchFiltersCleared>(
      _onFiltersCleared,
      transformer: _restartable(),
    );
    on<PaymentsSearchRefreshRequested>(
      _onRefreshRequested,
      transformer: _restartable(),
    );
  }

  static const Duration defaultDebounceDuration = Duration(milliseconds: 300);

  final SearchPaymentsUseCase _searchPayments;

  /// Bumped by every handler that changes the criteria. A search whose
  /// sequence is no longer current was superseded by another event type
  /// (the per-handler restart only covers events of the same type).
  int _searchSequence = 0;

  Future<void> _onQueryChanged(
    PaymentsSearchQueryChanged event,
    Emitter<PaymentsSearchState> emit,
  ) {
    return _search(emit, state.criteria.copyWith(query: event.query));
  }

  Future<void> _onStatusFilterChanged(
    PaymentsSearchStatusFilterChanged event,
    Emitter<PaymentsSearchState> emit,
  ) {
    return _search(
      emit,
      state.criteria.copyWith(
        statuses: Set<PaymentStatus>.unmodifiable(event.statuses),
      ),
    );
  }

  Future<void> _onDateRangeChanged(
    PaymentsSearchDateRangeChanged event,
    Emitter<PaymentsSearchState> emit,
  ) {
    return _search(emit, state.criteria.copyWith(dateRange: event.dateRange));
  }

  Future<void> _onSortChanged(
    PaymentsSearchSortChanged event,
    Emitter<PaymentsSearchState> emit,
  ) {
    return _search(emit, state.criteria.copyWith(sort: event.sort));
  }

  Future<void> _onFiltersCleared(
    PaymentsSearchFiltersCleared event,
    Emitter<PaymentsSearchState> emit,
  ) {
    return _search(emit, PaymentsSearchCriteria(query: state.criteria.query));
  }

  Future<void> _onRefreshRequested(
    PaymentsSearchRefreshRequested event,
    Emitter<PaymentsSearchState> emit,
  ) {
    if (!state.isActive) {
      return Future<void>.value();
    }
    return _search(emit, state.criteria);
  }

  Future<void> _search(
    Emitter<PaymentsSearchState> emit,
    PaymentsSearchCriteria requested,
  ) async {
    final int sequence = ++_searchSequence;
    final PaymentsSearchCriteria criteria = requested.copyWith(
      query: requested.query.trim(),
    );
    if (criteria.isEmpty) {
      emit(const PaymentsSearchState.idle());
      return;
    }
    emit(PaymentsSearchState.loading(criteria: criteria));
    final Result<PaymentsFailure, List<Payment>> result = await _searchPayments(
      criteria,
    );
    if (emit.isDone || sequence != _searchSequence) {
      return;
    }
    emit(switch (result) {
      Failure<PaymentsFailure, List<Payment>>(:final failure) =>
        PaymentsSearchState.error(criteria: criteria, failure: failure),
      Success<PaymentsFailure, List<Payment>>(:final value)
          when value.isEmpty =>
        PaymentsSearchState.empty(criteria: criteria),
      Success<PaymentsFailure, List<Payment>>(:final value) =>
        PaymentsSearchState.results(criteria: criteria, payments: value),
    });
  }

  /// Restarts the handler for every new event of its type, so a stale search
  /// never overwrites a newer state.
  static EventTransformer<E> _restartable<E extends PaymentsSearchEvent>() {
    return (Stream<E> events, EventMapper<E> mapper) =>
        events.switchMap(mapper);
  }

  /// Holds each query edit for [debounce] and forwards only the last one,
  /// then restarts the handler for the forwarded edit.
  static EventTransformer<PaymentsSearchQueryChanged> _debouncedRestartable(
    Duration debounce,
  ) {
    return (
      Stream<PaymentsSearchQueryChanged> events,
      EventMapper<PaymentsSearchQueryChanged> mapper,
    ) => _debounce(events, debounce).switchMap(mapper);
  }

  static Stream<PaymentsSearchQueryChanged> _debounce(
    Stream<PaymentsSearchQueryChanged> events,
    Duration debounce,
  ) {
    Timer? pending;
    StreamSubscription<PaymentsSearchQueryChanged>? input;
    late final StreamController<PaymentsSearchQueryChanged> output;
    output = StreamController<PaymentsSearchQueryChanged>(
      sync: true,
      onListen: () {
        input = events.listen(
          (PaymentsSearchQueryChanged event) {
            pending?.cancel();
            pending = Timer(debounce, () {
              pending = null;
              output.add(event);
            });
          },
          onError: output.addError,
          onDone: () {
            pending?.cancel();
            pending = null;
            unawaited(output.close());
          },
        );
      },
      onCancel: () {
        pending?.cancel();
        pending = null;
        return input?.cancel();
      },
    );
    return output.stream;
  }
}
