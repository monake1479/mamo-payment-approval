import 'package:mamo_payment_approval_challenge/common/data/appearance/data_sources/theme_preference_local_data_source.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/theme_preference_repository.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/use_cases/load_theme_preference_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/use_cases/save_theme_preference_use_case.dart';
import 'package:mamo_payment_approval_challenge/features/settings/states/theme_mode/theme_mode_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// Resets `SharedPreferences` to a fresh in-memory store, optionally seeded with
/// a persisted appearance [stored] value, and returns the instance.
Future<SharedPreferences> resetSharedPreferences({
  ThemePreference? stored,
}) async {
  SharedPreferences.setMockInitialValues(const <String, Object>{});
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  if (stored != null) {
    await ThemePreferenceLocalDataSource(preferences).write(stored);
  }
  return preferences;
}

/// Installs a store whose writes always throw and returns a `SharedPreferences`
/// bound to it, for exercising the persistence-failure path.
Future<SharedPreferences> failingWriteSharedPreferences() async {
  SharedPreferencesStorePlatform.instance = _FailingWriteStore();
  SharedPreferences.resetStatic();
  return SharedPreferences.getInstance();
}

/// Builds a [ThemeModeCubit] over [preferences] with its initial preference
/// already hydrated from storage.
ThemeModeCubit createThemeModeCubit(SharedPreferences preferences) {
  final ThemePreferenceRepository repository = ThemePreferenceRepository(
    ThemePreferenceLocalDataSource(preferences),
  );
  return ThemeModeCubit(
    loadPreference: LoadThemePreferenceUseCase(repository),
    savePreference: SaveThemePreferenceUseCase(repository),
  )..loadInitial();
}

/// Convenience for widget tests: a hydrated [ThemeModeCubit], optionally opening
/// with a persisted [stored] preference.
Future<ThemeModeCubit> loadThemeModeCubit({ThemePreference? stored}) async {
  final SharedPreferences preferences = await resetSharedPreferences(
    stored: stored,
  );
  return createThemeModeCubit(preferences);
}

class _FailingWriteStore extends InMemorySharedPreferencesStore {
  _FailingWriteStore() : super.empty();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      throw const _StorageException();
}

class _StorageException implements Exception {
  const _StorageException();
}
