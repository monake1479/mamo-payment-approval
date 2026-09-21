# Repository Instructions

These instructions apply to every human or AI contributor in this repository.

## Start here

1. Read `.ai/INDEX.md`.
2. Read `docs/product/requirements.md` before changing behaviour.
3. Load only the rule files whose trigger matches the task.
4. Inspect the current implementation and tests before editing.
5. Before creating a branch, commit, PR, or release, read `.ai/workflows/review-loop.md`.
6. Load the project skills selected by `.ai/INDEX.md` before the matching work. Read their `SKILL.md` files directly if the agent runtime does not list them; do not assume a slash command exists.

## Non-negotiable rules

- All source code, identifiers, comments, documentation, commit messages, and user-facing copy are written in English.
- Flutter UI copy lives in ARB resources and is accessed through generated `AppLocalizations`; follow `.ai/principles/flutter-ui.md`.
- The author must understand and be able to explain every committed line. AI output is a draft until inspected and verified.
- Keep the solution proportional to the challenge. Add an abstraction only when it protects a real boundary or makes behaviour easier to test.
- Domain code must not import Flutter.
- Supported application platforms are iOS and Android only.
- Use the Flutter SDK pinned in `.fvmrc` through FVM for local commands. Do not change the global SDK. CI reads the same version file.
- Widgets must not perform repository or authentication work directly.
- BLoC/Cubit implementations must not accept or retain `BuildContext` or invoke navigation APIs. Widgets may use `context.read`, `context.select`, providers, builders, and listeners.
- Provide a BLoC/Cubit (`@injectable`, `BlocProvider(create: (_) => getIt<...>())`) as close as possible to the subtree that uses it. Lift it to the top of the page only when several parts of that page consume it; only process-wide owners are created in app composition. The router and DI composition never wrap pages in providers or accept bloc factories; see `.ai/architecture/state-and-side-effects.md`.
- Do not silently swallow failures. Convert infrastructure exceptions into explicit application failures at the boundary.
- User-facing error text is resolved in presentation from stable failure codes through `AppLocalizations`, never supplied as a ready-made sentence by repositories or controllers.
- Never commit secrets, local signing material, generated build output, or machine-specific configuration.
- Do not weaken analysis rules or add ignore comments to hide a finding. Fix the cause or document a narrowly justified exception.

## Working agreement

- Implement in small vertical slices that leave the app runnable.
- Keep state owners narrow. A state object should change only for events relevant to its concern.
- Prefer immutable state and exhaustive state handling.
- Extract meaningful widget classes instead of `Widget _buildX()` helper methods.
- Use theme tokens rather than ad hoc colours, spacing, or typography in feature widgets.
- Preserve accessibility: semantic labels, keyboard/focus support where applicable, readable contrast, and at least 48x48 logical-pixel touch targets.
- Update requirements, architecture notes, and tests in the same change when behaviour or a contract changes.
- Deliver each vertical slice through a PR into `dev`; promote verified increments through a separate `dev` to `main` PR.
- Agents must not merge or enable auto-merge unless the owner explicitly authorizes that specific merge. Passing checks, review acceptance, and permission to commit, push, or open a PR are not merge authorization.
- Install the local push hook as described in `.ai/workflows/push-gate.md`. Agents must not disable hooks or skip checks without explicit owner authorization for the exact exception; record the request, approval, and single-attempt use. A local test exception does not waive CI or authorize publication/merge.
- Preserve review discussions and verification evidence in the PR. Address findings with a fix or evidence-backed explanation before resolving them.
- Skill use does not authorize additional mutations or delegation. Respect the requested mode (plan, inspect, implement, or publish) and any instruction to batch local changes without commits/pushes.

## Definition of done

A change is complete only when:

1. acceptance criteria affected by the change are identified;
2. relevant Flutter unit/widget tests and affected Maestro journeys exist and pass, with separate native-authentication evidence when applicable;
3. formatting and static analysis are clean;
4. loading, empty, error, and success states have been considered;
5. the implementation works at compact and expanded widths;
6. no debug output, dead code, secrets, or unexplained generated code remain;
7. documentation still describes the code truthfully.

Run the commands in `.ai/workflows/quality-gate.md` before committing.
