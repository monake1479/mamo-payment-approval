import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/bootstrap.dart';
import 'package:mamo_payment_approval_challenge/app/config/app_environment.dart';
import 'package:mamo_payment_approval_challenge/app/di/configure_dependencies.dart';
import 'package:mamo_payment_approval_challenge/app/diagnostics/local_diagnostics.dart';
import 'package:mamo_payment_approval_challenge/app/errors/app_failure.dart';
import 'package:mamo_payment_approval_challenge/app/errors/configure_error_handling.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payment_operations.dart';
import 'package:mamo_payment_approval_challenge/features/payments/domain/payments_repository.dart';
import 'package:mamo_payment_approval_challenge/features/payments/presentation/cubit/payments_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(getIt.reset);

  for (final AppEnvironment environment in AppEnvironment.values) {
    test('configures dependencies for $environment', () async {
      validateAppEnvironment(environment, environment.name);
      await configureDependencies(environment);
      expect(getIt<AppEnvironment>(), environment);
      expect(getIt<LocalDiagnostics>().environment, environment);
      expect(getIt<LocalDiagnostics>(), same(getIt<LocalDiagnostics>()));
      expect(getIt<PaymentsRepository>(), same(getIt<PaymentsRepository>()));
      expect(getIt<PaymentOperations>(), same(getIt<PaymentOperations>()));
      expect(getIt<PaymentsCubit>(), same(getIt<PaymentsCubit>()));
      expect(getIt<GoRouter>(), same(getIt<GoRouter>()));
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
    final AppEnvironment mismatch = appFlavor == 'dev'
        ? AppEnvironment.prod
        : AppEnvironment.dev;
    await bootstrap(mismatch);
    await tester.pumpAndSettle();
    expect(getIt.isRegistered<AppEnvironment>(), isFalse);
    expect(getIt.isRegistered<GoRouter>(), isFalse);
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
