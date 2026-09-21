import 'package:injectable/injectable.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_approval/common/data/appearance/theme_preference_repository.dart';

/// Returns the persisted appearance preference, defaulting to the system mode.
@lazySingleton
class LoadThemePreferenceUseCase {
  const LoadThemePreferenceUseCase(this._repository);

  final ThemePreferenceRepository _repository;

  ThemePreference call() => _repository.read();
}
