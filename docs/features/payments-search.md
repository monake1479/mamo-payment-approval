# Payments search and status filtering

Status: implemented on the feature branch as the slice-5 extension selected from the [backlog](../product/extension-backlog.md) (`SEARCH-01..07`, `PAY-05`); decision recorded in [ADR 0014](../decisions/0014-event-driven-bloc-for-payments-search.md).

## Behaviour

- The Payments screen shows a search field and a wrapping row of controls above the decided history once the collection has loaded: a status dropdown (all, approved, rejected), the decision-date chip, the sort dropdown, and a Clear button while a status, date, or non-default order is set (it keeps the typed text; the field clears its own text). The controls sit inside the history scroll view, so they never constrain the list at large text sizes. With no criteria the page shows the unchanged full history.
- Text matches case-insensitively against the counterparty and the reference, the two text fields the history row and details already display without authentication. Amount and dates are not text-searchable; status is selected through the chips. An empty status selection means both decided statuses.
- The pending request is never part of a result, whatever the query or filter, because its counterparty and amount stay masked until native authentication (`APPROVAL-02/04`). The mock backend excludes it, the data source drops it again at the boundary, and both rules are tested.
- Query edits are debounced (300 ms) and every newer criterion cancels the search still in flight.
- A decision-date chip opens the Material date-range picker; the chosen calendar days are converted to the account zone's UTC window by `PaymentFormatters.accountDays` and the backend filters `decidedAt` against it (start inclusive, end exclusive). The chip shows the chosen days and removes the window with its delete action.
- A sort menu chip offers newest first (default), oldest first, highest amount, lowest amount, and counterparty A to Z. The backend orders results by the requested field and direction with a stable identifier tie-break; no layer above it re-sorts. The default order with no other criterion is the plain history.
- Pull-to-refresh on the list, empty, and error areas reloads the authoritative collection; an open search re-runs through the page's collection listener. Results use the same tappable rows, so opening details works unchanged, and a result count is announced above the list.
- No match shows a search-specific empty state; a typed failure shows a search-specific error with retry. Neither replaces the history load states.
- A decision that changes the authoritative collection re-runs an active search, so the newly decided payment appears in the open result without retyping.
- Reaching Payments from Home still pushes no route: system Back returns to Home and the search field, chips, and results are intact when Payments is reopened in the same session. Search state is session-only and resets with the process, like the rest of the demo.

## Ownership and data path

`PaymentsPage` provides the `injectable` `PaymentsSearchBloc` and selects a view per collection state; `PaymentsHistoryView` (under `views/`) selects a view per search state. `PaymentsSearchField`, `PaymentStatusFilterMenu`, `PaymentsDateFilterChip`, `PaymentsSortMenu`, and the Clear action dispatch events; each event has its own handler in the bloc. Every criterion (query, statuses, date window, sort) lives in one `PaymentsSearchCriteria` value carried by the active states. The bloc calls `SearchPaymentsUseCase`, which calls `PaymentsRepository.searchPayments`, which calls `PaymentsRemoteDataSource.search`, which calls the backend client's `searchPayments` with the query, statuses, ISO date bounds, and sort parameters and maps records and exceptions to typed results. `MockPaymentsBackend` filters and orders its single authoritative record list; there is no second collection, cache, or persistence.

## Verification

Backend, data-source, repository, use-case, bloc (`blocTest` and `fakeAsync`), page, and app tests cover the path; see ADR 0014 for the file list. Maestro coverage for the search journey is not added in this slice and remains a follow-up.
