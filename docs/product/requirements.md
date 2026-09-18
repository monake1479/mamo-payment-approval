# Product Requirements

This document paraphrases the supplied challenge brief. The original attachment is intentionally not committed.

## Owner clarifications

- iOS and Android only. The owner removed the earlier Web delivery proposal on 2026-09-16; see ADR 0003.
- No-compile reviewer access is provided through an Android APK. iOS remains supported and tested, but TestFlight/store distribution is not part of submission scope.
- Original additions will be discussed after the core flow works. Backlog candidates are not accepted scope.
- Maestro is the selected mobile E2E tool, by owner decision; see ADR 0005. This does not change product behaviour or authorize an authentication bypass.
- Provide `dev`, `staging`, and `prod` native flavors on both platforms; see [ADR 0007](../decisions/0007-native-flavors.md). They currently share application behaviour and have separate installation identities.
- Keep Flutter UI text in ARB resources accessed through `AppLocalizations`, using Flutter localization tooling and `intl`; see [ADR 0008](../decisions/0008-localization.md). English remains the only supported locale.
- Use `go_router` for application navigation, wired at app composition from the foundation stage. Feature routes are added with their implementations.

### Planning Q&A: accepted decisions

These answers define the implementation scope; they do not claim that the behaviour is implemented. The visual direction is inspired by Mamo Business. On 2026-09-17 the owner delegated UI/theme selection and remaining implementation decisions for an overnight increment. The [UI contract](ui-contract.md) was accepted with its merge into `dev` on 2026-09-18; the remaining [implementation contracts](../architecture/implementation-contract.md) record coordinator-selected details for subsequent owner review.

