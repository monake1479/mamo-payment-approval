import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mamo_approval/app/config/app_environment.dart';
import 'package:mamo_approval/common/data/app_info/error_handling/app_info_failure.dart';
import 'package:mamo_approval/common/data/app_info/models/app_build_info.dart';

part 'about_state.freezed.dart';

/// Presentation state of the About section: the installed build identity and
/// whether native device authentication is available on this device.
///
/// The section is loaded once per visit. [AboutLoaded] carries everything the
/// section renders; [AboutFailed] means the platform could not report the build
/// identity and the user may retry.
@freezed
sealed class AboutState with _$AboutState {
  const factory AboutState.loading() = AboutLoading;

  const factory AboutState.loaded({
    required AppBuildInfo buildInfo,
    required AppEnvironment environment,
    required bool isDeviceAuthenticationAvailable,
  }) = AboutLoaded;

  const factory AboutState.failed({required AppInfoFailure failure}) =
      AboutFailed;
}
