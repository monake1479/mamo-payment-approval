# Device authentication

This slice provides the native authentication boundary for `APPROVAL-04`,
`APPROVAL-05`, and the stale-result part of `APPROVAL-10`. It does not reveal or
approve a payment by itself and does not add a production authentication fake.

## Contract and integration

`DeviceAuthenticator.authenticate(localizedReason:)` returns the shared
`Result<DeviceAuthenticationFailure, Unit>` contract. Success carries `Unit`;
the Freezed failure union distinguishes cancelled, unavailable, and failed.
Presentation obtains the reason from `AppLocalizations` and supplies it when
composing the approval state owner; the capability does not import localization.
Use wording equivalent to "Authenticate to reveal payment details." in the
English ARB resource.

Call `cancel()` when the active request is invalidated, the approval state owner is
disposed, or actual backgrounding revokes disclosure. Cancellation invalidates the
active generation before requesting native prompt closure, so a late success is
reported as cancelled. Its typed result distinguishes no active attempt, a stopped
prompt, and a failed prompt stop without exposing plugin exceptions. Native
occupancy remains reserved until the previous `authenticate()` future settles, even
when prompt stopping returns false or throws (as on iOS); a new attempt is rejected
until then. The UI must still scope success to the same active request.

This is a deliberate safety-over-liveness tradeoff: if the underlying native
`authenticate()` future never settles (a plugin or OS defect), occupancy stays
reserved for the process lifetime and every later attempt is rejected. The
capability intentionally has no timeout or forced reset; recovery from a wedged
native prompt is left to the future approval state owner rather than risking a
late completion that resolves after a forced reset.

The adapter allows biometrics or the operating system credential, treats the
operation as sensitive, and does not persist authentication across backgrounding.
That leaves background-versus-native-prompt lifecycle policy with the approval
state owner instead of letting the plugin automatically retry.

The capability and adapter live under `lib/common/data/device_authentication/`,
the typed failure lives under `lib/common/error_handling/`, and generated DI binds
the production adapter as a lazy-singleton `DeviceAuthenticator`. Future approval
presentation calls this capability rather than a repository or data source. This
slice adds no widgets, routes, dialogs, sheets, indexed pages, or payment-status UI,
so `AppTheme`, `AppMotion`, `PaymentStatusChip`, and shared transition primitives
remain owned by the accepted presentation baseline without feature-local copies.

## Native setup

All Android flavors share `USE_BIOMETRIC`, `FlutterFragmentActivity`, and an
AppCompat DayNight launch theme. The existing Android recents-screenshot safeguard
remains in `MainActivity` on API 33 and newer. Older supported Android versions use
`FLAG_SECURE`, which also disables ordinary screenshots and screen recording while
the activity is visible. The merged application baseline locks Android, iOS, and
Flutter composition to portrait-up. All iOS flavors share the Face ID usage
description and retain the existing scene privacy cover. The iOS Face ID usage
string in `Info.plist` duplicates the canonical ARB reason because platform
permission strings cannot be sourced from ARB; keep the two in sync, or add an
`InfoPlist.strings` if this string ever needs localization.

The implementation follows the official [`local_auth` 3.0.2 API](https://pub.dev/packages/local_auth)
and its endorsed [Android](https://pub.dev/packages/local_auth_android) and
[Darwin](https://pub.dev/packages/local_auth_darwin) setup documentation. Adapter unit tests use an injected
plugin-facing client and cover result normalization, options, duplicate attempts,
cancellation, and late completions. They do not constitute emulator, simulator,
installation, biometric, passcode, or physical-device evidence.
