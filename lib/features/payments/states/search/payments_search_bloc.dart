import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/error_handling/payments_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/models/payment.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/search_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/search/payments_search_event.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/search/payments_search_state.dart';
import 'package:stream_transform/stream_transform.dart';

/// Event-driven search over the decided payment history.
///
/// This is deliberately a `Bloc` rather than a `Cubit`: the query input is a
/// stream of discrete events whose timing matters (debounce), and every new
/// event must cancel the search still in flight. Both concerns live in one
/// [EventTransformer] instead of hand-rolled timers and version counters.
final class PaymentsSearchBloc
    extends Bloc<PaymentsSearchEvent, PaymentsSearchState> {
  PaymentsSearchBloc({
    required this._searchPayments,
    Duration debounceDuration = defaultDebounceDuration,
  }) : super(const PaymentsSearchState.idle()) {
    on<PaymentsSearchEvent>(
      _onEvent,
      transformer: _restartableWithDebouncedQueries(debounceDuration),
    );
  }

  static const Duration defaultDebounceDuration = Duration(milliseconds: 300);

  final SearchPaymentsUseCase _searchPayments;

  Future<void> _onEvent(
    PaymentsSearchEvent event,
    Emitter<PaymentsSearchState> emit,
  ) {
    return switch (event) {
      PaymentsSearchQueryChanged(:final query) => _search(
        emit,
        query: query,
        statuses: state.statuses,
      ),
      PaymentsSearchStatusFilterChanged(:final statuses) => _search(
        emit,
        query: state.query,
        statuses: statuses,
      ),
      PaymentsSearchCleared() => _search(
        emit,
        query: '',
        statuses: const <PaymentStatus>{},
      ),
      PaymentsSearchRefreshRequested() when state.isActive => _search(
        emit,
        query: state.query,
        statuses: state.statuses,
      ),
      PaymentsSearchRefreshRequested() => Future<void>.value(),
    };
  }

  Future<void> _search(
    Emitter<PaymentsSearchState> emit, {
    required String query,
    required Set<PaymentStatus> statuses,
  }) async {
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
    // A newer event restarted the handler while the search was in flight; its
    // own emission already describes the current criteria.
    if (emit.isDone) {
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
}

/// Holds each query edit for [debounce] and forwards only the last one, passes
/// every other event through immediately, lets a clear request discard a
/// waiting query edit, and restarts the handler for each forwarded event so a
/// stale search never overwrites a newer state.
EventTransformer<PaymentsSearchEvent> _restartableWithDebouncedQueries(
  Duration debounce,
) {
  return (
    Stream<PaymentsSearchEvent> events,
    EventMapper<PaymentsSearchEvent> mapper,
  ) => _debounceQueryEdits(events, debounce).switchMap(mapper);
}

Stream<PaymentsSearchEvent> _debounceQueryEdits(
  Stream<PaymentsSearchEvent> events,
  Duration debounce,
) {
  Timer? pendingQuery;
  StreamSubscription<PaymentsSearchEvent>? input;
  late final StreamController<PaymentsSearchEvent> output;
  output = StreamController<PaymentsSearchEvent>(
    sync: true,
    onListen: () {
      input = events.listen(
        (PaymentsSearchEvent event) {
          switch (event) {
            case PaymentsSearchQueryChanged():
              pendingQuery?.cancel();
              pendingQuery = Timer(debounce, () {
                pendingQuery = null;
                output.add(event);
              });
            case PaymentsSearchCleared():
              pendingQuery?.cancel();
              pendingQuery = null;
              output.add(event);
            case PaymentsSearchStatusFilterChanged():
            case PaymentsSearchRefreshRequested():
              output.add(event);
          }
        },
        onError: output.addError,
        onDone: () {
          pendingQuery?.cancel();
          pendingQuery = null;
          unawaited(output.close());
        },
      );
    },
    onCancel: () {
      pendingQuery?.cancel();
      pendingQuery = null;
      return input?.cancel();
    },
  );
  return output.stream;
}
