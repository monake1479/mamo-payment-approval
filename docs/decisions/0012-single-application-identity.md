# ADR 0012: Single application identity (Mamo Approval)

- Status: Accepted
- Date: 2026-09-21
- Supersedes the identity table of [ADR 0007](0007-native-flavors.md); the flavor mechanism (schemes, entry points, configuration mappings) in ADR 0007 remains in force.

## Context and alternatives

The owner rebranded the application to the display name **Mamo Approval** and requested the exact application/bundle identifier `mamo.payment.approval` for every flavor. ADR 0007 had given each flavor a distinct suffixed identity (`.dev`, `.staging`) and launcher name (`Mamo Dev`, `Mamo Staging`, `Mamo`) so the three installations could coexist on one device.

Two ways to honour the rebrand were considered:

1. Keep per-flavor suffixes on the new base (`mamo.payment.approval`, `.dev`, `.staging`) and rename only the launcher labels. Preserves side-by-side installation.
2. Collapse all flavors to the single exact identifier `mamo.payment.approval` and the single launcher name `Mamo Approval`. Matches the owner's literal instruction.

## Decision

Adopt option 2. Every Android flavor and every iOS scheme ships:

| Property | Value (all flavors) |
|---|---|
| Launcher / display name | `Mamo Approval` |
| Android `applicationId` | `mamo.payment.approval` |
| iOS `PRODUCT_BUNDLE_IDENTIFIER` | `mamo.payment.approval` |

The identifier is intentionally **not** reverse-DNS. It is a valid Android application ID (three label segments, each starting with a letter) and a valid iOS bundle identifier, and both toolchains accept it; the `dev`/`prod` builds were verified. The iOS `RunnerTests` bundle identifier becomes `mamo.payment.approval.RunnerTests`.

The Android source `namespace` and Kotlin package remain `com.danieloblak.mamo_payment_approval_challenge`. Namespace is internal (it names the generated `R`/`BuildConfig` package) and is independent of the installed application ID; `mamo.payment.approval` is unconventional as a Java/Kotlin package, so it was left unchanged to minimise build risk. This can be aligned later as isolated, mechanical work if desired.

The Dart package (`pubspec.yaml` `name`) cannot contain dots, so it was renamed `mamo_approval` with a full `package:` import sweep and code generation regenerated.

## Consequences

- The three flavors share one installation identity, so `dev`, `staging`, and `prod` **can no longer be installed side by side** on one device; installing one replaces another. This reverses the isolation benefit ADR 0007 provided. Flavors are retained only to select the Dart entry point and native scheme.
- Store uniqueness: a single identity means one App Store / Play listing space; the flavors are not separately publishable identities.
- Maestro still receives the installed flavor's platform ID; that ID is now identical across flavors.
- Placeholder launcher icon and native splash were introduced with this rebrand (brand colour `#6938EF` from `app_theme`, white `MA` monogram); they are placeholders to be replaced before release.

## Verification

Android `dev` (debug) and `prod` (release) APKs report `package='mamo.payment.approval'` and `application-label='Mamo Approval'`. iOS `dev` (simulator debug) and `prod` (unsigned device release) builds report `CFBundleIdentifier=mamo.payment.approval` and `CFBundleDisplayName=Mamo Approval`. Format, analyze, the full Flutter suite, and the tooling tests pass. A successful build is not installation, native-authentication, or signed-distribution evidence.

## References

- [ADR 0007: Native flavors](0007-native-flavors.md)
- [Flutter Android flavors](https://docs.flutter.dev/deployment/flavors)
