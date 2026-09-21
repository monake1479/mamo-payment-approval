import 'package:flutter_test/flutter_test.dart';
import 'package:mamo_approval/common/data/appearance/data_sources/theme_preference_local_data_source.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_approval/common/data/appearance/theme_preference_repository.dart';
import 'package:mamo_approval/common/data/appearance/use_cases/load_theme_preference_use_case.dart';
import 'package:mamo_approval/common/data/appearance/use_cases/save_theme_preference_use_case.dart';
import 'package:mamo_approval/features/settings/states/theme_mode/theme_mode_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

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

/// Installs a store whose writes throw and returns a `SharedPreferences` bound
/// to it, for exercising the persistence-failure path. With [failingWrites]
/// set, only that many writes throw and later writes succeed, which exercises
/// retry. The default store is restored when the test ends.
Future<SharedPreferences> failingWriteSharedPreferences({
  int? failingWrites,
}) async {
  SharedPreferencesStorePlatform.instance = _FailingWriteStore(failingWrites);
  SharedPreferences.resetStatic();
  addTearDown(_restoreSharedPreferences);
  return SharedPreferences.getInstance();
}

/// Installs a store that cannot be opened at all, for exercising composition
/// when platform preferences are unavailable. Restored when the test ends.
void installUnavailableSharedPreferencesStore() {
  SharedPreferencesStorePlatform.instance = _UnavailableStore();
  SharedPreferences.resetStatic();
  addTearDown(_restoreSharedPreferences);
}

void _restoreSharedPreferences() {
  SharedPreferences.setMockInitialValues(const <String, Object>{});
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
  _FailingWriteStore(this._remainingFailures) : super.empty();

  int? _remainingFailures;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    final int? remaining = _remainingFailures;
    if (remaining == null) {
      throw const _StorageException();
    }
    if (remaining > 0) {
      _remainingFailures = remaining - 1;
      throw const _StorageException();
    }
    return super.setValue(valueType, key, value);
  }
}

class _UnavailableStore extends InMemorySharedPreferencesStore {
  _UnavailableStore() : super.empty();

  @override
  Future<Map<String, Object>> getAll() async => throw const _StorageException();

  @override
  Future<Map<String, Object>> getAllWithParameters(
    GetAllParameters parameters,
  ) async => throw const _StorageException();
}

class _StorageException implements Exception {
  const _StorageException();
}
