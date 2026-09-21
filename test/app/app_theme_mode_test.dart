import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_approval/app/app.dart';
import 'package:mamo_approval/app/navigation/app_router.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_approval/common/data/device_authentication/local_auth_repository.dart';
import 'package:mamo_approval/common/data/device_authentication/use_cases/local_authentication_use_case.dart';
import 'package:mamo_approval/common/data/device_authentication/use_cases/stop_local_authentication_use_case.dart';
import 'package:mamo_approval/common/data/payments/models/payment.dart';
import 'package:mamo_approval/features/payments/states/payments/payments_cubit.dart';
import 'package:mamo_approval/features/settings/states/theme_mode/theme_mode_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/app_info_test_support.dart';
import '../support/appearance_test_support.dart';
import '../support/device_authentication_test_support.dart';
import '../support/payments_test_support.dart';

void main() {
  late MamoPaymentRouter appRouter;
  late GoRouter router;
  late PaymentsCubit paymentsCubit;
  late LocalAuthenticationUseCase authenticate;
  late StopLocalAuthenticationUseCase stop;

  setUp(() {
    registerAboutCubitFactory();
    final StubPaymentsBackend backend = StubPaymentsBackend(
      onLoad: () async => const <Payment>[],
    );
    paymentsCubit = createPaymentsCubit(backend);
    final LocalAuthRepository authRepository = LocalAuthRepository(
      FakeLocalAuthClient(),
    );
    authenticate = LocalAuthenticationUseCase(authRepository);
    stop = StopLocalAuthenticationUseCase(authRepository);
    appRouter = MamoPaymentRouter();
    router = appRouter.router;
  });

  tearDown(() async {
    appRouter.dispose();
    await paymentsCubit.close();
  });

  MamoPaymentApprovalApp buildApp(ThemeModeCubit themeModeCubit) =>
      MamoPaymentApprovalApp(
        router: router,
        paymentsCubit: paymentsCubit,
        themeModeCubit: themeModeCubit,
        authenticate: authenticate,
        stopAuthentication: stop,
      );

  ThemeMode? themeModeOf(WidgetTester tester) =>
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode;

  testWidgets('opens in the persisted dark appearance', (
    WidgetTester tester,
  ) async {
    final ThemeModeCubit themeModeCubit = await loadThemeModeCubit(
      stored: ThemePreference.dark,
    );
    addTearDown(themeModeCubit.close);

    await tester.pumpWidget(buildApp(themeModeCubit));
    await tester.pumpAndSettle();

    expect(themeModeOf(tester), ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.bySemanticsIdentifier('home.page')))
          .brightness,
      Brightness.dark,
    );
  });

  testWidgets('toggling in settings updates and persists the appearance', (
    WidgetTester tester,
  ) async {
    final SharedPreferences preferences = await resetSharedPreferences();
    final ThemeModeCubit themeModeCubit = createThemeModeCubit(preferences);
    addTearDown(themeModeCubit.close);

    await tester.pumpWidget(buildApp(themeModeCubit));
    await tester.pumpAndSettle();
    expect(themeModeOf(tester), ThemeMode.system);

    await tester.tap(find.bySemanticsIdentifier('home.openSettings'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('settings.page'), findsOneWidget);

    await tester.tap(find.bySemanticsIdentifier('settings.themeMode.dark'));
    await tester.pumpAndSettle();
    expect(themeModeOf(tester), ThemeMode.dark);

    // A fresh owner over the same storage restores the persisted choice.
    final ThemeModeCubit reloaded = createThemeModeCubit(preferences);
    addTearDown(reloaded.close);
    expect(reloaded.state.preference, ThemePreference.dark);

    await tester.tap(find.bySemanticsIdentifier('settings.back'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier('home.page'), findsOneWidget);
    expect(themeModeOf(tester), ThemeMode.dark);
    expect(tester.takeException(), isNull);
  });
}
