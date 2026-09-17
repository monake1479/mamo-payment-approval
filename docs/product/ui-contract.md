# Payment UI Contract

Status: selected for implementation under delegated design authority on 2026-09-17; owner review remains pending. This is the shared baseline for feature branches, not a claim that the screens exist.

## Visual direction

Use a restrained business-payment interface: neutral surfaces, generous spacing, rounded cards, strong amount hierarchy, and a violet primary action. The public [Mamo Business listing](https://play.google.com/store/apps/details?id=com.mamopay.business.app) informs the visual direction; these are app-owned token choices, not an official brand specification. No downloaded logos, fonts, or marketing assets are required.

`AppTheme` owns light/dark Material themes, spacing, radii, touch targets, and layout thresholds. Follow system appearance; no manual theme switch or persistence in this increment. Both normal app composition and standalone failure UI support both appearances. Use system typography via `TextTheme`. Status uses a readable word and icon, never colour alone. Use the existing Material error palette for rejected/error states; approved can use primary tones with a check icon, avoiding another palette abstraction until needed.

## Shared layout

- Use constraints, not device identity. Below 720 logical pixels, use 16-pixel page insets and bottom navigation for Home/Payments. At or above 720, use a navigation rail and centered content up to 1040 pixels with 24-pixel insets.
- Use 24-pixel section gaps, 12-pixel item gaps, 8-pixel tight gaps, 20-pixel card radii, and 14-pixel control radii. Reuse `AppTheme` constants; add a token only for a concrete repeated requirement.
- Allow text wrapping, scrolling, and taller controls at 200% text scale; do not truncate the only accessible amount/party value or use fixed-height cards. Every interactive target is at least 48 by 48 logical pixels.
- Keep English UI copy in ARB, including empty/error/loading states, hints, status, accessibility labels, and authentication prompts. User data and stable semantics identifiers are not localization keys.
- No speculative animations, custom font dependency, repaint boundaries, or caching. Respect system reduced-motion behaviour for any added transitions.

## Screens and transitions

| Surface | Composition and behaviour |
|---|---|
| Home | Month heading with account reporting-zone context, approved amount total and approved count, then up to five recent decided payments and a View all action. Summary and recent list derive from the same collection. |
| Payments | All approved/rejected history newest decision first. Each tappable row contains party, fixed-format amount, status text/icon, and decision date. No pending list, search, filters, or pagination in baseline. |
| Details | Back action, status, prominent amount, party, visible reference, request time and decision time. Open with a pushed route from Home or Payments; back returns to that origin. Resolve by stable ID against canonical state. Missing/invalid IDs produce safe localized UI. |
| Incoming request | Non-dismissible confirmation above the existing route. Compact layouts use a scrollable bottom sheet; expanded layouts a centered constrained dialog. Show heading, masked party/amount, visible reference, Reveal details, Reject, and Approve. Approve is disabled until authenticated disclosure. Keep actions reachable at large text sizes. |
| Debug action | Draggable, labelled incoming-request action above the route and above the approval barrier. Remains visible but disabled while a request exists. Position survives navigation for the session, clamps to safe bounds after resize/rotation, and dragging does not activate it. |

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

`UI-01`, `HOME-01..04`, `PAY-01..04`, `DETAIL-01/02`, `APPROVAL-01..10`, and `DEBUG-01..04` map to their feature tests as implemented. Exercise both appearances at 320x640 and 1024x768 logical pixels with normal and 200% text, plus rotation/safe-area changes for the floating action. Check primary/body text contrast, status labels, touch targets, overlay semantics, and origin-preserving navigation. Widget tests cover exhaustive states; Maestro covers critical native journeys. Retain screenshots from synthetic data and label simulated authentication separately from physical-device evidence.
