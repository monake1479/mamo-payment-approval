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

## Core concepts

The current SDK baseline supports Android API 24+ and iOS 15+; see [ADR 0006](../decisions/0006-fvm-managed-flutter.md) for the toolchain and platform consequences.

A payment request contains an identifier, counterparty, amount, reference, creation time, and status. Status begins as pending and may transition once to approved or rejected.

## Acceptance criteria

### Runtime foundation

- `RUNTIME-01`: Three explicit flavor entry points use a shared bootstrap and initialize only a matching native environment before starting the app.
- `RUNTIME-02`: Unexpected startup/framework/platform errors have a local, sanitized diagnostic path; no external crash service, sensitive logs, or automatic operation replay.
- `RUNTIME-03`: Startup and build failures show safe localized UI instead of raw exceptions. Runtime logging does not navigate or reset application state; feature operations own their recovery paths.
- `PRIVACY-01`: App-switcher previews hide application content. Returning does not require authentication or reset the session. App-entry PIN and session expiry remain deferred in the extension backlog; payment reveal/authentication policy is separate.

### Home

- `HOME-01`: Show a current-month payment summary.
- `HOME-02`: Rejected payments do not contribute to the summary.
- `HOME-03`: Show recent payments.
- `HOME-04`: Selecting a decided payment opens its full details.

### Payments

- `PAY-01`: Show all payments ordered newest first.
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
- `APPROVAL-04`: Full amount and counterparty are revealed only after successful device authentication.
- `APPROVAL-05`: The user can approve or reject the request.
- `APPROVAL-06`: Approval closes the overlay and opens the payments list.
- `APPROVAL-07`: Rejection closes the overlay and returns to the prior screen.
- `APPROVAL-08`: Either decision updates all affected screens consistently.

### Debug action

- `DEBUG-01`: A debug floating action is visible on every screen.
- `DEBUG-02`: It can be dragged to any safe position on the screen.
- `DEBUG-03`: Its position survives navigation for the current app session.
- `DEBUG-04`: Activating it creates a deterministic incoming payment request.

### Handover

- `DELIVERY-01`: Reviewers can try the app without compiling or configuring it.
- `DELIVERY-02`: The repository explains key decisions and what would be improved with more time.

## Product invariants

- A payment decision is final within the scope of the challenge.
- Authentication reveals sensitive data; it does not itself approve a payment.
- Failed or cancelled authentication keeps data masked and allows recovery.
- Totals, recent items, the full list, and details derive from the same authoritative payment state.
- All displayed money uses an explicit currency and consistent formatting.

## Clarifications to decide during implementation

- Exact definition of the current-month summary: approved-only versus approved plus pending.
- Reporting calendar/time zone and whether the summary uses creation or decision time.
- Ordering when an older pending request is decided: reconcile newest-first with newly decided items appearing at the top.
- Exact mask format for the counterparty and amount.
- Native authentication fallback policy when biometrics are unavailable.
- Overlay dismissal/back behaviour, repeated incoming requests, and reveal state on background/resume.
- Whether pending rows appear outside the overlay and how they avoid exposing full sensitive data before authentication.
- Final seeded dataset, currency, and locale.
