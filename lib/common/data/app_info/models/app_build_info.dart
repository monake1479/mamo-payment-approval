import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_build_info.freezed.dart';

/// Build identity of the installed application as reported by the platform:
/// the marketing [version], the platform [buildNumber], and the installed
/// [packageName] (Android application ID or iOS bundle identifier).
@freezed
abstract class AppBuildInfo with _$AppBuildInfo {
  const factory AppBuildInfo({
    required String version,
    required String buildNumber,
    required String packageName,
  }) = _AppBuildInfo;
}
