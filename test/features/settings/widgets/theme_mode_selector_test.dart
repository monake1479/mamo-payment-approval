import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_approval/features/settings/widgets/theme_mode_selector.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child, Brightness brightness) => MaterialApp(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  for (final Brightness brightness in Brightness.values) {
    testWidgets('renders every option and reports taps at $brightness', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final SemanticsHandle handle = tester.ensureSemantics();
      ThemePreference? tapped;

      await tester.pumpWidget(
        _wrap(
          ThemeModeSelector(
            selected: ThemePreference.system,
            onSelected: (ThemePreference preference) => tapped = preference,
          ),
          brightness,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(
        tester.getSemantics(
          find.bySemanticsIdentifier('settings.themeMode.system'),
        ),
        isSemantics(isSelected: true, isButton: true),
      );
      expect(
        tester.getSemantics(
          find.bySemanticsIdentifier('settings.themeMode.dark'),
        ),
        isSemantics(isSelected: false, isButton: true),
      );
      handle.dispose();
      expect(
        tester
            .getSize(find.bySemanticsIdentifier('settings.themeMode.dark'))
            .height,
        greaterThanOrEqualTo(AppTheme.minimumTouchTarget),
      );

      await tester.tap(find.bySemanticsIdentifier('settings.themeMode.dark'));
      expect(tapped, ThemePreference.dark);
      expect(tester.takeException(), isNull);
    });
  }
}
