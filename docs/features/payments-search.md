# Payments search and status filtering

Status: implemented on the feature branch as the slice-5 extension selected from the [backlog](../product/extension-backlog.md); decision recorded in [ADR 0013](../decisions/0013-event-driven-bloc-for-payments-search.md).

## Behaviour

- The Payments screen shows a search field and Approved/Rejected filter chips above the decided history once the collection has loaded. With no query and no selected status the page shows the unchanged full history.
- Text matches case-insensitively against the counterparty and the reference, the two text fields the history row and details already display without authentication. Amount and dates are not text-searchable; status is selected through the chips. An empty status selection means both decided statuses.
- The pending request is never part of a result, whatever the query or filter, because its counterparty and amount stay masked until native authentication (`APPROVAL-02/04`). The mock backend excludes it, the data source drops it again at the boundary, and both rules are tested.
- Query edits are debounced (300 ms); a clear action discards a waiting edit and returns to the full history; every newer criterion cancels the search still in flight.
- The backend orders results by the requested field and direction (the history order: newest decision first, stable identifier tie-break); no layer above it re-sorts. Results use the same tappable rows, so opening details works unchanged, and a result count is announced above the list.
- No match shows a search-specific empty state; a typed failure shows a search-specific error with retry. Neither replaces the history load states.
- A decision that changes the authoritative collection re-runs an active search, so the newly decided payment appears in the open result without retyping.
- Reaching Payments from Home still pushes no route: system Back returns to Home and the search field, chips, and results are intact when Payments is reopened in the same session. Search state is session-only and resets with the process, like the rest of the demo.

## Ownership and data path

`PaymentsPage` provides the `injectable` `PaymentsSearchBloc` and selects a view per collection state; `PaymentsHistoryView` (under `views/`) selects a view per search state. `PaymentsSearchField` and `PaymentStatusFilterChips` dispatch events; each event has its own handler in the bloc. The bloc calls `SearchPaymentsUseCase`, which calls `PaymentsRepository.searchPayments`, which calls `PaymentsRemoteDataSource.search`, which calls the backend client's `searchPayments` with the query, statuses, and sort parameters and maps records and exceptions to typed results. `MockPaymentsBackend` filters and orders its single authoritative record list; there is no second collection, cache, or persistence.

## Verification

Backend, data-source, repository, use-case, bloc (`blocTest` and `fakeAsync`), page, and app tests cover the path; see ADR 0013 for the file list. Maestro coverage for the search journey is not added in this slice and remains a follow-up.
