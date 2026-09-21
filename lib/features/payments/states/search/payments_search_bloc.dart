import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
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
    on<PaymentsSearchCleared>(_onCleared);
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

  /// Bumped by [_onCleared] so a query edit that was still waiting for its
  /// debounce window when the user cleared the search is discarded.
  int _clearGeneration = 0;

  Future<void> _onQueryChanged(
    PaymentsSearchQueryChanged event,
    Emitter<PaymentsSearchState> emit,
  ) {
    return _search(emit, query: event.query, statuses: state.statuses);
  }

  Future<void> _onStatusFilterChanged(
    PaymentsSearchStatusFilterChanged event,
    Emitter<PaymentsSearchState> emit,
  ) {
    return _search(emit, query: state.query, statuses: event.statuses);
  }

  void _onCleared(
    PaymentsSearchCleared event,
    Emitter<PaymentsSearchState> emit,
  ) {
    _clearGeneration += 1;
    _searchSequence += 1;
    emit(const PaymentsSearchState.idle());
  }

  Future<void> _onRefreshRequested(
    PaymentsSearchRefreshRequested event,
    Emitter<PaymentsSearchState> emit,
  ) {
    if (!state.isActive) {
      return Future<void>.value();
    }
    return _search(emit, query: state.query, statuses: state.statuses);
  }

  Future<void> _search(
    Emitter<PaymentsSearchState> emit, {
    required String query,
    required Set<PaymentStatus> statuses,
  }) async {
    final int sequence = ++_searchSequence;
    final String trimmed = query.trim();
    final Set<PaymentStatus> selected = Set<PaymentStatus>.unmodifiable(
      statuses,
    );
    if (trimmed.isEmpty && selected.isEmpty) {
      emit(const PaymentsSearchState.idle());
      return;
    }
    emit(PaymentsSearchState.loading(query: trimmed, statuses: selected));
    final Result<PaymentsFailure, List<Payment>> result = await _searchPayments(
      query: trimmed,
      statuses: selected,
    );
    if (emit.isDone || sequence != _searchSequence) {
      return;
    }
    emit(switch (result) {
      Failure<PaymentsFailure, List<Payment>>(:final failure) =>
        PaymentsSearchState.error(
          query: trimmed,
          statuses: selected,
          failure: failure,
        ),
      Success<PaymentsFailure, List<Payment>>(:final value)
          when value.isEmpty =>
        PaymentsSearchState.empty(query: trimmed, statuses: selected),
      Success<PaymentsFailure, List<Payment>>(:final value) =>
        PaymentsSearchState.results(
          query: trimmed,
          statuses: selected,
          payments: value,
        ),
    });
  }

  /// Restarts the handler for every new event of its type, so a stale search
  /// never overwrites a newer state.
  static EventTransformer<E> _restartable<E extends PaymentsSearchEvent>() {
    return (Stream<E> events, EventMapper<E> mapper) =>
        events.switchMap(mapper);
  }

  /// Holds each query edit for [debounce] and forwards only the last one,
  /// drops an edit that was waiting when the search was cleared, then restarts
  /// the handler for the forwarded edit.
  EventTransformer<PaymentsSearchQueryChanged> _debouncedRestartable(
    Duration debounce,
  ) {
    return (
      Stream<PaymentsSearchQueryChanged> events,
      EventMapper<PaymentsSearchQueryChanged> mapper,
    ) {
      return _debounce(events, debounce)
          .where((_TaggedQuery tagged) => tagged.generation == _clearGeneration)
          .map((_TaggedQuery tagged) => tagged.event)
          .switchMap(mapper);
    };
  }

  Stream<_TaggedQuery> _debounce(
    Stream<PaymentsSearchQueryChanged> events,
    Duration debounce,
  ) {
    Timer? pending;
    StreamSubscription<PaymentsSearchQueryChanged>? input;
    late final StreamController<_TaggedQuery> output;
    output = StreamController<_TaggedQuery>(
      sync: true,
      onListen: () {
        input = events.listen(
          (PaymentsSearchQueryChanged event) {
            final _TaggedQuery tagged = (
              event: event,
              generation: _clearGeneration,
            );
            pending?.cancel();
            pending = Timer(debounce, () {
              pending = null;
              output.add(tagged);
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

typedef _TaggedQuery = ({PaymentsSearchQueryChanged event, int generation});
