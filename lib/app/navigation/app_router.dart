import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure_view.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/payment_navigation_shell.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_motion.dart';
import 'package:mamo_payment_approval_challenge/features/payments/pages/home_page.dart';
import 'package:mamo_payment_approval_challenge/features/payments/pages/payment_details_page.dart';
import 'package:mamo_payment_approval_challenge/features/payments/pages/payments_page.dart';
import 'package:mamo_payment_approval_challenge/features/settings/pages/settings_page.dart';

abstract final class AppRoutes {
  static const String home = 'home';
  static const String payments = 'payments';
  static const String paymentDetails = 'payment-details';
  static const String settings = 'settings';
}

final class MamoPaymentRouter {
  MamoPaymentRouter()
    : _router = GoRouter(
        initialLocation: '/home',
        routes: <RouteBase>[
          GoRoute(path: '/', redirect: (context, state) => '/home'),
          GoRoute(
            path: '/payments/payment/:paymentId',
            name: AppRoutes.paymentDetails,
            pageBuilder: (context, state) => AppMotionPage<void>(
              key: state.pageKey,
              name: state.name,
              child: PaymentDetailsPage(
                paymentId: state.pathParameters['paymentId'] ?? '',
              ),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: AppRoutes.settings,
            pageBuilder: (context, state) => AppMotionPage<void>(
              key: state.pageKey,
              name: state.name,
              child: const SettingsPage(),
            ),
          ),
          StatefulShellRoute(
            builder: (context, state, navigationShell) =>
                PaymentNavigationShell(navigationShell: navigationShell),
            navigatorContainerBuilder: (context, navigationShell, children) =>
                PaymentBranchNavigatorContainer(
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
                    name: AppRoutes.home,
                    builder: (context, state) => HomePage(
                      onOpenPayment: (String paymentId) => unawaited(
                        context.pushNamed(
                          AppRoutes.paymentDetails,
                          pathParameters: <String, String>{
                            'paymentId': paymentId,
                          },
                        ),
                      ),
                      onViewAll: () => context.goNamed(AppRoutes.payments),
                      onOpenSettings: () =>
                          unawaited(context.pushNamed(AppRoutes.settings)),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                preload: true,
                routes: <RouteBase>[
                  GoRoute(
                    path: '/payments',
                    name: AppRoutes.payments,
                    builder: (context, state) => PaymentsPage(
                      onOpenPayment: (String paymentId) => unawaited(
                        context.pushNamed(
                          AppRoutes.paymentDetails,
                          pathParameters: <String, String>{
                            'paymentId': paymentId,
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
        errorBuilder: (context, state) =>
            const AppFailureView(failure: AppFailureCode.unexpected),
      );

  final GoRouter _router;

  GoRouter get router => _router;

  void dispose() => _router.dispose();
}
