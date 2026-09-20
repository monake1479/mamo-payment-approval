# Read-only payment screens

Status: implemented on the feature branch; rebased onto the accepted shared payments architecture, theme, and navigation foundation.

## Behaviour

- Home shows the current `Asia/Dubai` account month, approved-only amount/count, and up to five recent decided payments.
- Payments shows every approved or rejected payment newest decision first, labels its timestamps with the account reporting zone, and never includes pending requests.
- Home and Payments form one directly manipulated horizontal pager: the surfaces follow the pointer during a drag, then settle on the destination or return to the origin. Compact/expanded navigation controls remain equivalent entry points.
- Home is the start destination: reaching Payments (View all, a navigation control, or a swipe) pushes no route, so system Back returns to Home instead of leaving the app, and only Home exits.
- Selecting a row pushes `/payments/payment/:paymentId` above the Home/Payments shell, so details have no bottom navigation or rail and system Back returns to the exact origin.
- Details resolve the stable identifier against live canonical collection state. Decided content starts at the top with the amount, followed by one card containing the counterparty, status directly beneath it, and the remaining payment information. Missing, invalid, or pending identifiers show localized safe UI.
- Compact widths use bottom navigation; widths at or above 720 logical pixels use a rail. Both use the shared light/dark themes and support 200% text without fixed-height payment cards.
- Shared motion drives indexed Home/Payments switches, pushed details routes, and loading-to-content entrances; iOS retains its interactive edge-back transition, and reduced-motion settings render final states immediately.
- The app composition owns initial loading, dependency wiring, account-month refresh on resume, and a root builder reserved for the later approval/debug layer.
- Date formatting uses `intl` with an explicit English locale after conversion to the account zone; month names are not a second hand-maintained text catalogue.

## States and exclusions

Loading does not present stale totals as current. A loaded empty collection shows `AED 0.00` and an empty recent/history explanation. Typed load failures map to safe localized copy and an explicit retry. Approval, authentication, incoming-request masking, and the draggable debug action are not implemented by this slice.

## Verification

Widget coverage includes fixed AED/account-zone formatting, status/row semantics, loading/empty/error/success, compact/expanded navigation and horizontal switching, light/dark appearances, 200% text, missing identifiers, canonical live detail resolution, full-screen details, system/iOS gesture back, exact origin return, unknown routes, and resume-driven month rollover. Maestro flows cover deterministic list/summary and details-origin journeys; native evidence must identify the installed flavor and binary separately.