| Question | Accepted answer |
|---|---|
| Q1. Which appearance modes are required? | Both light and dark. The delegated UI contract selects system-following behaviour without a manual selector for the baseline. |
| Q2. Which statuses contribute to the monthly summary? | Approved only, for both the amount total and payment count. Pending and rejected are excluded. |
| Q3. Where are pending requests visible initially? | Only in the approval overlay. Home recent payments and Payments contain approved/rejected history. A dedicated pending-payments screen is deferred to the [extension backlog](extension-backlog.md#deferred-owner-request-pending-payments-screen). |
| Q4. Which currencies are supported initially? | The demonstration data source returns AED, but every payment carries its own validated currency code and the shared data flow supports another configured currency. Do not sum different currencies. A future account/API setting may select among currencies without changing the payment contract. |
| Q5. Which timestamp drives history and monthly membership? | Decision time, newest first in history. An August request approved in September belongs to September's summary. Preserve creation time separately. |
| Q6. How are timestamps stored and which time zone defines reporting? | UTC instants in the domain; ISO 8601 with a UTC `Z` suffix in serialized records. An account-level IANA `reportingTimeZone` defines monthly boundaries and initial date display. Use `Asia/Dubai` for the demonstration account, not a global business rule or a value inferred from currency/device settings. |
| Q7. Can the approval overlay be dismissed without a decision? | No. Outside taps, swipe-to-dismiss, and Back do not close it or reject the request. Close only after a successful approve/reject operation. |
| Q8. Can the FAB create another request while one is open? | No. Keep it visible but disable request creation until the active request is decided. No queue or replacement in the initial scope. |
| Q9. Which device authentication methods are allowed? | Biometrics or the operating system's device PIN/passcode. This is not an application-owned PIN. Cancellation, failure, or unavailable device authentication never grants access. |
| Q10. Does approval require authentication first? | Yes. Successfully authenticate and reveal the active request, then explicitly select Approve. Authentication alone never approves. Reject is available without authentication. |
| Q11. What happens to revealed data after leaving the app? | Actual backgrounding remasks the active request and revokes its reveal/approval authorization. Keep the overlay open and require fresh authentication before revealing or approving again. No global app lock on return. Merely presenting the native authentication prompt is not treated as leaving the app. |
| Q12. Are payment amounts with fractional fils supported? | No. Incoming payment amounts are already expressed to whole fils (at most two decimal places). Excess business precision is invalid data, not a supported payment scenario or an invitation to silently round the requested amount. |
| Q13. Which business rounding mode is required? | None in the initial scope. The app approves existing amounts and sums them for reporting; it does not calculate amounts requiring fractional-fils rounding. Floating-point handling for valid amounts remains a technical concern, not a new product feature. |
| Q14. Which money display format is used? | Fixed English formatting, such as `AED 1,234.56`, independent of device locale: the payment's explicit currency code, comma grouping, decimal point, and exactly two decimal places. |

For monthly reporting, determine the current calendar month in the account's reporting zone, convert the start of that month and the start of the next month to UTC, and filter `decidedAt` using an inclusive start and exclusive end. Device time zone changes must not change the account's report. Date formatting is separate from the reporting zone. This contract does not select a persistent database or add a time-zone settings screen; the initial repository remains in memory.

## Core concepts

The current SDK baseline supports Android API 24+ and iOS 15+; see [ADR 0006](../decisions/0006-fvm-managed-flutter.md) for the toolchain and platform consequences.

A payment request contains an identifier, counterparty, amount, reference, creation time, and status. Status begins as pending and may transition once to approved or rejected, at which point a separate decision time is recorded.

## Acceptance criteria

### Runtime foundation

- `RUNTIME-01`: Three explicit flavor entry points use a shared bootstrap and initialize only a matching native environment before starting the app.
- `RUNTIME-02`: Unexpected startup/framework/platform errors have a local, sanitized diagnostic path; no external crash service, sensitive logs, or automatic operation replay.
- `RUNTIME-03`: Startup and build failures show safe localized UI instead of raw exceptions. Runtime logging does not navigate or reset application state; feature operations own their recovery paths.
- `PRIVACY-01`: App-switcher previews hide application content. Returning does not require authentication or reset the session. App-entry PIN and session expiry remain deferred in the extension backlog; payment reveal/authentication policy is separate.

### Home

- `HOME-01`: Show the total amount and count of payments approved during the current month, using decision time and the account's reporting time zone (`Asia/Dubai` for the demonstration account).
- `HOME-02`: Rejected and pending payments do not contribute to either summary value.
- `HOME-03`: Show recent approved and rejected payments, excluding pending requests.
- `HOME-04`: Selecting a decided payment opens its full details.

### Payments

- `PAY-01`: Show all decided payments (approved and rejected) ordered by decision time, newest first. Home recent payments use the same ordering. Pending requests are not part of this history in the initial scope.
- `PAY-02`: Each row shows the counterparty, amount, and status.
- `PAY-03`: Selecting a decided payment opens its details.
- `PAY-04`: A newly approved or rejected payment appears at the top immediately.

### Payment details

- `DETAIL-01`: Details are available only for approved or rejected payments.
- `DETAIL-02`: Back navigation returns to the screen from which details were opened.

### Incoming approval request

- `APPROVAL-01`: An incoming request opens as a confirmation overlay above the current screen, not as a replacement route.
- `APPROVAL-02`: The amount and counterparty are partially masked initially.
- `APPROVAL-03`: The payment reference remains visible.
- `APPROVAL-04`: Full amount and counterparty are revealed only after successful device authentication using biometrics or the operating system's device PIN/passcode. Unavailability, failure, and cancellation keep them masked.
- `APPROVAL-05`: Approve requires successful authentication and disclosure for the active request, followed by a separate explicit approval action. Reject does not require authentication.
- `APPROVAL-06`: Approval closes the overlay and opens the payments list.
- `APPROVAL-07`: Rejection closes the overlay and returns to the prior screen.
- `APPROVAL-08`: Either decision updates all affected screens consistently.
- `APPROVAL-09`: Outside taps, swipe-to-dismiss, and Back leave the overlay and pending request intact. Only a successful approve/reject operation closes it; an operation failure keeps it open for recovery.
- `APPROVAL-10`: Actual backgrounding remasks the active request and invalidates its reveal/approval authorization without closing the overlay or locking the app. Fresh authentication is required to reveal or initiate approval again. Ignore late authentication results from before backgrounding; the native prompt's own transient inactive state must not invalidate its success.

### Debug action

- `DEBUG-01`: A debug floating action is visible on every screen.
- `DEBUG-02`: It can be dragged to any safe position on the screen.
- `DEBUG-03`: Its position survives navigation for the current app session.
- `DEBUG-04`: When no request is active, activating it creates a deterministic incoming payment request. While a request is active, the action remains visible but request creation is disabled; repeated activation must not queue or replace requests.

### Handover

- `DELIVERY-01`: Reviewers can try the app without compiling or configuring it.
- `DELIVERY-02`: The repository explains key decisions and what would be improved with more time.

### Appearance and money display

- `UI-01`: Support light and dark appearances across screens, overlays, and loading/empty/error states, with readable contrast and status cues that do not rely on colour alone.
- `UI-02`: Run in portrait-up orientation on iOS and Android. Compact phones and expanded portrait tablets remain responsive; landscape layouts are outside the baseline.
- `MONEY-01`: The demo source uses AED, while each payment carries a validated three-letter currency code. Incoming amounts use at most two decimal places and display in fixed English form such as `AED 1,234.56` regardless of device locale. Do not sum different currencies or impose a client-side transaction maximum. Money remains represented as Dart `double`; no precision tolerance, hidden minor-unit model, or business-rounding feature is in scope.

## Product invariants

- A payment decision is final within the scope of the challenge.
- Authentication reveals sensitive data; it does not itself approve a payment.
- Failed or cancelled authentication keeps data masked and allows recovery.
- Totals, recent items, the full list, and details derive from the same authoritative payment state.
- All displayed money uses an explicit currency and consistent formatting.

## Delegated implementation details

The [UI contract](ui-contract.md) selects masks, appearance, layouts, and states. The [implementation contracts](../architecture/implementation-contract.md) select date formatting, equal-time ordering, money boundary behaviour, deterministic seed requirements, process reset, and in-flight decision handling. These are delegated choices, not additional answers attributed to the owner. Future product additions remain subject to separate agreement.
