import 'package:freezed_annotation/freezed_annotation.dart';

part 'appearance_failure.freezed.dart';

/// Typed appearance-domain failures.
///
/// Reading the stored preference is total (a missing or unrecognized value means
/// "follow the system"), so only persistence can fail. The stable [code] is the
/// application contract that presentation maps to safe localized copy.
@freezed
sealed class AppearanceFailure with _$AppearanceFailure {
  const AppearanceFailure._();

  const factory AppearanceFailure.persistenceFailed() =
      AppearancePersistenceFailedFailure;

  String get code => switch (this) {
    AppearancePersistenceFailedFailure() => 'appearance.persistence_failed',
  };
}
