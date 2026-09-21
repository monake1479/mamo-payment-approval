import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/app/config/app_environment.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/common/data/app_info/error_handling/app_info_failure.dart';
import 'package:mamo_approval/features/settings/states/about/about_cubit.dart';
import 'package:mamo_approval/features/settings/states/about/about_state.dart';
import 'package:mamo_approval/features/settings/widgets/about_details_card.dart';
import 'package:mamo_approval/features/settings/widgets/about_section.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';

import '../../../support/app_info_test_support.dart';

Widget _wrap({ThemeData? theme}) => MaterialApp(
  theme: theme ?? AppTheme.light,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const Scaffold(
    body: SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.compactPadding),
      child: AboutSection(),
    ),
  ),
);

/// The cubit the section resolved from the locator, for state assertions.
AboutCubit _cubitOf(WidgetTester tester) =>
    tester.element(find.byType(AboutDetailsCard)).read<AboutCubit>();

void main() {
  testWidgets('shows a loading indicator before details arrive', (
    WidgetTester tester,
  ) async {
    registerAboutCubitFactory(
      packageInfo: FakePackageInfoPlatform(
        pending: Completer<PackageInfoData>(),
      ),
    );

    await tester.pumpWidget(_wrap());
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
      registerAboutCubitFactory(environment: AppEnvironment.staging);

      await tester.pumpWidget(_wrap());
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
    registerAboutCubitFactory(isDeviceAuthenticationSupported: false);

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Not available'), findsOneWidget);
    expect(find.text('Available'), findsNothing);
    expect(find.byIcon(Icons.block_outlined), findsOneWidget);
    expect(find.byIcon(Icons.fingerprint), findsNothing);
  });

  testWidgets('shows the failure with a retry that reloads', (
    WidgetTester tester,
  ) async {
    registerAboutCubitFactory(
      packageInfo: FakePackageInfoPlatform(error: Exception('channel down')),
    );

    await tester.pumpWidget(_wrap());
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
      _cubitOf(tester).state,
      const AboutState.failed(failure: AppInfoFailure.unavailable()),
    );
    expect(find.bySemanticsIdentifier('settings.about.error'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('closes its cubit when the section leaves the tree', (
    WidgetTester tester,
  ) async {
    registerAboutCubitFactory();

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    final AboutCubit cubit = _cubitOf(tester);
    expect(cubit.isClosed, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());

    expect(cubit.isClosed, isTrue);
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
        registerAboutCubitFactory();

        await tester.pumpWidget(_wrap(theme: theme));
        await tester.pumpAndSettle();

        expect(find.text('1.2.3'), findsOneWidget);
        expect(find.text('What is included'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
