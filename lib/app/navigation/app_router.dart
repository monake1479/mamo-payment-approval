import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure_view.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/pages/foundation_page.dart';

GoRouter createAppRouter() => GoRouter(
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (context, state) => const FoundationPage()),
  ],
  errorBuilder: (context, state) =>
      const AppFailureView(failure: AppFailureCode.unexpected),
);
