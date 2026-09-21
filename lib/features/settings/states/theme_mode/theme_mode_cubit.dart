import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/use_cases/load_theme_preference_use_case.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/use_cases/save_theme_preference_use_case.dart';
import 'package:mamo_payment_approval_challenge/features/settings/states/theme_mode/theme_mode_state.dart';

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
  /// The new value is emitted first so the change is instant. Persistence runs
  /// afterwards; its typed result is intentionally not surfaced because
  /// appearance is non-critical and the selection is already effective for the
  /// session. A failed write simply will not survive a restart, and the user can
  /// retry by selecting again (see ADR 0012).
  Future<void> select(ThemePreference preference) async {
    if (preference == state.preference) {
      return;
    }
    emit(ThemeModeState(preference: preference));
    await _savePreference(preference);
  }
}
