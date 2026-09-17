# Incoming approval flow

Status: implemented on the approval feature branch; native and review evidence remains required before promotion.

## Scope

This increment implements `APPROVAL-01..10`, `DEBUG-01..04`, and the incoming-decision part of `PAY-04` on top of the theme, payment-state, native-authentication, and read-only-screen increments. It keeps one session-scoped pending request, uses the production `local_auth` adapter in application composition, and does not add persistence, a queue, or an authentication bypass.

`PaymentsCubit` remains the canonical collection owner. A short-lived `ApprovalCubit` holds the pending request snapshot, authentication disclosure authorization, submission state, and one terminal decision effect. The application layer keeps that controller and its non-dismissible popup route alive until the canonical decision result is consumed, even though the pending item leaves `PaymentsState` before the decision callback returns.

## Interaction and lifecycle

- The draggable request action is rendered above the router and modal barrier. Its
  session position survives route changes, defaults above compact bottom
  navigation, and clamps to current safe bounds after layout changes. Drag gestures
  do not activate it. While a request is active, the action remains visibly disabled
  at its saved position and ignores taps and drags so it cannot intercept approval
  controls; interaction resumes after the overlay closes.
- The approval popup retains the underlying route. Outside taps, swipes, and Back cannot dismiss it. Rejection updates canonical state before closing and leaves the router location unchanged; approval updates canonical state before closing and selects Payments.
- Counterparty and amount widgets contain only masks until successful native authentication. The reference remains visible. Authentication success reveals but never decides; approval requires a separate action, while rejection does not authenticate.
- Native-prompt-only `inactive` lifecycle events are ignored. `hidden` or `paused` revokes disclosure, invalidates an in-flight authentication result, and explicitly attempts prompt cancellation. A submitted decision may complete once while backgrounded; its route/navigation effect is consumed once after resume.

## Verification mapping

- `test/features/payments/presentation/cubit/approval_cubit_test.dart` covers authentication outcomes, authorization, duplicate actions, background cancellation/remasking, submitted-decision completion, recoverable failures, and disposal races.
- `test/app/approval_flow_test.dart` covers masking in visual and semantic content, non-dismissal, origin preservation, explicit approval navigation, canonical ordering, lifecycle distinction, deferred completion, draggable/clamped session position, reduced motion, failures, themes, compact/expanded layouts, and 200% text.
- `maestro/approval_rejection.yaml`, `maestro/approval_origins.yaml`, and
  `maestro/debug_action.yaml` cover deterministic Home rejection,
  Payments/details origin preservation, and the global-action journey.
  `maestro/approval_success_prepare.yaml` and
  `maestro/approval_success_verify.yaml` bracket a real operating-system
  authentication event so the separate explicit approval and canonical cross-view
  update have repeatable assertions. The event itself uses labelled simulator/device
  input and separate evidence; no fake is present in reviewer composition.
