import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure_view.dart';
import 'package:mamo_payment_approval_challenge/features/payments/pages/foundation_page.dart';

final class MamoPaymentRouter {
  MamoPaymentRouter()
    : _router = GoRouter(
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (context, state) => const FoundationPage(),
          ),
        ],
        errorBuilder: (context, state) =>
            const AppFailureView(failure: AppFailureCode.unexpected),
      );

  final GoRouter _router;

  GoRouter get router => _router;

  void dispose() => _router.dispose();
}
