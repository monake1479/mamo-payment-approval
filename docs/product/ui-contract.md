# Payment UI Contract

Status: selected for implementation under delegated design authority on 2026-09-17; owner review remains pending. This is the shared baseline for feature branches, not a claim that the screens exist.

## Visual direction

Use a restrained business-payment interface: neutral surfaces, generous spacing, rounded cards, strong amount hierarchy, and a violet primary action. The public [Mamo Business listing](https://play.google.com/store/apps/details?id=com.mamopay.business.app) informs the visual direction; these are app-owned token choices, not an official brand specification. No downloaded logos, fonts, or marketing assets are required.

`AppTheme` owns light/dark Material themes, spacing, radii, touch targets, layout thresholds, outlined field states, chips, navigation surfaces, dividers, and fixed snackbars. Follow system appearance; no manual theme switch or persistence in this increment. Both normal app composition and standalone failure UI support both appearances. Use system typography via `TextTheme`. Payment status uses the shared `PaymentStatusChip`, which combines a localized word and icon so meaning never depends on colour alone. Rejected uses the Material error palette, approved uses primary tones, and pending uses a contrasting amber container in both appearances. Informational feedback uses a dedicated blue container so it remains distinct from primary-toned success feedback.

## Shared layout

- Use constraints, not device identity. Below 720 logical pixels, use 16-pixel page insets and bottom navigation for Home/Payments. At or above 720, use a navigation rail and centered content up to 1040 pixels with 24-pixel insets.
- Lock the shipping app to portrait-up on iOS and Android. Expanded behaviour supports portrait tablets and other portrait viewports at or above the breakpoint; landscape layouts are outside the baseline.
- Use 24-pixel section gaps, 12-pixel item gaps, 8-pixel tight gaps, 20-pixel card radii, and 14-pixel control radii. Reuse `AppTheme` constants; add a token only for a concrete repeated requirement.
- Allow text wrapping, scrolling, and taller controls at 200% text scale; do not truncate the only accessible amount/party value or use fixed-height cards. Every interactive target is at least 48 by 48 logical pixels.
- Clip every interactive Material surface and its ink response to the same app-owned shape. A rounded list row or card must never show a rectangular hover, focus, or ripple effect.
- Keep English UI copy in ARB, including empty/error/loading states, hints, status, accessibility labels, and authentication prompts. User data and stable semantics identifiers are not localization keys.
- No speculative animations, custom font dependency, repaint boundaries, or caching.

## Motion

`AppMotion` is the source of truth for durations, easing, entrance distance, and stagger. Loading-to-data transitions fade out the labelled loading state, then reveal the data groups from bottom to top over 280 milliseconds with a 56-millisecond stagger and a 16-pixel maximum offset. Animate meaningful groups, not every decorative descendant.

Run an entrance once when a state genuinely changes from loading to data; ordinary rebuilds, filtering, and scrolling must not replay it. Motion never delays interaction, hides an operation result, or substitutes for explicit loading/error status. Destructive and financial decisions do not use celebratory movement. When the platform requests reduced motion, state changes are immediate and content renders in its final position without translation.

Modal bottom sheets and centered dialogs retain their platform Material surface transitions and always animate meaningful content groups with `AppBottomSheetStaggeredColumn` and `AppDialogStaggeredColumn`, respectively. Their content animations are gated until the route is visibly on screen, beginning when a sheet reaches 65% and a dialog reaches 45% of its surface transition; starting content while its surface is still off screen makes the motion imperceptible. Treat the heading and explanation as one group and the actions as the next; do not stagger every text node or icon independently.

Pushed `go_router` destinations use `AppMotionPage`; indexed top-level destinations use `AppPageTransitionSwitcher`. Forward navigation moves two opaque page surfaces edge to edge: the current page leaves through the leading edge while the incoming page enters from the trailing edge. Pages must not fade through or visually overlap because duplicated text and controls make the transition unreadable. Backward navigation mirrors the direction. Navigation state changes before the visual transition, interactions are never delayed, and reduced motion replaces the transition immediately. Do not combine these shared transitions with screen-local transforms on the whole page.

## Screens and transitions

| Surface | Composition and behaviour |
|---|---|
| Home | Month heading with account reporting-zone context, approved amount total and approved count, then up to five recent decided payments and a View all action. Summary and recent list derive from the same collection. |
| Payments | All approved/rejected history newest decision first. Each tappable row contains party, fixed-format amount, status text/icon, and decision date. No pending list, search, filters, or pagination in baseline. |
| Details | Back action, status, prominent amount, party, visible reference, request time and decision time. Open with a pushed route from Home or Payments; back returns to that origin. Resolve by stable ID against canonical state. Missing/invalid IDs produce safe localized UI. |
| Incoming request | Non-dismissible confirmation above the existing route. Compact layouts use a scrollable bottom sheet; expanded layouts a centered constrained dialog. Show heading, masked party/amount, visible reference, Reveal details, Reject, and Approve. Approve is disabled until authenticated disclosure. Keep actions reachable at large text sizes. |
| Debug action | Draggable, labelled incoming-request action above the route and above the approval barrier. Remains visible but disabled while a request exists. Position survives navigation for the session, clamps to safe bounds after viewport or safe-area changes, and dragging does not activate it. |

Use separate widget classes for meaningful subtrees. Navigation belongs to app composition; controllers report outcomes without retaining `BuildContext`.

## State contract

- Loading: labelled progress without stale totals presented as current.
- Empty: a concise explanation and the always-available request action; a zero monthly total is valid data, not an error.
- Error: localized message from a typed failure, explicit retry, no raw exception or payment data in logs.
- Authentication: disable duplicate reveal/decision taps while active; cancellation/unavailability keeps masks and offers retry or Reject. No authentication bypass or shipping fake.
- Submitting: disable decisions and keep overlay until repository success. On failure, keep it open with retry. Successful approval updates canonical state before closing and selecting Payments; rejection updates state before closing over the unchanged route.
- Background: remask the request and revoke pending disclosure authorization; distinguish native-auth prompt inactivity from actual background. No global lock on resume.
- Masked recipient: first grapheme followed by four bullets (empty input uses bullets only). Masked amount: `AED ••••.••`, independent of the actual amount's length. Reference stays visible. Semantics and copyable content must not contain the hidden full values.

## Verification

`UI-01/02`, `HOME-01..04`, `PAY-01..04`, `DETAIL-01/02`, `APPROVAL-01..10`, and `DEBUG-01..04` map to their feature tests as implemented. Exercise both appearances at 320x640 and 768x1024 portrait logical pixels with normal and 200% text, plus safe-area changes for the floating action. Verify the native portrait declarations and the Flutter orientation request. Check primary/body text contrast, status labels, touch targets, overlay semantics, and origin-preserving navigation. Widget tests cover exhaustive states; Maestro covers critical native journeys. Retain screenshots from synthetic data and label simulated authentication separately from physical-device evidence.
