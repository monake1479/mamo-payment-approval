import 'package:mamo_approval/common/data/app_info/error_handling/app_info_failure.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// Resolves an application-information failure to safe localized copy.
/// Presentation owns this mapping so the failure contract stays free of
/// user-facing text.
String aboutFailureMessage(AppInfoFailure failure, AppLocalizations l10n) =>
    switch (failure) {
      AppInfoUnavailableFailure() => l10n.aboutDetailsUnavailable,
    };
