# Device authentication

This slice provides the native authentication boundary for `APPROVAL-04`,
`APPROVAL-05`, and the stale-result part of `APPROVAL-10`. It does not reveal or
approve a payment by itself and does not add a production authentication fake.

## Contract and integration

`DeviceAuthenticator.authenticate(localizedReason:)` returns one of four domain
outcomes: succeeded, cancelled, unavailable, or failed. Presentation obtains the
reason from `AppLocalizations` and supplies it when composing the approval state
owner; domain and data code do not import localization. Use wording equivalent to
"Authenticate to reveal payment details." in the English ARB resource.

Call `cancel()` when the active request is invalidated, the approval state owner is
disposed, or actual backgrounding revokes disclosure. Cancellation invalidates the
active generation before requesting native prompt closure, so a late success is
reported as cancelled. Its typed result distinguishes no active attempt, a stopped
prompt, and a failed prompt stop without exposing plugin exceptions. A new attempt
is rejected while native cancellation is settling. The UI must still scope success
to the same active request.

The adapter allows biometrics or the operating system credential, treats the
operation as sensitive, and does not persist authentication across backgrounding.
That leaves background-versus-native-prompt lifecycle policy with the approval
state owner instead of letting the plugin automatically retry.

## Native setup

All Android flavors share `USE_BIOMETRIC`, `FlutterFragmentActivity`, and an
AppCompat DayNight launch theme. The existing Android recents-screenshot safeguard
remains in `MainActivity` on API 33 and newer. Older supported Android versions use
`FLAG_SECURE`, which also disables ordinary screenshots and screen recording while
the activity is visible. All iOS flavors share the Face ID usage description and
retain the existing scene privacy cover.

The implementation follows the official [`local_auth` 3.0.2 API](https://pub.dev/packages/local_auth)
and its endorsed [Android](https://pub.dev/packages/local_auth_android) and
[Darwin](https://pub.dev/packages/local_auth_darwin) setup documentation. Adapter unit tests use an injected
plugin-facing client and cover result normalization, options, duplicate attempts,
cancellation, and late completions. They do not constitute emulator, simulator,
installation, biometric, passcode, or physical-device evidence.
