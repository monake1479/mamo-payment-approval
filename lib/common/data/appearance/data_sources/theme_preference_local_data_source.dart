import 'package:injectable/injectable.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/error_handling/appearance_failure.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/result.dart';
import 'package:mamo_payment_approval_challenge/common/result/models/unit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the appearance preference in `SharedPreferences`.
///
/// This is the single concrete data source for the appearance domain, like
/// `LocalAuthClient` for device authentication. It owns the storage SDK calls
/// and translates storage failures into typed results.
///
/// [read] is total: a missing or unrecognized stored value is not an error, it
/// means "follow the system", so it returns [ThemePreference.system] rather than
/// a failure. [write] can fail, so it returns a typed [AppearanceFailure].
@lazySingleton
class ThemePreferenceLocalDataSource {
  const ThemePreferenceLocalDataSource(this._preferences);

  static const String _preferenceKey = 'appearance.theme_preference';

  final SharedPreferences _preferences;

  ThemePreference read() {
    try {
      return ThemePreference.fromStorageValue(
            _preferences.getString(_preferenceKey),
          ) ??
          ThemePreference.system;
    } on Exception {
      return ThemePreference.system;
    }
  }

  Future<Result<AppearanceFailure, Unit>> write(
    ThemePreference preference,
  ) async {
    try {
      final bool stored = await _preferences.setString(
        _preferenceKey,
        preference.storageValue,
      );
      return stored
          ? const Result<AppearanceFailure, Unit>.success(unit)
          : const Result<AppearanceFailure, Unit>.failure(
              AppearanceFailure.persistenceFailed(),
            );
    } on Exception {
      return const Result<AppearanceFailure, Unit>.failure(
        AppearanceFailure.persistenceFailed(),
      );
    }
  }
}
