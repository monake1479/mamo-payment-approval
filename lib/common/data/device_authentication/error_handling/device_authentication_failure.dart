import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_authentication_failure.freezed.dart';

@freezed
sealed class DeviceAuthenticationFailure with _$DeviceAuthenticationFailure {
  const DeviceAuthenticationFailure._();

  const factory DeviceAuthenticationFailure.cancelled() =
      DeviceAuthenticationCancelledFailure;

  const factory DeviceAuthenticationFailure.unavailable() =
      DeviceAuthenticationUnavailableFailure;

  const factory DeviceAuthenticationFailure.failed() =
      DeviceAuthenticationFailedFailure;

  String get code => switch (this) {
    DeviceAuthenticationCancelledFailure() => 'authentication.cancelled',
    DeviceAuthenticationUnavailableFailure() => 'authentication.unavailable',
    DeviceAuthenticationFailedFailure() => 'authentication.failed',
  };
}
