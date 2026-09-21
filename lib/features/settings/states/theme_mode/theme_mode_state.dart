import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_approval/common/data/appearance/error_handling/appearance_failure.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';

part 'theme_mode_state.freezed.dart';

/// Presentation state for the application appearance mode.
///
/// [preference] is always the applied appearance. [persistenceFailure] is set
/// when the latest save of that preference failed, so presentation can tell the
/// user the choice will not survive a restart until it is selected again.
@freezed
abstract class ThemeModeState with _$ThemeModeState {
  const factory ThemeModeState({
    required ThemePreference preference,
    AppearanceFailure? persistenceFailure,
  }) = _ThemeModeState;
}
