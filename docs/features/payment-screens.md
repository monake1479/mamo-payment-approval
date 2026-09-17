# Read-only payment screens

Status: implemented on the feature branch; dependent on the unmerged theme and payments-data ancestors.

## Behaviour

- Home shows the current `Asia/Dubai` account month, approved-only amount/count, and up to five recent decided payments.
- Payments shows every approved or rejected payment newest decision first, labels its timestamps with the account reporting zone, and never includes pending requests.
- Selecting a row pushes decided-payment details within the active Home or Payments branch, so Back returns to the exact origin.
- Details resolve the stable identifier against live canonical collection state. Missing, invalid, or pending identifiers show localized safe UI.
- Compact widths use bottom navigation; widths at or above 720 logical pixels use a rail. Both use the shared light/dark themes and support 200% text without fixed-height payment cards.
- The app composition owns initial loading, dependency wiring, account-month refresh on resume, and a root builder reserved for the later approval/debug layer.

## States and exclusions

Loading does not present stale totals as current. A loaded empty collection shows `AED 0.00` and an empty recent/history explanation. Typed load failures map to safe localized copy and an explicit retry. Approval, authentication, incoming-request masking, and the draggable debug action are not implemented by this slice.

## Verification

Widget coverage includes fixed AED/account-zone formatting, status/row semantics, loading/empty/error/success, compact/expanded navigation, light/dark appearances, 200% text, missing identifiers, canonical live detail resolution, exact origin return, unknown routes, and resume-driven month rollover. Maestro flows cover deterministic list/summary and details-origin journeys; native evidence must identify the installed flavor and binary separately.
