import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/app/config/app_environment.dart';
import 'package:mamo_approval/common/data/app_info/error_handling/app_info_failure.dart';
import 'package:mamo_approval/common/data/app_info/models/app_build_info.dart';
import 'package:mamo_approval/common/data/app_info/use_cases/load_app_build_info_use_case.dart';
import 'package:mamo_approval/common/data/device_authentication/use_cases/is_local_auth_supported_use_case.dart';
import 'package:mamo_approval/common/result/models/result.dart';
import 'package:mamo_approval/features/settings/states/about/about_state.dart';

/// Owns the About section state for one visit to the settings screen.
///
/// [load] is a single request-to-result operation: it reads the installed
/// build identity and probes device-authentication availability once, then
/// emits the combined result. It never starts authentication. The active
/// [AppEnvironment] is supplied by composition because it is a static launch
/// fact, not something fetched.
final class AboutCubit extends Cubit<AboutState> {
  factory AboutCubit({
    required LoadAppBuildInfoUseCase loadBuildInfo,
    required IsLocalAuthSupportedUseCase isLocalAuthSupported,
    required AppEnvironment environment,
  }) => AboutCubit._(loadBuildInfo, isLocalAuthSupported, environment);

  AboutCubit._(
    this._loadBuildInfo,
    this._isLocalAuthSupported,
    this._environment,
  ) : super(const AboutState.loading());

  final LoadAppBuildInfoUseCase _loadBuildInfo;
  final IsLocalAuthSupportedUseCase _isLocalAuthSupported;
  final AppEnvironment _environment;

  bool _inFlight = false;

  /// Loads the section data. A repeated call while a load is in flight is
  /// ignored so a retry cannot produce a duplicate completion; a call after a
  /// failure retries.
  Future<void> load() async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;
    try {
      if (state is! AboutLoading) {
        emit(const AboutState.loading());
      }
      final Future<Result<AppInfoFailure, AppBuildInfo>> buildInfo =
          _loadBuildInfo();
      final Future<bool> supported = _isLocalAuthSupported();
      final Result<AppInfoFailure, AppBuildInfo> buildInfoResult =
          await buildInfo;
      final bool isSupported = await supported;
      if (isClosed) {
        return;
      }
      emit(
        buildInfoResult.fold(
          onSuccess: (AppBuildInfo info) => AboutState.loaded(
            buildInfo: info,
            environment: _environment,
            isDeviceAuthenticationAvailable: isSupported,
          ),
          onFailure: (AppInfoFailure failure) =>
              AboutState.failed(failure: failure),
        ),
      );
    } finally {
      _inFlight = false;
    }
  }
}
