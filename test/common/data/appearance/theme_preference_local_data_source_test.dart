import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/common/data/appearance/data_sources/theme_preference_local_data_source.dart';
import 'package:mamo_approval/common/data/appearance/error_handling/appearance_failure.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:mamo_approval/common/result/models/unit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/appearance_test_support.dart';

const String _preferenceKey = 'appearance.theme_preference';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ThemePreferenceLocalDataSource> dataSourceWith(
    Map<String, Object> seed,
  ) async {
    SharedPreferences.setMockInitialValues(seed);
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return ThemePreferenceLocalDataSource(preferences);
  }

  group('read', () {
    test('defaults to system when nothing is stored', () async {
      final ThemePreferenceLocalDataSource dataSource = await dataSourceWith(
        const <String, Object>{},
      );

      expect(dataSource.read(), ThemePreference.system);
    });

    for (final ThemePreference preference in ThemePreference.values) {
      test('returns the stored $preference value', () async {
        final ThemePreferenceLocalDataSource dataSource = await dataSourceWith(
          <String, Object>{_preferenceKey: preference.storageValue},
        );

        expect(dataSource.read(), preference);
      });
    }

    test('falls back to system for an unrecognized stored value', () async {
      final ThemePreferenceLocalDataSource dataSource = await dataSourceWith(
        const <String, Object>{_preferenceKey: 'sepia'},
      );

      expect(dataSource.read(), ThemePreference.system);
    });

    test(
      'falls back to system when the stored value is not a string',
      () async {
        final ThemePreferenceLocalDataSource dataSource = await dataSourceWith(
          const <String, Object>{_preferenceKey: 1},
        );

        expect(dataSource.read(), ThemePreference.system);
      },
    );
  });

  group('write', () {
    test('persists the preference and reports success', () async {
      final SharedPreferences preferences = await resetSharedPreferences();
      final ThemePreferenceLocalDataSource dataSource =
          ThemePreferenceLocalDataSource(preferences);

      final Result<AppearanceFailure, Unit> result = await dataSource.write(
        ThemePreference.dark,
      );

      expect(result, const Result<AppearanceFailure, Unit>.success(unit));
      expect(dataSource.read(), ThemePreference.dark);
    });

    test('maps a storage exception to a persistence failure', () async {
      final SharedPreferences preferences =
          await failingWriteSharedPreferences();
      final ThemePreferenceLocalDataSource dataSource =
          ThemePreferenceLocalDataSource(preferences);

      final Result<AppearanceFailure, Unit> result = await dataSource.write(
        ThemePreference.light,
      );

      expect(
        result,
        const Result<AppearanceFailure, Unit>.failure(
          AppearanceFailure.persistenceFailed(),
        ),
      );
    });
  });
}
