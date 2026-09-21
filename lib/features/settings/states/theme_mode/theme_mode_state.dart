import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';

part 'theme_mode_state.freezed.dart';

/// Presentation state for the application appearance mode.
@freezed
abstract class ThemeModeState with _$ThemeModeState {
  const factory ThemeModeState({required ThemePreference preference}) =
      _ThemeModeState;
}
