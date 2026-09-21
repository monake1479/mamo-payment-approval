# ADR 0014: Event-driven BLoC for payments search

- Status: Proposed (coordinator-selected under the delegated implementation authority; subject to owner review)
- Date: 2026-09-21

## Context

The payment screens use Cubits: `PaymentsCubit` owns the authoritative collection, `ApprovalCubit` owns one request's authentication and decision, and `DebugActionCubit` owns the draggable action. Each exposes imperative methods that map one call to one state transition.

Search over the decided history is different. Its primary input is a stream of keystrokes whose timing matters: rapid edits must collapse into one search for the final text, a clear request must discard an edit still waiting, and every newer criterion must cancel the search still in flight so a slow, stale result never overwrites a newer state. The slice also demonstrates the full path UI -> state owner -> use case -> repository -> data source -> mock backend and back for reviewers.

## Alternatives

1. **Cubit with hand-rolled timers.** A `search(query)` method that owns a `Timer`, a version counter, and cancellation bookkeeping. Works, but reimplements what `Bloc.on` transformers already model, scatters the timing rules across methods, and is harder to test than a declarative event pipeline.
2. **`bloc_concurrency` + `stream_transform`.** `restartable()` is a one-line wrapper over `switchMap`, and `bloc_concurrency` offers no debounce, so the project would still need `stream_transform` plus a custom debounce that also honours the clear rule. Two packages for one line of value.
3. **Event-driven `Bloc` with one handler per event (chosen).** Each event (`queryChanged`, `statusFilterChanged`, `dateRangeChanged`, `sortChanged`, `cleared`, `refreshRequested`) has its own private handler, following the project's `NewsListBloc`-style convention. Timing rules live in the transformers attached to those handlers: the query handler debounces edits and drops an edit that was waiting when the search was cleared; the query, filter, and refresh handlers restart with `switchMap` from `stream_transform`. A sequence counter guards completions superseded by a different event type.

## Decision

Implement `PaymentsSearchBloc` under `lib/features/payments/states/search/` with `payments_search_bloc.dart`, `payments_search_event.dart`, and `payments_search_state.dart`. States are a Freezed sealed union: `idle`, `loading`, `results`, `empty`, `error`; every active state carries the criteria it describes. The bloc is registered with `injectable` as a factory, receives `SearchPaymentsUseCase` by constructor, and never sees `BuildContext`, navigation, or dialogs. `PaymentsPage` provides it through `BlocProvider(create: getIt<PaymentsSearchBloc>())`; the router stays unaware of page-internal state owners. The page selects a view per collection state and `PaymentsHistoryView` selects a view per search state; those views live under `lib/features/payments/views/`, one class per file.

Filtering and ordering are backend concerns: `PaymentsBackendClient.searchPayments` takes the query, statuses, optional ISO `decidedFrom`/`decidedTo` bounds, and `sortBy`/`sortDirection`; `PaymentsRemoteDataSource` maps one typed `PaymentsSearchCriteria` (query, statuses, `PaymentsDateRange`, `PaymentsSort`) to them. The default criteria mean the plain history (no text, every decided status, no window, newest decision first, identifier tie-break). No layer above the backend re-filters or re-sorts search results; presentation only converts picked calendar days into the account zone's UTC window.

Add `stream_transform` as a direct dependency for `switchMap`; it was already resolved transitively and is maintained by the Dart team. Add `bloc_test` and `fake_async` as dev dependencies: `blocTest` documents event-to-state expectations in the textbook form the slice demonstrates, and `fakeAsync` proves the debounce window deterministically without wall-clock waits.

The rest of the payment screens keep their Cubits. This ADR does not make BLoC the default; it records when an event transformer earns its place: input timing, cancellation of in-flight work, or discrete events with different concurrency rules.

## Consequences

- Each handler is small and reads as one event's rule; the timing and cancellation rules are covered by focused tests (debounce window, discarded edit on clear, in-flight restart across event types, no timer left after close).
- The page-scoped `BlocProvider` inside `PaymentsPage` owns the bloc for the session (the preloaded branch keeps the page alive), so an active search survives the Home/Payments switch and system Back, matching the pushed-route-free navigation contract.
- The bloc does not subscribe to `PaymentsCubit`; a widget `BlocListener` re-dispatches `refreshRequested` when the authoritative collection changes so a fresh decision reaches an open result immediately.
- Search reads the same authoritative mock backend through the production-shaped data source; there is no second store, cache, or persistence.

## Verification

- `test/features/payments/states/search/payments_search_bloc_test.dart`: event-to-state transitions, debounce, clear, restart, refresh, disposal.
- `test/common/data/payments/use_cases/search_payments_use_case_test.dart`, `test/common/data/payments/data_sources/payments_remote_data_source_test.dart`, `test/common/data/payments/payments_repository_test.dart`, `test/mock_backend/payments/mock_payments_backend_test.dart`: each layer of the search path, including the masked-data exclusion.
- `test/features/payments/pages/payments_page_test.dart` and `test/app/app_test.dart`: field, chips, empty/error states, debounce, collection refresh, and Back-navigation state retention.
