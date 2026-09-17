# ADR 0005: Maestro for mobile end-to-end testing

- Status: Accepted
- Date: 2026-09-16

## Context and alternatives

The owner selected Maestro, citing its inclusion in the target role's technology stack. The challenge also needs repeatable evidence for user journeys across routes, overlays, and native authentication boundaries.

Flutter unit and widget tests remain the fastest way to prove business rules and controlled async scenarios. Using only Flutter's `integration_test` for full-app journeys was an alternative; maintaining two equivalent E2E suites would add unnecessary work here.

## Decision

Use Maestro CLI and repository-owned YAML flows as the primary mobile E2E layer, alongside Flutter unit and widget tests. Start locally on Android emulators and iOS simulators. Add flows with each executable vertical slice, beginning with the payments list, rather than postponing all E2E work until delivery.

No Maestro Cloud subscription or additional Dart package is required by this decision. Do not introduce a second full-app framework without a concrete coverage gap and a documented reason.

## Consequences

- UI contracts include stable, non-sensitive semantics identifiers; Flutter keys alone are not Maestro selectors.
- Affected flows run before a feature is reported complete or pushed. Promotions require the implemented critical journeys on both mobile platforms.
- Flow reports identify the tested application build, test sources, environment, results, and artifacts. A YAML file or a successful CLI installation is not execution evidence.
- Unit/widget authentication fakes do not prove the native prompt. Any simulator biometric input is labelled as simulated; real-device authentication still requires separate verification. Never bypass authentication merely because automation is detected.
- Flow authoring and execution follow the [Maestro workflow](../../.ai/workflows/maestro-e2e.md). Toolkit versions and device support are verified during harness setup.

## Adoption status and verification

This change records the choice and workflow only. No Maestro flows, native E2E runner, or Maestro CI job exist yet. The installed CLI reports version 2.7.0; that is a local observation, not a validated project pin. Pin the version after the first Android/iOS smoke runs succeed.

Verify adoption through the criterion-to-flow map, passing runs on both platforms, retained reports, and the absence of an authentication bypass in reviewer builds.
