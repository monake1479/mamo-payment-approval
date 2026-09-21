import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/app/di/configure_dependencies.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_approval/features/settings/pages/settings_page.dart';
import 'package:mamo_approval/features/settings/states/theme_mode/theme_mode_cubit.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';

import '../../../support/app_info_test_support.dart';
import '../../../support/appearance_test_support.dart';

Widget _wrap(ThemeModeCubit cubit) => BlocProvider<ThemeModeCubit>.value(
  value: cubit,
  child: MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const SettingsPage(),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(registerAboutCubitFactory);

  testWidgets('shows the appearance chooser and applies a selection', (
    WidgetTester tester,
  ) async {
    final ThemeModeCubit cubit = await loadThemeModeCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('settings.page'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);

    await tester.tap(find.bySemanticsIdentifier('settings.themeMode.dark'));
    await tester.pumpAndSettle();

    expect(cubit.state.preference, ThemePreference.dark);
    expect(tester.takeException(), isNull);
  });

  testWidgets('announces a failed save and keeps the selection applied', (
    WidgetTester tester,
  ) async {
    final ThemeModeCubit cubit = createThemeModeCubit(
      await failingWriteSharedPreferences(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrap(cubit));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsIdentifier('settings.themeMode.dark'));
    await tester.pumpAndSettle();

    expect(cubit.state.preference, ThemePreference.dark);
    expect(
      find.text(
        'Your appearance choice could not be saved. It stays applied for now; '
        'select it again to retry.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('marks the current preference as selected', (
    WidgetTester tester,
  ) async {
    final ThemeModeCubit cubit = await loadThemeModeCubit(
      stored: ThemePreference.light,
    );
    addTearDown(cubit.close);
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(_wrap(cubit));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(
        find.bySemanticsIdentifier('settings.themeMode.light'),
      ),
      isSemantics(isSelected: true),
    );
    handle.dispose();
  });

  testWidgets('shows the About section with loaded app details', (
    WidgetTester tester,
  ) async {
    final ThemeModeCubit cubit = await loadThemeModeCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrap(cubit));
    await tester.pumpAndSettle();

    expect(find.bySemanticsIdentifier('settings.about'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.bySemanticsIdentifier('settings.about.packageId'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('1.2.3'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
    expect(find.text('Development'), findsOneWidget);
    expect(find.text('mamo.payment.approval.dev'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the appearance chooser usable while About is loading', (
    WidgetTester tester,
  ) async {
    await getIt.reset();
    registerAboutCubitFactory(
      packageInfo: FakePackageInfoPlatform(
        pending: Completer<PackageInfoData>(),
      ),
    );
    final ThemeModeCubit cubit = await loadThemeModeCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrap(cubit));
    await tester.pump();

    expect(
      find.bySemanticsIdentifier('settings.about.loading'),
      findsOneWidget,
    );
    await tester.tap(find.bySemanticsIdentifier('settings.themeMode.light'));
    // pump() rather than pumpAndSettle(): the loading indicator keeps
    // animating while the platform answer is deliberately left pending.
    await tester.pump();

    expect(cubit.state.preference, ThemePreference.light);
    expect(tester.takeException(), isNull);
  });
}
