import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/payment_navigation_shell.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

void main() {
  for (final Size size in <Size>[const Size(320, 640), const Size(1024, 768)]) {
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
      await tester.pumpAndSettle();
      expect(find.text('Payments content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

GoRouter _createRouter() => GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) => PaymentNavigationShell(navigationShell: navigationShell),
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
