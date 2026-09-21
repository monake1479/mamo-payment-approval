import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_approval/features/settings/pages/settings_page.dart';
import 'package:mamo_approval/features/settings/states/theme_mode/theme_mode_cubit.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

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

    await tester.tap(find.bySemanticsIdentifier('settings.themeMode.dark'));
    await tester.pumpAndSettle();

    expect(cubit.state.preference, ThemePreference.dark);
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
}
