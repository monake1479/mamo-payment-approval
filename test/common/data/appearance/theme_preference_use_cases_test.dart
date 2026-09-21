import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/common/data/appearance/data_sources/theme_preference_local_data_source.dart';
import 'package:mamo_approval/common/data/appearance/error_handling/appearance_failure.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_approval/common/data/appearance/theme_preference_repository.dart';
import 'package:mamo_approval/common/data/appearance/use_cases/load_theme_preference_use_case.dart';
import 'package:mamo_approval/common/data/appearance/use_cases/save_theme_preference_use_case.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:mamo_approval/common/result/models/unit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/appearance_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LoadThemePreferenceUseCase returns the stored preference', () async {
    final SharedPreferences preferences = await resetSharedPreferences(
      stored: ThemePreference.dark,
    );
    final LoadThemePreferenceUseCase useCase = LoadThemePreferenceUseCase(
      ThemePreferenceRepository(ThemePreferenceLocalDataSource(preferences)),
    );

    expect(useCase(), ThemePreference.dark);
  });

  test('LoadThemePreferenceUseCase defaults to system', () async {
    final SharedPreferences preferences = await resetSharedPreferences();
    final LoadThemePreferenceUseCase useCase = LoadThemePreferenceUseCase(
      ThemePreferenceRepository(ThemePreferenceLocalDataSource(preferences)),
    );

    expect(useCase(), ThemePreference.system);
  });

  test('SaveThemePreferenceUseCase persists the preference', () async {
    final SharedPreferences preferences = await resetSharedPreferences();
    final ThemePreferenceRepository repository = ThemePreferenceRepository(
      ThemePreferenceLocalDataSource(preferences),
    );
    final SaveThemePreferenceUseCase save = SaveThemePreferenceUseCase(
      repository,
    );

    final Result<AppearanceFailure, Unit> result = await save(
      ThemePreference.light,
    );

    expect(result, const Result<AppearanceFailure, Unit>.success(unit));
    expect(LoadThemePreferenceUseCase(repository)(), ThemePreference.light);
  });

  test('SaveThemePreferenceUseCase surfaces a persistence failure', () async {
    final SharedPreferences preferences = await failingWriteSharedPreferences();
    final SaveThemePreferenceUseCase save = SaveThemePreferenceUseCase(
      ThemePreferenceRepository(ThemePreferenceLocalDataSource(preferences)),
    );

    final Result<AppearanceFailure, Unit> result = await save(
      ThemePreference.dark,
    );

    expect(
      result,
      const Result<AppearanceFailure, Unit>.failure(
        AppearanceFailure.persistenceFailed(),
      ),
    );
  });
}
