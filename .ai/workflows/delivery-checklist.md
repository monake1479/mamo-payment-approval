# Native Delivery Checklist

## Rule

Deliver an identifiable, tested mobile build that reviewers can install without compiling the project.

## Before release promotion

- Link included PRs, ADRs, and acceptance-criteria evidence.
- Verify both native builds and implemented critical journeys. Record unavailable hardware/signing checks as missing evidence, never as passed.
- Provide an Android APK with source commit, version, signing/distribution status, and installation instructions. Label a debug-key-signed release-mode APK accurately.
- iOS remains supported and verified, but TestFlight/store distribution is not required. An unsigned build is compile evidence only, not device evidence or an install link.
- Keep credentials, profiles, keystores, local paths, and sensitive data out of commits and evidence.
- Verify the debug action and native authentication in the distributed build. Test fakes must not enter production composition.
- Document session-only storage/reset behaviour for reviewers.
- Include screenshots or a recording, decisions, trade-offs, limitations, and selected future improvements in the reviewer guide.
- Verify artifact access for reviewers of this private repository; an inaccessible CI link does not satisfy delivery.

## Anchors

- `docs/product/requirements.md`
- `docs/decisions/0003-mobile-only-platform-scope.md`
- `docs/implementation-plan.md`
