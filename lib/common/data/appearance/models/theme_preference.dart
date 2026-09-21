/// User-selectable appearance mode for the application.
///
/// This is a domain-level type and deliberately free of Flutter imports;
/// presentation maps it onto a Material `ThemeMode`. The default is
/// [ThemePreference.system], which follows the device appearance.
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
