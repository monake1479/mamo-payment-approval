# Implementation Plan

## Delivery policy and status

Every slice is a runnable increment with a PR into `dev`. Verified increments reach `main` through separate promotion PRs from `dev`. PRs link decisions, criteria, tests, and evidence; no implementation goes directly into shared branches.

The foundation contains the placeholder app, initial rules, native-only scope, branch flow, and CI configuration. Local additions include flavors and localization/layout widget tests. All payment behaviour below is planned. Further workflow refinements remain local until ready for a PR.

The current local process iteration adds Maestro policy, four project skills routed through `.ai/INDEX.md`, and a verification record template. An earlier version received an [independent audit and targeted correction check](testing/agent-workflow-review.md). Subsequent changes generalize the skills, add local review, require explicit owner authorization for agent merges, and pin Flutter through FVM (ADR 0006); the earlier audit does not verify these later changes. Keep edits uncommitted until the agreed process-review checkpoint.

| Slice | Scope and criteria | Decisions and evidence |
|---|---|---|
| 0. Rules and workflow | `.ai/`, docs, PR template, `dev`, CI; supports `DELIVERY-02` | ADRs 0003/0004; rule/link audit, local gate, CI logs |
| 1. Read-only payments | Model, deterministic async repository, collection state, list; `PAY-01/02` | Resolve money ADR 0002, pending-row disclosure, and minimum fixture contract first; failures, ordering, loading/empty/error, compact/expanded tests; first Maestro list flow and local Android/iOS harness |
| 2. Home and details | Summary, recent payments, decided-only details, origin back navigation; `HOME-01..04`, `PAY-03`, `DETAIL-01/02` | Settle summary/calendar/timestamps; boundary, navigation, and layout tests |
| 3. Incoming request and rejection | Draggable global action, masked overlay, rejection, canonical update; `DEBUG-01..04`, `APPROVAL-01..03/05/07/08`, rejection part of `PAY-04` | Agree masks, dismissal, concurrency, ordering; safe drag, origin preservation, duplicate/stale operation tests |
| 4. Native authentication and approval | Real adapter, reveal, approve, list navigation; `APPROVAL-04/05/06/08`, remaining `PAY-04` | Agree fallback/lifecycle; fake contract tests plus native iOS/Android verification; no shipping fake success |
| 5. Original addition | Jointly select from extension backlog | New criteria, proportional design, tests, evidence, own PR |
| 6. Delivery and reviewer guide | Installable Android APK, supported/tested iOS, critical journeys; `DELIVERY-01/02` | Native builds, APK install/access checks, recordings, provenance, limitations; no store/TestFlight requirement |

Split slices further when useful. Domain/data/state/UI types arrive when the runnable increment needs them. Introduce native CI/build artifacts with platform delivery work.

## Native foundation increment

The local foundation adds `dev`, `staging`, and `prod` on both platforms (ADR 0007) and removes the unused Web scaffold and platform metadata. This supports `DELIVERY-01/02` without implementing payment behaviour.

- Three thin Dart entry points share one bootstrap; native identifiers and launcher names distinguish installations (ADR 0010).
- Commands name the matching entry point and native flavor explicitly; IDE configurations encode the pair.
- Verify Android debug/release artifacts and iOS simulator/device compilation for each flavor, inspect packaged identifiers/names, and check all Xcode Debug/Profile/Release mappings. Run the Flutter gate and document any unrun installation, signing, or device checks separately.
- No backend environments, signing provisioning, or authentication shortcuts are introduced. Deferred product decisions remain open.

## Runtime foundation increment

`RUNTIME-01..03` add shared bootstrap, manual `get_it` registration per environment,
runtime flavor validation, sanitized local diagnostics, and localized startup/build-error
UI. Scope, state ownership, exclusions, and criterion-to-test mapping are in the
[runtime screen contract](product/runtime-foundation.md) and ADR 0010. No payment
model or summary policy is encoded. The owner-selected startup is a linear function
with one process-wide `getIt`, no startup controller, and a stateless app root.
Tests cover flavor wiring, mismatch, safe logging, a throwing widget, and
compact/expanded failure layouts. Native compilation
and launch/failure journeys are separate verification items, not implied by unit
tests. This increment also enforces the dependency lockfile in CI and adds pinned
Gitleaks scanning of publishable working files and history.

