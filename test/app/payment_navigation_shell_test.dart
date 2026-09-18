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
      expect(find.text('Payments content'), findsOneWidget);
      await tester.pump(AppMotion.standard ~/ 2);
      expect(
        find.descendant(
          of: find.byType(AppPageTransitionSwitcher),
          matching: find.byType(FractionalTranslation),
        ),
        findsNWidgets(2),
      );
      await tester.pumpAndSettle();
      expect(find.text('Payments content'), findsOneWidget);
      expect(find.text('Home content'), findsNothing);

      final Finder homeDestination = expanded
          ? find.text('Home')
          : find.bySemanticsIdentifier('navigation.destination.home');
      await tester.tap(homeDestination);
      await tester.pump();
      await tester.pump(AppMotion.standard ~/ 2);
      final FractionalTranslation outgoing = tester
          .widgetList<FractionalTranslation>(
            find.ancestor(
              of: find.text('Payments content'),
              matching: find.byType(FractionalTranslation),
            ),
          )
          .singleWhere(
            (FractionalTranslation transition) =>
                transition.translation.dx.abs() > 0.001,
          );
      final FractionalTranslation incoming = tester
          .widgetList<FractionalTranslation>(
            find.ancestor(
              of: find.text('Home content'),
              matching: find.byType(FractionalTranslation),
            ),
          )
          .singleWhere(
            (FractionalTranslation transition) =>
                transition.translation.dx.abs() > 0.001,
          );
      expect(outgoing.translation.dx, greaterThan(0));
      expect(incoming.translation.dx, lessThan(0));
      await tester.pumpAndSettle();
      expect(find.text('Home content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
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
            children: children,
          ),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/home',
              builder: (BuildContext context, GoRouterState state) =>
                  const Scaffold(body: Text('Home content')),
            ),
          ],
        ),
        StatefulShellBranch(
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
