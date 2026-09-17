# ADR 0003: Mobile-only platform scope

- Status: Accepted
- Date: 2026-09-16

## Context and alternatives

The foundation proposed iOS, Android, and a hosted Web demo to minimize reviewer setup. The owner chose iOS/Android only. The brief's no-compile reviewer experience still applies.

## Decision

Support iOS and Android with native authentication behind a domain-facing interface and deterministic test fakes. Web hosting and an authentication simulator are outside scope. The Web scaffold and its platform metadata have been removed.

## Consequences

- Native authentication and mobile lifecycle behaviour are the relevant verification surface.
- Android delivery provides an installable APK with source/version provenance and instructions.
- The owner selected APK delivery for no-compile reviewer access. iOS remains supported and tested; TestFlight/store distribution is outside submission scope.
- An unsigned iOS build proves compilation only, not installation or device verification.

## Verification

Native build evidence, device journeys on both platforms, and install/access checks for delivered artifacts. Platform cleanup is complete; native CI remains planned.
