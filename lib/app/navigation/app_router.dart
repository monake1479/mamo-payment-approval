import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure_view.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/payment_navigation_shell.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/pages/home_page.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/pages/payment_details_page.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/pages/payments_page.dart';

abstract final class AppRoutes {
  static const String home = 'home';
  static const String homePayment = 'home-payment';
  static const String payments = 'payments';
  static const String paymentsPayment = 'payments-payment';
}

GoRouter createAppRouter() => GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    GoRoute(path: '/', redirect: (context, state) => '/home'),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          PaymentNavigationShell(navigationShell: navigationShell),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/home',
              name: AppRoutes.home,
              builder: (context, state) => HomePage(
                onOpenPayment: (String paymentId) => unawaited(
                  context.pushNamed(
                    AppRoutes.homePayment,
                    pathParameters: <String, String>{'paymentId': paymentId},
                  ),
                ),
                onViewAll: () => context.goNamed(AppRoutes.payments),
              ),
              routes: <RouteBase>[
                GoRoute(
                  path: 'payment/:paymentId',
                  name: AppRoutes.homePayment,
                  builder: (context, state) => PaymentDetailsPage(
                    paymentId: state.pathParameters['paymentId'] ?? '',
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/payments',
              name: AppRoutes.payments,
              builder: (context, state) => PaymentsPage(
                onOpenPayment: (String paymentId) => unawaited(
                  context.pushNamed(
                    AppRoutes.paymentsPayment,
                    pathParameters: <String, String>{'paymentId': paymentId},
                  ),
                ),
              ),
              routes: <RouteBase>[
                GoRoute(
                  path: 'payment/:paymentId',
                  name: AppRoutes.paymentsPayment,
                  builder: (context, state) => PaymentDetailsPage(
                    paymentId: state.pathParameters['paymentId'] ?? '',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      const AppFailureView(failure: AppFailureCode.unexpected),
);
