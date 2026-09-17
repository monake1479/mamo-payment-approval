# Implementation Plan

## Delivery policy and status

Every slice is a runnable increment with a PR into `dev`. Verified increments reach `main` through separate promotion PRs from `dev`. PRs link decisions, criteria, tests, and evidence; no implementation goes directly into shared branches.

The shared `dev` base contains the placeholder app, rules and project skills, native flavors, localization, bootstrap/error handling, router, push tooling, tests, and CI configuration. The unmerged theme ancestor adds the accepted system-following light/dark themes. This feature branch adds the read-only Home, Payments, and decided-payment details increment; approval, authentication, and the debug action remain separate work.

The current UI foundation increment adds system-following light/dark themes and centralized component/layout tokens. The owner authorized a theme PR and separate stacked feature worktrees on 2026-09-17, without merging into `dev`. [UI contract](product/ui-contract.md) and [implementation contracts](architecture/implementation-contract.md) govern that increment and resolve its previously open routine decisions under delegated authority. Their selections remain subject to owner review. No payment screen is claimed implemented by the theme increment.

An earlier version of the workflow received an [independent audit and targeted correction check](testing/agent-workflow-review.md). That audit does not verify subsequent workflow or application changes. New planning decisions are recorded in the [product Q&A](product/requirements.md#planning-qa-accepted-decisions); accepted requirements are distinct from implemented behaviour.

| Slice | Scope and criteria | Decisions and evidence |
|---|---|---|
| 0. Rules and workflow | `.ai/`, docs, PR template, `dev`, CI; supports `DELIVERY-02` | ADRs 0003/0004; rule/link audit, local gate, CI logs |
| 1. Read-only payments | Model, deterministic async repository, collection state, decided-payment list; `PAY-01/02`, `MONEY-01` | Resolve remaining money semantics in ADR 0002 and fixture contract; AED-only, pending excluded from history; failures, ordering, loading/empty/error, compact/expanded tests; first Maestro list flow and local Android/iOS harness |
| 2. Home and details | Approved-only summary, decided recent payments and details, origin back navigation; `HOME-01..04`, `PAY-03`, `DETAIL-01/02` | Decision time drives ordering and monthly membership in the account reporting zone (demo: `Asia/Dubai`); test pending/rejected exclusion, UTC-converted month boundaries, device-zone independence, navigation, and layout |
| 3. Incoming request and rejection | Draggable global action, masked non-dismissible overlay, rejection, canonical update; `DEBUG-01..04`, `APPROVAL-01..03/05/07..09`, rejection part of `PAY-04` | One active request, no queue/replacement; agree masks and equal-timestamp tie-breaker; test dismissal blocking, disabled creation, safe drag, origin preservation, duplicate/stale operations |
| 4. Native authentication and approval | Real adapter, reveal, explicit approve, list navigation; `APPROVAL-04/05/06/08/10`, remaining `PAY-04` | Q9–Q11 accept biometrics/device credentials, authentication before approval, and remasking on actual backgrounding; test native-prompt lifecycle separately from leaving the app, stale completions, cancellation/unavailability, and rejection without authentication; fake contract tests plus native iOS/Android verification; no shipping fake success |
| 5. Original addition | Jointly select from extension backlog | New criteria, proportional design, tests, evidence, own PR |
| 6. Delivery and reviewer guide | Installable Android APK, supported/tested iOS, critical journeys; `DELIVERY-01/02` | Native builds, APK install/access checks, recordings, provenance, limitations; no store/TestFlight requirement |

Split slices further when useful. Domain/data/state/UI types arrive when the runnable increment needs them. Introduce native CI/build artifacts with platform delivery work.

Parallel screen implementation follows the delegated UI contract and shared light/dark tokens (`UI-01`). Verify both appearances at compact/expanded widths and with large text as screens arrive. No manual theme selector is included. A separate pending-payments screen remains a deferred extension, not an initial-slice dependency.

## Read-only payments screen increment

The read-only increment implements `HOME-01..04`, `PAY-01..03`, `DETAIL-01/02`, `MONEY-01`, and the applicable `UI-01` states against the authoritative `PaymentsCubit` collection. Home shows an approved-only account-month summary and five recent decided payments. Payments shows all approved/rejected history, and branch-local pushed details preserve whether the user arrived from Home or Payments. Missing or pending identifiers render safe localized UI.

Compact layouts use bottom navigation; expanded layouts use a rail. Loading, empty, typed-error/retry, success, light/dark, account-zone dates, fixed AED formatting, and 200% text are covered by widget tests. The app shell exposes a composition builder for the later global approval/debug layer but does not implement either feature in this increment. `maestro/payments_list.yaml` and `maestro/payment_details.yaml` cover the deterministic list, summary, details, and return journeys; native run evidence remains separate from Flutter tests.

Local review follow-up for `MONEY-01` rejects any positive input that would normalize to zero fils, including values inside the binary-noise tolerance. Regression tests cover the shared validator and payment model. Date display delegates English month names to `intl` with an explicit locale, preserving the accepted format and account zone even when the device locale differs.

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

The owner selected `go_router` for app navigation. `MaterialApp.router` uses one
`GoRouter` registered and disposed by `getIt`; route declarations remain in app
composition. `/home` and `/payments` are stateful shell branches with branch-local
decided-payment detail routes. Unknown paths use the existing localized safe error
view without revealing the requested URI. Startup/build-error UI remains
independent of router and DI. There is no routing facade, code generation, or auth
redirect. The app-level builder remains the explicit extension point for the later
global approval overlay and draggable action.

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

The slice questions below are historical planning gates resolved for the baseline by the delegated implementation contract unless explicitly marked as an extension or delivery-access dependency. Do not silently reinterpret them as permission to expand the scope.

- Before slice 1: remaining `double` comparison, summation, boundary parsing/validation, and serialization details in ADR 0002. Q12–Q14 settle whole-fils incoming amounts, no business-rounding feature, and fixed English display (`AED 1,234.56`) independent of device locale.
- Before slice 1: the minimum deterministic fixture contract. Pending requests are explicitly excluded from Home/Payments history; tests must prove the filter rather than relying only on decided fixtures.
- Before slice 2: additional seed scenarios and date formatting. Approved-only membership, decision-time ordering, UTC/ISO 8601 storage, and account-level reporting zone are settled in Q6. The demo uses `Asia/Dubai`; no country/account management UI is required.
- Before slices 3/4: masks, equal-decision-time tie-breaker, process termination, and backgrounding during an already submitted decision. Q7–Q11 settle non-dismissible approval, one active request without queue/replacement, native credential fallback, authentication before approval, rejection without authentication, and remasking after actual backgrounding without a global app lock.
- Before slice 5: choose an original addition with user/reviewer value and manageable scope. Retain the [deferred app PIN and session-expiry request](product/extension-backlog.md#deferred-owner-request-app-pin-and-session-expiry); its timeout and security policy remain undecided, and recording it does not authorize implementation.
- Before delivery: APK installation and reviewer artifact permissions. iOS distribution is not required; iOS support and native verification remain required.

## Promotion

Promote cohesive verified milestones rather than automatically every commit. Link included PRs, criteria delivered, current-head CI, relevant native/device evidence, limitations, and review acceptance. Process-only promotions may mark app journeys/builds not applicable with rationale. Use merge commits to preserve ancestry. Agents must wait for explicit owner authorization for each implementation or promotion merge; review acceptance does not grant it.
