import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';

part 'theme_mode_option_data.freezed.dart';

/// Presentation data for one selectable appearance-mode option: the domain
/// [value] it represents and the localized copy and icon used to render it.
@freezed
abstract class ThemeModeOptionData with _$ThemeModeOptionData {
  const factory ThemeModeOptionData({
    required ThemePreference value,
    required IconData icon,
    required String label,
    required String description,
  }) = _ThemeModeOptionData;
}
