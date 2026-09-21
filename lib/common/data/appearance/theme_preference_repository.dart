import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/appearance/data_sources/theme_preference_local_data_source.dart';
import 'package:mamo_approval/common/data/appearance/error_handling/appearance_failure.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:mamo_approval/common/result/models/unit.dart';

/// Coordinates appearance persistence over [ThemePreferenceLocalDataSource].
///
/// It mirrors the use-case -> repository -> data-source layering used across the
/// app so presentation depends on use cases rather than the storage SDK, and it
/// keeps the appearance store swappable without touching those use cases.
@lazySingleton
class ThemePreferenceRepository {
  const ThemePreferenceRepository(this._dataSource);

  final ThemePreferenceLocalDataSource _dataSource;

  ThemePreference read() => _dataSource.read();

  Future<Result<AppearanceFailure, Unit>> write(ThemePreference preference) =>
      _dataSource.write(preference);
}
