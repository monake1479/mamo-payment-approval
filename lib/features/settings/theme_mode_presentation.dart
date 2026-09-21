import 'package:flutter/material.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/models/theme_preference.dart';

/// Maps the domain [ThemePreference] onto the Flutter [ThemeMode] consumed by
/// `MaterialApp`, keeping the domain enum free of Flutter imports.
extension ThemePreferenceMaterial on ThemePreference {
  ThemeMode get materialThemeMode => switch (this) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };
}
