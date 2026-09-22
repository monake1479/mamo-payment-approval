import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/common/data/appearance/error_handling/appearance_failure.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_approval/common/data/appearance/use_cases/load_theme_preference_use_case.dart';
import 'package:mamo_approval/common/data/appearance/use_cases/save_theme_preference_use_case.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:mamo_approval/common/result/models/unit.dart';
import 'package:mamo_approval/features/settings/states/theme_mode/theme_mode_state.dart';

/// Owns the selected appearance mode and drives `MaterialApp.themeMode`.
///
/// The default is [ThemePreference.system]. [loadInitial] hydrates the persisted
/// choice during composition; [select] applies a new choice immediately and
/// persists it.
final class ThemeModeCubit extends Cubit<ThemeModeState> {
  factory ThemeModeCubit({
    required LoadThemePreferenceUseCase loadPreference,
    required SaveThemePreferenceUseCase savePreference,
  }) => ThemeModeCubit._(loadPreference, savePreference);

  ThemeModeCubit._(this._loadPreference, this._savePreference)
    : super(const ThemeModeState(preference: ThemePreference.system));

  final LoadThemePreferenceUseCase _loadPreference;
  final SaveThemePreferenceUseCase _savePreference;

  /// Hydrates state from persisted storage. Called once during composition
  /// before the first frame so the app opens in the stored appearance.
  void loadInitial() {
    emit(ThemeModeState(preference: _loadPreference()));
  }

  /// Applies [preference] and persists it.
  ///
  /// The new value is emitted first so the change is instant, then the save
  /// runs. A failed save keeps the applied selection for the session and is
  /// surfaced through [ThemeModeState.persistenceFailure]; selecting the same
  /// option again retries the save. Reselecting an already persisted option is
  /// a no-op. A save result that arrives after a newer selection is discarded.
  Future<void> select(ThemePreference preference) async {
    final bool alreadyApplied = preference == state.preference;
    if (alreadyApplied && state.persistenceFailure == null) {
      return;
    }
    emit(ThemeModeState(preference: preference));
    final Result<AppearanceFailure, Unit> result = await _savePreference(
      preference,
    );
    if (isClosed || state.preference != preference) {
      return;
    }
    result.fold(
      onSuccess: (Unit _) {},
      onFailure: (AppearanceFailure failure) =>
          emit(state.copyWith(persistenceFailure: failure)),
    );
  }
}
