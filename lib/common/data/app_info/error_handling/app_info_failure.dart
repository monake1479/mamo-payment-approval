import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_info_failure.freezed.dart';

/// Typed failure of the application-information domain. The platform could
/// not report the installed package identity.
@freezed
sealed class AppInfoFailure with _$AppInfoFailure {
  const AppInfoFailure._();

  const factory AppInfoFailure.unavailable() = AppInfoUnavailableFailure;

  String get code => switch (this) {
    AppInfoUnavailableFailure() => 'app_info.unavailable',
  };
}