`PRIVACY-01` is a separate native lifecycle step: conceal app-switcher snapshots
without reauthentication or session reset. Older Android screenshot restrictions
require an explicit owner choice; PIN/expiry remain deferred. Track native device
evidence independently from bootstrap tests.

## Navigation foundation increment

The owner selected `go_router` for app navigation. A DI-owned
`MamoPaymentRouter` owns and disposes one `GoRouter`; app composition injects its
stable router into `MaterialApp.router`. Route declarations stay in that
application-infrastructure class. The only current route is `/`, displaying the
unchanged foundation page.
Unknown paths use the existing localized safe error view without revealing the
requested URI. Startup/build-error UI remains independent of router and DI. No
placeholder feature routes, code generation, or auth redirects are introduced.
Verify router ownership and identity, root/back behavior, preserved location on
rebuild, unknown-route recovery, localization/layout, and native startup/resume.
Future payment/details/overlay journeys arrive with their corresponding slices.

## Localization foundation increment

Use English ARB messages and generated `AppLocalizations` for the existing application title, foundation heading, and explanatory text (ADR 0008). Preserve copy and the centered, width-constrained composition; allow scrolling when large text exceeds the viewport. Do not introduce payment behaviour, extra languages, or money formatting rules. Verify English and regional-English locales, unsupported-locale fallback, compact/expanded layouts at large text scale, generation from source ARB, and native compilation. Native flavor launcher names remain platform metadata. CI generates localization output before analysis/tests.

## Local quality tooling increment

The local push hook selects tests from the pushed diff, with an explicit impact map and conservative full-suite fallback (ADR 0009). Documentation-only pushes avoid Flutter checks. It records separately requested, approved, and consumed single-attempt Flutter-test exceptions. Installation is per worktree; full-suite CI and explicit merge authorization remain unchanged. Tooling tests use temporary local repositories, not GitHub. Error-message rules now require presentation-owned `AppLocalizations` mapping from stable failure codes; concrete types and mapper tests arrive with the first failure-producing slice.

## Maestro adoption

ADR 0005 accepts Maestro as the E2E layer. The runtime foundation introduces normal
launch/resume and configuration-failure flows, mapped in the testing strategy.
There are no Maestro CI jobs yet; retain local results and tool-version provenance.

- Slice 1: extend foundation flows with the first real list flow, inspect semantics on Android/iOS, document deterministic data reset, and retain local reports.
- Slice 2: add details/origin navigation and summary scenarios after their product decisions are settled.
- Slice 3: add masked-overlay rejection and debug-drag/session journeys.
- Slice 4: add native-auth approval/cancellation coverage, label simulated input, and retain separate device evidence. Do not add an authentication bypass to complete automation.
- Slice 6: automate the native Maestro lanes and report uploads in CI as runner access permits; document any remaining manual gate. No paid Cloud service is implied.

Run affected journeys with each slice before completion/push. Each implemented critical journey must have Android/iOS evidence before promotion; local evidence is required while CI automation is pending.

## Open decisions

- Before slice 1: `double` precision, rounding, equality, totals, currency, formatting, parsing, and wire representation. Earlier recommendations are not accepted decisions.
- Before slice 1: pending-row visibility/disclosure and the minimum seeded currency, locale, and status contract. Do not render full pending values, silently filter them, or claim complete all-payment coverage from decided-only fixtures without an agreed scope.
- Before slice 2: summary inclusion, reporting calendar/timestamp, and additional seed scenarios needed by the summary.
- Before slices 3/4: masks, dismissal/back, multiple requests, ordering older requests after decisions, auth fallback and lifecycle.
- Before slice 5: choose an original addition with user/reviewer value and manageable scope. Retain the [deferred app PIN and session-expiry request](product/extension-backlog.md#deferred-owner-request-app-pin-and-session-expiry); its timeout and security policy remain undecided, and recording it does not authorize implementation.
- Before delivery: APK installation and reviewer artifact permissions. iOS distribution is not required; iOS support and native verification remain required.

## Promotion

Promote cohesive verified milestones rather than automatically every commit. Link included PRs, criteria delivered, current-head CI, relevant native/device evidence, limitations, and review acceptance. Process-only promotions may mark app journeys/builds not applicable with rationale. Use merge commits to preserve ancestry. Agents must wait for explicit owner authorization for each implementation or promotion merge; review acceptance does not grant it.
