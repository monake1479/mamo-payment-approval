# Runtime foundation contract

Scope: `RUNTIME-01..03`; shared bootstrap, flavor-scoped dependency composition,
and safe unexpected-error handling. Payment behaviour, networking, persistence,
app-entry PIN, session expiry, and payment authentication are excluded.

## Startup and ownership

Each thin entry point passes its environment to the common bootstrap. The native
flavor must match before dependencies initialize, including release mode. Native
launch UI remains visible during initialization; there is no artificial delay or
second Flutter loading page. Bootstrap awaits configuration of one process-wide
`getIt`, installs error handlers, and calls `runApp`. Dependencies are resolved in
composition and passed to consumers through constructors. The app root is stateless;
there is no startup controller, fatal-state notifier, or synthetic environment adapter.

## Failure screen

Normal app composition uses the DI-owned `GoRouter` through `MaterialApp.router`.
The `/` route renders the existing foundation page. Unknown paths reuse the safe
localized unexpected-error view, never raw route exceptions or URIs. Router
identity and location survive root rebuilds. `AppFailureApp` renders startup/build
failures without requiring a router; no new layout or visual direction is introduced.

- Entry: invalid environment or failed startup selects the failure app before normal
  launch. A build exception uses Flutter's error-widget callback. Other framework
  and platform errors are logged without global navigation or app-state replacement.
- Content: localized heading and code-specific safe explanation.
  No raw exception, stack, payment, or authentication data.
- Exit: close and restart the app. No retry button or automatic operation replay;
  the screen does not assert whether a pending business operation succeeded.
- Appearance: existing light theme; centered icon/text column, 24-pixel padding,
  maximum width 520, gaps 24/12. Reuse these tokens on the foundation page.
- Compact/expanded: safe area, width constraint, vertical scrolling; no breakpoint
  needed for this single column. Verify 320x640 and 1024x768 at 200% text size.
- Accessibility: readable text, non-colour error cue, live-region semantics with
  stable identifier `app.failure`. No tappable controls, focus trap, or animation.
- Empty/data/submitting are not states of this terminal screen. Success continues
  to the existing foundation page without changing its product content.

## Verification map

- `RUNTIME-01`: bootstrap tests cover all flavor registrations, mismatch/missing
  flavor validation, and rejection before dependency registration.
- `RUNTIME-02`: tests cover framework/platform logging,
  bounded allowlisted diagnostics, and exceptions that must never be stringified.
- `RUNTIME-03`: widget tests cover every localized code, layout/text scale,
  semantics, and localized fallback for an actual throwing widget without ancestors.
- Native smoke flow verifies normal launch. A separately built mismatched
  entrypoint/native-flavor pair verifies configuration failure without a shipping
  fault-injection flag. Native evidence remains distinct from widget coverage.

## Native privacy step

`PRIVACY-01` introduces no Flutter state or authentication. On iOS, a plain opaque
black native cover is placed above the existing window when the scene becomes
inactive and removed when active again. It resizes with the window and does not
replace navigation/content. It contains no readable copy or interaction. A native
cover is needed before the OS captures a snapshot, independently of Dart frames.
On Android 13+, disable recents screenshots through the Activity API; the system
may substitute its window background. Normal foreground screenshots remain allowed.

Android 12 and older are **not protected yet**: approval of the broader
`FLAG_SECURE` screenshot restriction is pending. This is an explicit incomplete
criterion, not a claim of complete cross-version protection. No foreground
screenshot restriction is added without that choice.

Native checks must verify the preview visually, repeated background/resume,
preserved content, and no reauthentication. Swift tests cover opaque/idempotent
cover insertion/removal and resizing setup, not the OS snapshot itself. Future
payment-auth implementation must verify native prompt and reveal lifecycle
separately. App-entry PIN/expiry are not part of the cover.

References: [Apple background preparation](https://developer.apple.com/documentation/UIKit/preparing-your-ui-to-run-in-the-background),
[Android recents screenshots](https://developer.android.com/reference/android/app/Activity#setRecentsScreenshotEnabled(boolean)).
