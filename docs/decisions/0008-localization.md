# ADR 0008: Generated localization resources

- Status: Accepted
- Date: 2026-09-17

## Context and alternatives

The owner requires centrally managed text using `intl` and `AppLocalizations`, including replacement of existing inline UI strings. Hardcoded widget copy and a hand-written string registry would not provide generated message access, locale resolution, or plural/placeholder support.

## Decision

Use Flutter's built-in `gen-l10n` with `flutter_localizations` from the pinned SDK and a compatible `intl` dependency. Author messages in `lib/l10n/app_en.arb`; `l10n.yaml` generates `AppLocalizations` under `lib/l10n/generated/`. No additional generator package or custom localization service is needed.

English is the only supported locale. Use the generated delegates and supported locales in `MaterialApp`; unsupported device locales resolve to English. Generate the application title through `onGenerateTitle`, where the localization context exists.

Widgets access `AppLocalizations.of(context)`. Keep human-readable text for headings, buttons, errors, tooltips, accessibility labels, and other Flutter UI in ARB. Include English message descriptions; use typed placeholders and ICU plurals/selects instead of concatenating sentences. Stable test identifiers, protocol values, and user/payment data are not translation keys.

Localization remains in presentation and app composition. Domain/data contracts must not depend on Flutter localization or return pretranslated errors. Currency, rounding, and money serialization remain deferred under ADR 0002; adding `intl` does not settle them.

## Native string boundary

The OS launcher and native permission dialogs operate outside the Dart widget tree. Their text belongs in Android resources/manifest or iOS bundle resources/settings, not `AppLocalizations`. Current flavor launcher names are defined by ADR 0007; native permission copy will be added with the capability that needs it. Do not build a custom ARB-to-native generator for three fixed launcher labels.

## Generation and verification

- Commit ARB input and `l10n.yaml`, not generated Dart files. Regenerate via `fvm flutter gen-l10n`; never edit generated output manually. `generate: true` also enables generation during checkout preparation with `flutter pub get`.
- Run generation before the local quality gate. CI explicitly generates before formatting, analysis, and tests, so a fresh checkout does not depend on a developer's generated files.
- Require resource descriptions and format generated files through generator options. Do not suppress generator warnings.
- Test localized title/body rendering, regional-English and unsupported-locale fallback, and compact/expanded layouts with large text. Keep the existing English copy and centered composition; allow scrolling when enlarged text exceeds the viewport.
- Native builds verify dependency and generated-source integration; no external translation service or additional locale is introduced.

## Error-message boundary

Application operations and state controllers carry typed failures with stable codes/slugs and only safe parameters. A presentation method or mapper resolves those codes through `AppLocalizations`; domain/data/controller code does not depend on localization or return ready-made user messages. External codes are normalized at the data boundary. Known failures are mapped exhaustively, and unknown codes receive a safe localized fallback instead of displaying a raw exception or server message. Codes are not ARB keys.

Introduce and test each mapper with its first concrete failure-producing operation. The runtime foundation now maps three actual startup/runtime failure codes through `AppFailureMessage`, with exhaustive mapping and layout tests; see ADR 0010. Payment failure codes remain deferred until needed.

## References

- [Flutter internationalization](https://docs.flutter.dev/ui/internationalization)
