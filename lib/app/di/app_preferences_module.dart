import 'package:injectable/injectable.dart';
import 'package:mamo_approval/app/di/session_only_shared_preferences_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// Provides the process-wide `SharedPreferences` instance to dependency
/// injection. It is pre-resolved during composition so synchronous reads (such
/// as the initial appearance preference) are available before the first frame.
///
/// If the platform store cannot be opened, composition continues over a
/// [SessionOnlySharedPreferencesStore] rather than failing startup: the only
/// stored value is the non-critical appearance preference.
@module
abstract class AppPreferencesModule {
  @preResolve
  Future<SharedPreferences> sharedPreferences() async {
    try {
      return await SharedPreferences.getInstance();
    } on Exception {
      // A failed getInstance() clears its cached completer, so the retry below
      // opens the fallback store instead of re-awaiting the failed future.
      SharedPreferencesStorePlatform.instance =
          SessionOnlySharedPreferencesStore();
      return SharedPreferences.getInstance();
    }
  }
}
