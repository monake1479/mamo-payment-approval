import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/app/config/app_environment.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/common/data/app_info/error_handling/app_info_failure.dart';
import 'package:mamo_approval/features/settings/states/about/about_cubit.dart';
import 'package:mamo_approval/features/settings/states/about/about_state.dart';
import 'package:mamo_approval/features/settings/widgets/about_section.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

import '../../../support/app_info_test_support.dart';

Widget _wrap(AboutCubit cubit, {ThemeData? theme}) =>
    BlocProvider<AboutCubit>.value(
      value: cubit,
      child: MaterialApp(
        theme: theme ?? AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppTheme.compactPadding),
            child: AboutSection(),
          ),
        ),
      ),
    );

void main() {
  testWidgets('shows a loading indicator before details arrive', (
    WidgetTester tester,
  ) async {
    final AboutCubit cubit = createAboutCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrap(cubit));
    await tester.pump();

    expect(find.bySemanticsIdentifier('settings.about'), findsOneWidget);
    expect(
      find.bySemanticsIdentifier('settings.about.loading'),
      findsOneWidget,
    );
    expect(find.text('Loading app details…'), findsOneWidget);
    expect(find.bySemanticsIdentifier('settings.about.version'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'renders version, build, environment, package, and availability',
    (WidgetTester tester) async {
      final AboutCubit cubit = createAboutCubit(
        environment: AppEnvironment.staging,
      );
      addTearDown(cubit.close);
      await cubit.load();

      await tester.pumpWidget(_wrap(cubit));
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);
      expect(find.text('1.2.3'), findsOneWidget);
      expect(find.text('Build'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
      expect(find.text('Environment'), findsOneWidget);
      expect(find.text('Staging'), findsOneWidget);
      expect(find.text('Package'), findsOneWidget);
      expect(find.text('mamo.payment.approval.dev'), findsOneWidget);
      expect(find.text('Device authentication'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.byIcon(Icons.fingerprint), findsOneWidget);
      expect(find.text('What is included'), findsOneWidget);
      expect(
        find.text(
          'App content is hidden in the app switcher while the app is in the '
          'background',
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier('settings.about.deviceAuthentication'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier('settings.about.loading'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shows device authentication as not available', (
    WidgetTester tester,
  ) async {
    final AboutCubit cubit = createAboutCubit(
      isDeviceAuthenticationSupported: false,
    );
    addTearDown(cubit.close);
    await cubit.load();

    await tester.pumpWidget(_wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Not available'), findsOneWidget);
    expect(find.text('Available'), findsNothing);
    expect(find.byIcon(Icons.block_outlined), findsOneWidget);
    expect(find.byIcon(Icons.fingerprint), findsNothing);
  });

  testWidgets('shows the failure with a retry that reloads', (
    WidgetTester tester,
  ) async {
    final AboutCubit cubit = createAboutCubit(
      packageInfo: FakePackageInfoPlatform(error: Exception('channel down')),
    );
    addTearDown(cubit.close);
    await cubit.load();

    await tester.pumpWidget(_wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('settings.about.error'), findsOneWidget);
    expect(find.text('App details could not be loaded.'), findsOneWidget);
    expect(find.bySemanticsIdentifier('settings.about.version'), findsNothing);
    final Size retrySize = tester.getSize(
      find.bySemanticsIdentifier('settings.about.retry'),
    );
    expect(retrySize.height, greaterThanOrEqualTo(AppTheme.minimumTouchTarget));

    await tester.tap(find.bySemanticsIdentifier('settings.about.retry'));
    await tester.pumpAndSettle();

    // The fake keeps failing, so a retry reports the same failure again
    // rather than pretending the platform recovered.
    expect(
      cubit.state,
      const AboutState.failed(failure: AppInfoFailure.unavailable()),
    );
    expect(find.bySemanticsIdentifier('settings.about.error'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final ThemeData theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
    testWidgets(
      'renders in ${theme.brightness} at compact width with enlarged text',
      (WidgetTester tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final AboutCubit cubit = createAboutCubit();
        addTearDown(cubit.close);
        await cubit.load();

        await tester.pumpWidget(_wrap(cubit, theme: theme));
        await tester.pumpAndSettle();

        expect(find.text('1.2.3'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
