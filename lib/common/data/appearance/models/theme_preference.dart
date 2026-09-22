import 'package:flutter/material.dart' show ThemeMode;

/// User-selectable appearance mode for the application.
///
/// The default is [ThemePreference.system], which follows the device
/// appearance. [ThemePreferenceMaterial] maps it onto the Flutter [ThemeMode]
/// consumed by `MaterialApp`.
enum ThemePreference {
  system,
  light,
  dark;

  /// Stable identifier persisted in storage.
  ///
  /// Kept separate from [name] so a future enum rename cannot silently
  /// invalidate a value already written to a user's device.
  String get storageValue => switch (this) {
    ThemePreference.system => 'system',
    ThemePreference.light => 'light',
    ThemePreference.dark => 'dark',
  };

  /// Resolves a persisted [storageValue] back to a preference.
  ///
  /// Returns `null` for a missing or unrecognized value so the caller can decide
  /// on a default rather than having one silently chosen here.
  static ThemePreference? fromStorageValue(String? value) => switch (value) {
    'system' => ThemePreference.system,
    'light' => ThemePreference.light,
    'dark' => ThemePreference.dark,
    _ => null,
  };
}

/// Maps a [ThemePreference] onto the Flutter [ThemeMode] consumed by
/// `MaterialApp`.
extension ThemePreferenceMaterial on ThemePreference {
  ThemeMode get materialThemeMode => switch (this) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };
}
