# AI Rule Index

This is the routing document for AI-assisted work. Read `AGENTS.md` first, then load only the rules triggered by the task.

| Trigger | Required rule |
|---|---|
| Any code or documentation change | `.ai/principles/engineering-standards.md` |
| Requirement ambiguity, architectural decision, dependency choice | `.ai/workflows/decision-gate.md`; [accepted product Q&A](../docs/product/requirements.md#planning-qa-accepted-decisions) |
| Architecture, dependency, model, repository, or service change | `.ai/architecture/app-structure.md` |
| Repository, adapter, validation, or failure handling | `.ai/architecture/failures-and-boundaries.md` |
| BLoC, Cubit, async work, authentication, or side effect | `.ai/architecture/state-and-side-effects.md` |
| Authentication, masking, payment disclosure, or logging | `.ai/architecture/authentication-and-sensitive-data.md` |
| Dates, ordering, fixtures, or money | `.ai/principles/utc-and-determinism.md`; `docs/decisions/0002-money-representation.md` for money |
| UI, widget, page, overlay, responsive layout, or design token | `.ai/principles/flutter-ui.md` |
| UI copy, localization, ARB, or `intl` | `.ai/principles/flutter-ui.md`; `docs/decisions/0008-localization.md` |
| Test, refactor, commit, or delivery work | `.ai/workflows/quality-gate.md` |
| Maestro, E2E, screen, navigation, or approval interaction change | `.ai/workflows/maestro-e2e.md` |
| Local review, branch, PR, review comment, merge, or promotion | `.ai/workflows/review-loop.md` |
| Push, Git hook, local gate installation, or test exception | `.ai/workflows/push-gate.md`; `.ai/workflows/quality-gate.md`; `.ai/workflows/review-loop.md` |
| Flutter/Dart version, FVM, IDE SDK, or CI toolchain | `docs/decisions/0006-fvm-managed-flutter.md`; `.ai/workflows/quality-gate.md` |
| Native build, distribution, or final handover | `.ai/workflows/delivery-checklist.md` |
| Flavor, native environment, app identity, or launch configuration | `docs/decisions/0007-native-flavors.md`; `.ai/workflows/quality-gate.md` |
| Adding or changing agent rules or project skills | `.ai/AUTHORING.md` |

## Project skill routing

Rules define constraints; skills define how to carry out a matching assignment. Read each triggered skill once, follow only the mode authorized by the user, and load further references only for the current phase. Following a link back here does not restart the workflow.

| Task | Required skill |
|---|---|
| Plan or implement a feature/behavioural fix | [mamo-feature-slice](skills/mamo-feature-slice/SKILL.md) |
| Specify, implement, or verify visible Flutter UI, shared theme, motion, or accessibility | [mamo-flutter-ui](skills/mamo-flutter-ui/SKILL.md) |
| Select/run tests, verify a change, or close a local quality gate | [mamo-verify](skills/mamo-verify/SKILL.md) |
| Review local changes or inspect/address PR feedback | [mamo-review-round](skills/mamo-review-round/SKILL.md) |

The canonical skill files live in this repository under `.ai/skills/`. Read them directly when selected by this router. Native skill-picker registration is not configured. If a required file/tool is missing, report the limitation; do not claim the skill/check ran.

For UI implementation, combine feature scoping (when behaviour changes), UI execution, and verification in that order. For review-only work, load the relevant procedures without implementing fixes or publishing anything. See the [verification record template](../docs/testing/evidence-template.md) for required output.

## Source-of-truth order

When two sources disagree, resolve them in this order:

1. explicit owner decisions recorded in `docs/product/requirements.md`, followed by the challenge brief where no recorded clarification exists;
2. accepted records under `docs/decisions/`;
3. `docs/architecture/overview.md`;
4. these AI rules;
5. the current implementation.

Do not silently choose when the conflict changes product behaviour. Record the discrepancy and ask the owner.

Rules describe required practice; they do not imply that planned code already exists. Implementation status lives in `docs/implementation-plan.md`.
