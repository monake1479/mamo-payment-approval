import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/payment_navigation_shell.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_motion.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

void main() {
  for (final Size size in <Size>[const Size(320, 640), const Size(768, 1024)]) {
    testWidgets('switches destinations at $size with large text', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final GoRouter router = _createRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pumpAndSettle();

      final bool expanded = size.width >= AppTheme.expandedBreakpoint;
      expect(
        expanded ? find.byType(NavigationRail) : find.byType(NavigationBar),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(
          expanded ? 'navigation.expanded' : 'navigation.compact',
        ),
        findsOneWidget,
      );
      expect(find.text('Home content'), findsOneWidget);
      final Finder paymentsDestination = expanded
          ? find.text('Payments')
          : find.bySemanticsIdentifier('navigation.destination.payments');
      expect(paymentsDestination, findsOneWidget);
      await tester.tap(paymentsDestination);
      await tester.pump();
      expect(find.byType(AppPageTransitionSwitcher), findsOneWidget);
      expect(find.text('Home content'), findsOneWidget);
      expect(
        find.text('Payments content', skipOffstage: false),
        findsOneWidget,
      );
      await tester.pump(AppMotion.standard ~/ 2);
      final double outgoingHomeX = tester
          .getTopLeft(find.text('Home content', skipOffstage: false))
          .dx;
      final double incomingPaymentsX = tester
          .getTopLeft(find.text('Payments content', skipOffstage: false))
          .dx;
      expect(outgoingHomeX, lessThan(0));
      expect(incomingPaymentsX, greaterThan(0));
      await tester.pumpAndSettle();
      expect(find.text('Payments content').hitTestable(), findsOneWidget);

      final Finder homeDestination = expanded
          ? find.text('Home')
          : find.bySemanticsIdentifier('navigation.destination.home');
      await tester.tap(homeDestination);
      await tester.pump();
      await tester.pump(AppMotion.standard ~/ 2);
      expect(
        tester
            .getTopLeft(find.text('Payments content', skipOffstage: false))
            .dx,
        greaterThan(0),
      );
      expect(
        tester.getTopLeft(find.text('Home content', skipOffstage: false)).dx,
        lessThan(0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Home content').hitTestable(), findsOneWidget);

      final Finder swipeRegion = find.bySemanticsIdentifier(
        'navigation.swipeRegion',
      );
      expect(swipeRegion, findsOneWidget);
      await tester.fling(swipeRegion, const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Payments content').hitTestable(), findsOneWidget);
      await tester.fling(swipeRegion, const Offset(300, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Home content').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('page follows the pointer and settles or cancels the drag', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final GoRouter router = _createRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();

    final Finder swipeRegion = find.bySemanticsIdentifier(
      'navigation.swipeRegion',
    );
    final double homeStart = tester.getTopLeft(find.text('Home content')).dx;
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(swipeRegion),
    );
    await gesture.moveBy(const Offset(-96, 0));
    await tester.pump();

    expect(
      tester.getTopLeft(find.text('Home content')).dx,
      closeTo(homeStart - 96, 1),
    );
    expect(find.text('Payments content', skipOffstage: false), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Home content').hitTestable(), findsOneWidget);

    final TestGesture completingGesture = await tester.startGesture(
      tester.getCenter(swipeRegion),
    );
    await completingGesture.moveBy(const Offset(-256, 0));
    await completingGesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Payments content').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'outgoing destination stays active until the swap settles, then releases',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final GoRouter router = _createProbeRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('home:started', skipOffstage: false), findsOneWidget);
      expect(find.text('payments:idle', skipOffstage: false), findsOneWidget);

      await tester.tap(
        find.bySemanticsIdentifier('navigation.destination.payments'),
      );
      await tester.pump();
      await tester.pump(AppMotion.standard ~/ 2);

      // Regression: while the pager commits to Payments at the half-way point,
      // the outgoing Home destination must stay "started" so its content keeps
      // painting instead of snapping back to its hidden pre-entrance state.
      expect(find.text('home:started', skipOffstage: false), findsOneWidget);
      expect(
        find.text('payments:started', skipOffstage: false),
        findsOneWidget,
      );

      await tester.pumpAndSettle();

      // Once settled, the off-screen Home destination is released back to idle
      // so it can replay its entrance the next time it becomes visible.
      expect(
        find.text('payments:started', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('home:idle', skipOffstage: false), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

GoRouter _createRouter() => GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    StatefulShellRoute(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) => PaymentNavigationShell(navigationShell: navigationShell),
      navigatorContainerBuilder:
          (
            BuildContext context,
            StatefulNavigationShell navigationShell,
            List<Widget> children,
          ) => PaymentBranchNavigatorContainer(
            currentIndex: navigationShell.currentIndex,
            onDestinationSelected: (int index) =>
                navigationShell.goBranch(index),
            children: children,
          ),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          preload: true,
          routes: <RouteBase>[
            GoRoute(
              path: '/home',
              builder: (BuildContext context, GoRouterState state) =>
                  const Scaffold(body: Text('Home content')),
            ),
          ],
        ),
        StatefulShellBranch(
          preload: true,
          routes: <RouteBase>[
            GoRoute(
              path: '/payments',
              builder: (BuildContext context, GoRouterState state) =>
                  const Scaffold(body: Text('Payments content')),
            ),
          ],
        ),
      ],
    ),
  ],
);

GoRouter _createProbeRouter() => GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    StatefulShellRoute(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) => PaymentNavigationShell(navigationShell: navigationShell),
      navigatorContainerBuilder:
          (
            BuildContext context,
            StatefulNavigationShell navigationShell,
            List<Widget> children,
          ) => PaymentBranchNavigatorContainer(
            currentIndex: navigationShell.currentIndex,
            onDestinationSelected: (int index) =>
                navigationShell.goBranch(index),
            children: children,
          ),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          preload: true,
          routes: <RouteBase>[
            GoRoute(
              path: '/home',
              builder: (BuildContext context, GoRouterState state) =>
                  const _MotionProbe('home'),
            ),
          ],
        ),
        StatefulShellBranch(
          preload: true,
          routes: <RouteBase>[
            GoRoute(
              path: '/payments',
              builder: (BuildContext context, GoRouterState state) =>
                  const _MotionProbe('payments'),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Renders whether its destination is currently marked to run its entrance,
/// exposing [AppIndexedPageMotionScope.startAnimation] as findable text.
class _MotionProbe extends StatelessWidget {
  const _MotionProbe(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final bool started =
        AppIndexedPageMotionScope.maybeOf(context)?.startAnimation ?? true;
    return Scaffold(body: Text('$label:${started ? 'started' : 'idle'}'));
  }
}
