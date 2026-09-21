import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_payment_approval_challenge/app/bootstrap.dart';
import 'package:mamo_payment_approval_challenge/app/config/app_environment.dart';
import 'package:mamo_payment_approval_challenge/app/di/configure_dependencies.dart';
import 'package:mamo_payment_approval_challenge/app/diagnostics/local_diagnostics.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure.dart';
import 'package:mamo_payment_approval_challenge/app/errors/configure_error_handling.dart';
import 'package:mamo_payment_approval_challenge/app/navigation/app_router.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/data_sources/theme_preference_local_data_source.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/theme_preference_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/use_cases/load_theme_preference_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/use_cases/save_theme_preference_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/data_sources/local_auth_client.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/local_auth_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/is_local_auth_supported_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/local_authentication_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/device_authentication/use_cases/stop_local_authentication_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/data_sources/payments_remote_data_source.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/create_payment_request_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/decide_payment_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/load_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/payments/use_cases/refresh_payments_use_case.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/settings/states/theme_mode/theme_mode_cubit.dart';
import 'package:mamo_payment_approval_challenge/mock_backend/payments/mock_payments_backend.dart';
import 'package:mamo_payment_approval_challenge/mock_backend/payments/payments_backend_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues(const <String, Object>{}));
  tearDown(getIt.reset);

  for (final AppEnvironment environment in AppEnvironment.values) {
    test('configures dependencies for $environment', () async {
      validateAppEnvironment(environment, environment.name);
      await configureDependencies(environment);
      expect(getIt<AppEnvironment>(), environment);
      expect(getIt<LocalDiagnostics>().environment, environment);
      expect(getIt<LocalDiagnostics>(), same(getIt<LocalDiagnostics>()));
      expect(getIt<MamoPaymentRouter>(), same(getIt<MamoPaymentRouter>()));
      expect(
        getIt<MamoPaymentRouter>().router,
        same(getIt<MamoPaymentRouter>().router),
      );
      expect(
        getIt<PaymentsBackendClient>(),
        same(getIt<PaymentsBackendClient>()),
      );
      expect(getIt<PaymentsBackendClient>(), isA<MockPaymentsBackend>());
      expect(
        getIt<PaymentsRemoteDataSource>(),
        same(getIt<PaymentsRemoteDataSource>()),
      );
      expect(getIt<PaymentsRepository>(), same(getIt<PaymentsRepository>()));
      expect(getIt<LoadPaymentsUseCase>(), same(getIt<LoadPaymentsUseCase>()));
      expect(
        getIt<CreatePaymentRequestUseCase>(),
        same(getIt<CreatePaymentRequestUseCase>()),
      );
      expect(
        getIt<DecidePaymentUseCase>(),
        same(getIt<DecidePaymentUseCase>()),
      );
      expect(
        getIt<RefreshPaymentsUseCase>(),
        same(getIt<RefreshPaymentsUseCase>()),
      );
      expect(getIt<LocalAuthClient>(), same(getIt<LocalAuthClient>()));
      expect(getIt<LocalAuthRepository>(), same(getIt<LocalAuthRepository>()));
      expect(
        getIt<IsLocalAuthSupportedUseCase>(),
        same(getIt<IsLocalAuthSupportedUseCase>()),
      );
      expect(
        getIt<LocalAuthenticationUseCase>(),
        same(getIt<LocalAuthenticationUseCase>()),
      );
      expect(
        getIt<StopLocalAuthenticationUseCase>(),
        same(getIt<StopLocalAuthenticationUseCase>()),
      );
      expect(getIt<PaymentsCubit>(), same(getIt<PaymentsCubit>()));
      expect(getIt<SharedPreferences>(), same(getIt<SharedPreferences>()));
      expect(
        getIt<ThemePreferenceLocalDataSource>(),
        same(getIt<ThemePreferenceLocalDataSource>()),
      );
      expect(
        getIt<ThemePreferenceRepository>(),
        same(getIt<ThemePreferenceRepository>()),
      );
      expect(
        getIt<LoadThemePreferenceUseCase>(),
        same(getIt<LoadThemePreferenceUseCase>()),
      );
      expect(
        getIt<SaveThemePreferenceUseCase>(),
        same(getIt<SaveThemePreferenceUseCase>()),
      );
      expect(getIt<ThemeModeCubit>(), same(getIt<ThemeModeCubit>()));
    });
  }

  test('rejects missing, unknown, or mismatched native flavors', () {
    for (final String? native in <String?>[null, 'unknown', 'prod']) {
      expect(
        () => validateAppEnvironment(AppEnvironment.dev, native),
        throwsA(isA<AppEnvironmentMismatch>()),
      );
    }
  });

  testWidgets('invalid startup shows safe UI before registering dependencies', (
    tester,
  ) async {
    final TestDefaultBinaryMessenger messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async => null,
    );
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    final AppEnvironment mismatch = appFlavor == 'dev'
        ? AppEnvironment.prod
        : AppEnvironment.dev;
    await bootstrap(mismatch);
    await tester.pumpAndSettle();
    expect(getIt.isRegistered<AppEnvironment>(), isFalse);
    expect(getIt.isRegistered<MamoPaymentRouter>(), isFalse);
    expect(getIt.isRegistered<PaymentsCubit>(), isFalse);
    expect(find.text('Unable to continue'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });

  test('framework and platform handlers log safely without navigating', () {
    final void Function(FlutterErrorDetails)? previousFlutter =
        FlutterError.onError;
    final bool Function(Object, StackTrace)? previousPlatform =
        PlatformDispatcher.instance.onError;
    final ErrorWidgetBuilder previousBuilder = ErrorWidget.builder;
    addTearDown(() {
      FlutterError.onError = previousFlutter;
      PlatformDispatcher.instance.onError = previousPlatform;
      ErrorWidget.builder = previousBuilder;
    });
    final List<String> records = <String>[];
    configureErrorHandling(
      LocalDiagnostics(environment: AppEnvironment.dev, write: records.add),
    );
    FlutterError.onError!(
      FlutterErrorDetails(exception: _SensitiveException()),
    );
    expect(
      PlatformDispatcher.instance.onError!(
        _SensitiveException(),
        StackTrace.current,
      ),
      isTrue,
    );
    expect(records, hasLength(2));
    expect(jsonDecode(records[0])['origin'], 'framework');
    expect(jsonDecode(records[1])['origin'], 'platform');
    expect(records.join(), isNot(contains('PRIVATE_PAYLOAD')));
  });

  test('diagnostics include only bounded app locations and fixed metadata', () {
    final List<String> records = <String>[];
    LocalDiagnostics(
      environment: AppEnvironment.dev,
      write: records.add,
    ).record(
      AppFailureCode.startupFailed,
      ErrorOrigin.startup,
      stack: StackTrace.fromString(
        'PRIVATE_PAYLOAD /private/file.dart:1:2\n${List<String>.generate(30, (index) => 'package:mamo_payment_approval_challenge/app/bootstrap.dart:$index:1').join('\n')}',
      ),
    );
    final Map<String, dynamic> record =
        jsonDecode(records.single) as Map<String, dynamic>;
    expect(
      record.keys,
      unorderedEquals(<String>['code', 'origin', 'environment', 'locations']),
    );
    expect(record['locations'], hasLength(12));
    expect(records.single, isNot(contains('PRIVATE_PAYLOAD')));
    expect(records.single, isNot(contains('/private/')));
  });
}

class _SensitiveException implements Exception {
  @override
  String toString() =>
      throw StateError('PRIVATE_PAYLOAD must not be serialized');
}
