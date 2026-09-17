import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure_view.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/payment_navigation_shell.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_motion.dart';
import 'package:mamo_payment_approval_challenge/features/payments/pages/home_page.dart';
import 'package:mamo_payment_approval_challenge/features/payments/pages/payment_details_page.dart';
import 'package:mamo_payment_approval_challenge/features/payments/pages/payments_page.dart';

abstract final class AppRoutes {
  static const String home = 'home';
  static const String homePayment = 'home-payment';
  static const String payments = 'payments';
  static const String paymentsPayment = 'payments-payment';
}

final class MamoPaymentRouter {
  MamoPaymentRouter()
    : _router = GoRouter(
        initialLocation: '/home',
        routes: <RouteBase>[
          GoRoute(path: '/', redirect: (context, state) => '/home'),
          StatefulShellRoute(
            builder: (context, state, navigationShell) =>
                PaymentNavigationShell(navigationShell: navigationShell),
            navigatorContainerBuilder: (context, navigationShell, children) =>
                PaymentBranchContainer(
                  currentIndex: navigationShell.currentIndex,
                  children: children,
                ),
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
                          pathParameters: <String, String>{
                            'paymentId': paymentId,
                          },
                        ),
                      ),
                      onViewAll: () => context.goNamed(AppRoutes.payments),
                    ),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'payment/:paymentId',
                        name: AppRoutes.homePayment,
                        pageBuilder: (context, state) => AppMotionPage<void>(
                          context: context,
                          key: state.pageKey,
                          name: state.name,
                          child: PaymentDetailsPage(
                            paymentId: state.pathParameters['paymentId'] ?? '',
                          ),
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
                          pathParameters: <String, String>{
                            'paymentId': paymentId,
                          },
                        ),
                      ),
                    ),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'payment/:paymentId',
                        name: AppRoutes.paymentsPayment,
                        pageBuilder: (context, state) => AppMotionPage<void>(
                          context: context,
                          key: state.pageKey,
                          name: state.name,
                          child: PaymentDetailsPage(
                            paymentId: state.pathParameters['paymentId'] ?? '',
                          ),
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

  final GoRouter _router;

  GoRouter get router => _router;

  void dispose() => _router.dispose();
}
