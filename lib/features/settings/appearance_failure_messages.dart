import 'package:mamo_approval/common/data/appearance/error_handling/appearance_failure.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// Resolves an appearance-domain failure to safe localized copy. Presentation
/// owns this mapping so the failure contract stays free of user-facing text.
String appearanceFailureMessage(
  AppearanceFailure failure,
  AppLocalizations l10n,
) => switch (failure) {
  AppearancePersistenceFailedFailure() => l10n.appearancePersistenceFailed,
};
