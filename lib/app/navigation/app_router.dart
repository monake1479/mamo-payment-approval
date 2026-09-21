import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_approval/app/errors/app_failure.dart';
import 'package:mamo_approval/app/errors/app_failure_view.dart';
import 'package:mamo_approval/app/navigation/payment_navigation_shell.dart';
import 'package:mamo_approval/app/theme/app_motion.dart';
import 'package:mamo_approval/features/payments/pages/home_page.dart';
import 'package:mamo_approval/features/payments/pages/payment_details_page.dart';
import 'package:mamo_approval/features/payments/pages/payments_page.dart';
import 'package:mamo_approval/features/payments/states/search/payments_search_bloc.dart';

abstract final class AppRoutes {
  static const String home = 'home';
  static const String payments = 'payments';
  static const String paymentDetails = 'payment-details';
}

final class MamoPaymentRouter {
  /// [createPaymentsSearchBloc] builds the page-scoped search state owner; the
  /// `/payments` route's `BlocProvider` owns and closes the instance.
  MamoPaymentRouter({
    required PaymentsSearchBloc Function() createPaymentsSearchBloc,
  }) : _router = GoRouter(
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
                     builder: (context, state) =>
                         BlocProvider<PaymentsSearchBloc>(
                           create: (BuildContext _) =>
                               createPaymentsSearchBloc(),
                           child: PaymentsPage(
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
