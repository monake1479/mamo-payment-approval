import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// Fallback `SharedPreferences` store installed when the platform store cannot
/// be opened at startup.
///
/// It reads as empty and refuses every write, so the appearance preference
/// falls back to "follow the system" and each save reports a typed persistence
/// failure instead of silently pretending to persist. A cosmetic preference
/// must never block the payment app from starting.
class SessionOnlySharedPreferencesStore extends InMemorySharedPreferencesStore {
  SessionOnlySharedPreferencesStore() : super.empty();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}
