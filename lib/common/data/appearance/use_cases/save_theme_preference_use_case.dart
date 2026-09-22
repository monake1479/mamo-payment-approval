import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/appearance/error_handling/appearance_failure.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_approval/common/data/appearance/theme_preference_repository.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:mamo_approval/common/result/models/unit.dart';

/// Persists the selected appearance preference, returning a typed failure when
/// the write cannot be completed.
@lazySingleton
class SaveThemePreferenceUseCase {
  const SaveThemePreferenceUseCase(this._repository);

  final ThemePreferenceRepository _repository;

  Future<Result<AppearanceFailure, Unit>> call(ThemePreference preference) =>
      _repository.write(preference);
}
