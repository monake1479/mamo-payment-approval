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
- Provide a feature state owner as close as possible to the widget subtree that uses it: annotate the BLoC/Cubit with `@injectable` (a factory) and place `BlocProvider(create: (_) => getIt<XyzBloc>())` directly above the widget(s) that read it, not higher. Lift the provider to the top of the page only when several separate parts of that page consume the same instance (`PaymentsPage` provides `PaymentsSearchBloc` at its top because the search controls, the list area, and the page's collection listener all use it). Only process-wide owners such as `PaymentsCubit` and `ThemeModeCubit` are created in app composition and passed down. The router, `lib/app/di/`, and the app shell must not wrap page widgets in providers, take "create the bloc" callbacks, or otherwise know which state owners a page needs. Widget tests register the factory in `getIt` (see `registerPaymentsSearchBloc` in `test/support/payments_test_support.dart`) instead of threading blocs through constructors.
- Do not subscribe one Cubit directly to another. Keep collection writes in one authoritative path and document how successful decisions reach it before navigation.
- Guard against stale async completions, emissions after disposal, and repeated terminal effects. Test races relevant to the operation.
- Derive empty state from a successfully loaded empty collection, without a separate mutable empty flag.

## Anchors

- `docs/architecture/overview.md` (planned ownership and decision flow)
- `docs/testing/strategy.md` (async and lifecycle scenarios)
