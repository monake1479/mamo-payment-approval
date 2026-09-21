import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides the process-wide `SharedPreferences` instance to dependency
/// injection. It is pre-resolved during composition so synchronous reads (such
/// as the initial appearance preference) are available before the first frame.
@module
abstract class AppPreferencesModule {
  @preResolve
  Future<SharedPreferences> sharedPreferences() =>
      SharedPreferences.getInstance();
}
