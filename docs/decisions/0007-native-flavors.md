# ADR 0007: Native flavors

- Status: Accepted
- Date: 2026-09-17

## Context and alternatives

The owner requested `dev`, `staging`, and `prod` from the foundation stage. Separate installation identities let development, verification, and reviewer builds coexist without replacing one another.

Dart defines alone cannot select native installation identities. Native flavors establish those identities; thin Dart entry points make launch intent explicit without duplicating bootstrap logic. A flavor-generation dependency is unnecessary for three variants.

## Decision

Use Android product flavors in one `environment` dimension and shared iOS schemes named `dev`, `staging`, and `prod`. Each iOS scheme maps Run/Test/Analyze to `Debug-<flavor>`, Profile to `Profile-<flavor>`, and Archive to `Release-<flavor>` for the same Runner target. The project and RunnerTests expose matching configurations. Retain Flutter's Debug/Release xcconfig inheritance; Profile uses Release settings.

| Flavor | Launcher name | Android application ID | iOS bundle ID |
|---|---|---|---|
| `dev` | Mamo Dev | `com.danieloblak.mamo_payment_approval_challenge.dev` | `com.danieloblak.mamoPaymentApprovalChallenge.dev` |
| `staging` | Mamo Staging | `com.danieloblak.mamo_payment_approval_challenge.staging` | `com.danieloblak.mamoPaymentApprovalChallenge.staging` |
| `prod` | Mamo | `com.danieloblak.mamo_payment_approval_challenge` | `com.danieloblak.mamoPaymentApprovalChallenge` |

Keep the existing base identifiers for `prod`. Android's source namespace remains unchanged. Flavor and build mode are independent: all three support debug, profile, and release. `default-flavor: dev` makes ordinary local commands safe by default; distribution and E2E commands must still name the intended flavor explicitly.

Use `lib/main_dev.dart`, `lib/main_staging.dart`, and `lib/main_prod.dart` with a shared bootstrap (ADR 0010). This supersedes the initial single-entrypoint arrangement. Commands pair `--flavor <name>` with `-t lib/main_<name>.dart`; Xcode Runner configurations and VS Code launches encode this pair. Runtime validation rejects disagreement with native `appFlavor`, also in release. Do not create another selector via `--dart-define`, speculative API URLs, secrets, or flavor-specific business rules.

## Consequences

- VS Code launch configurations and Xcode schemes use the same flavor names.
- Separate native identifiers isolate each installation's app sandbox. This does not introduce persistence or separate backend environments.
- The required debug request action is a product capability, not conditional on flavor or build mode.
- Flavors do not permit an authentication bypass, additional sensitive logging, or production test fakes.
- Android release builds remain debug-key-signed until distribution signing is configured. iOS device signing/provisioning remains separate work; flavor names do not establish store readiness.
- No Podfile exists at this stage. If a native dependency introduces CocoaPods, map all nine configurations to their debug/release modes and preserve Flutter xcconfig inheritance in that change.
- CI runs the shared Flutter quality gate. Native flavor compilation is currently a local gate, not an existing CI matrix.

## Verification

After native flavor configuration changes, build each Android flavor in debug and release and each iOS flavor for the simulator and as an unsigned release device build. Inspect packaged IDs and display names, and check all nine Xcode configuration mappings. Check profile compilation when its settings change. A successful build is not installation, native-authentication, or signed-distribution evidence.

Record artifact hashes and source inputs using the verification template. iOS output paths are reused across flavors, so retain each result before building the next. Maestro receives the installed flavor's platform-specific ID, not a guessed common ID. Run the shared Flutter format/analyze/test gate without multiplying identical widget tests by flavor.

## References

- [Flutter Android flavors](https://docs.flutter.dev/deployment/flavors)
- [Flutter iOS schemes and configurations](https://docs.flutter.dev/deployment/flavors-ios)
