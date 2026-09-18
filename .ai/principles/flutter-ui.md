# Flutter UI Rules

- Build responsive layouts from constraints, not from device names.
- Keep Material theme, colour, spacing, radius, and typography decisions in `lib/app/theme/`.
- Use `const` constructors wherever practical.
- Keep Flutter user-facing copy in `lib/l10n/app_en.arb` and read it through generated `AppLocalizations`, including titles, errors, tooltips, and semantic labels. Do not hardcode or concatenate translated sentences. Use ARB placeholders/plurals and keep metadata in English. See [ADR 0008](../../docs/decisions/0008-localization.md) for generation and native-string boundaries.
- Extract reusable or meaningful subtrees into widget classes. Do not create private methods that return widgets.
- Translate typed failure codes/slugs into `AppLocalizations` messages in a presentation method or mapper, with a safe unknown-error fallback. Repositories and BLoC/Cubit state carry failures, not user-facing sentences. See [failure boundaries](../architecture/failures-and-boundaries.md).
- Keep side effects out of `build` methods.
- Rebuild only the subtree that consumes changed state; use selectors or `buildWhen` when measurement shows value.
- Preserve the current route beneath the approval confirmation overlay.
- The debug action must remain discoverable, draggable, reachable, and visible on every route.
- Mask sensitive approval data by default. Authentication is required before revealing it.
- Add semantics for status, masked values, controls, and authentication outcomes.
- Treat compact and expanded widths, text scaling, loading, empty, error, and success states as part of implementation rather than polish.
- Normal framework builder callbacks remain valid; extract meaningful subtrees into widget classes.
- Interactive targets must be at least 48x48 logical pixels. Preserve focus and keyboard activation where applicable, including mobile devices with external keyboards.
- Communicate status without relying solely on colour. Apply masking to semantics and copyable content too.
- Clamp the debug action to safe bounds after resizing and safe-area changes; distinguish dragging from activation. The application is portrait-up only, so feature screens do not add landscape-specific layouts.
- Give Maestro-tested controls stable `Semantics.identifier` values and keep accessible labels readable English. Flutter keys remain useful for widget tests but are not exposed to Maestro; inspect the native semantics on both platforms.
- Profile before adding `RepaintBoundary`, memoization, or caches. Honour reduced motion for custom animations.
- Use the shared primitives in `lib/app/theme/app_motion.dart`: `AppMotionPage` for pushed `go_router` destinations, `AppPageTransitionSwitcher` for indexed top-level destinations, and the dedicated staggered columns for dialog and bottom-sheet content. Do not start modal content motion while its route surface is still off screen or replace these transitions with feature-local variants.
- Centralize genuinely shared breakpoints and theme tokens.

## Anchors

- `docs/product/ui-contract.md` (shared screen and component contract)
- `lib/app/theme/app_theme.dart`
- `docs/product/requirements.md`
- `docs/testing/strategy.md`
