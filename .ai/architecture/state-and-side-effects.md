# State and Side Effects

- Use BLoC/Cubit for business state that spans widgets, screens, or asynchronous work.
- Keep each feature state concern in its own `states/<state-name>/` directory. The folder name describes the concern without `_cubit` or `_bloc`; the files identify the implementation technology. Use `<name>_cubit.dart` plus `<name>_state.dart` for a Cubit, and `<name>_bloc.dart`, `<name>_event.dart`, plus `<name>_state.dart` for a BLoC. Do not collect unrelated controllers in one feature-level `cubit/` or `bloc/` directory.
- Use local widget state only for ephemeral visual behaviour with no business meaning.
- Model idle, in-progress, success, cancellation, and failure states explicitly when an operation can produce them.
- Keep payment decisions atomic from the UI's perspective. Repeated approve or reject actions must not create duplicate transitions.
- The payment list state is authoritative for ordering, status, and current-month totals.
- The approval controller coordinates authentication through an interface; it does not invoke platform plugins directly.
- Authentication cancellation is not a crash. Preserve masked data and expose a recoverable UI state.
- Ignore or serialize repeated actions while authentication or a decision is in progress.
- Keep the draggable debug action's position in session state. Do not persist it across application restarts unless the requirement changes.
- Avoid broad subscriptions. A widget should observe only the state needed to render itself.
- Every timer, stream subscription, and controller must have an explicit owner and disposal path.
- BLoC/Cubit implementations must not accept, retain, or use `BuildContext`, navigation APIs, or dialog APIs. They report outcomes; application composition reacts through listeners and callbacks.
- Widgets may use `context.read`, `context.select`, `context.watch`, `BlocBuilder`, and `BlocSelector`. `BlocProvider(create:)` owns a newly created instance; an existing instance passed by value keeps its original owner.
- Provide a BLoC/Cubit as low in the widget tree as its consumers allow. A screen-scoped controller is registered as an `@injectable` factory and provided at the top of the page that needs it with `BlocProvider(create: (_) => getIt<XCubit>()..load(), child: ...)`; the page's provider owns and closes it. Never wrap route builders in `lib/app/navigation/` with providers, and never register a controller as a process-wide singleton unless its state is genuinely global (the authoritative payment collection, the appearance mode). A provider in the router or a global singleton for page-local state is an anti-pattern.
- Do not subscribe one Cubit directly to another. Keep collection writes in one authoritative path and document how successful decisions reach it before navigation.
- Guard against stale async completions, emissions after disposal, and repeated terminal effects. Test races relevant to the operation.
- Derive empty state from a successfully loaded empty collection, without a separate mutable empty flag.

## Anchors

- `docs/architecture/overview.md` (planned ownership and decision flow)
- `docs/testing/strategy.md` (async and lifecycle scenarios)
