import 'package:injectable/injectable.dart';
import 'package:mamo_approval/mock_backend/payments/mock_payments_backend.dart';
import 'package:mamo_approval/mock_backend/payments/payments_backend_client.dart';

@module
abstract class MockBackendModule {
  @lazySingleton
  PaymentsBackendClient paymentsBackendClient() => MockPaymentsBackend();
}
