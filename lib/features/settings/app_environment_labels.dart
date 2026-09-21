import 'package:mamo_approval/app/config/app_environment.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// Localized display name of the active launch environment (native flavor).
String appEnvironmentLabel(AppEnvironment environment, AppLocalizations l10n) =>
    switch (environment) {
      AppEnvironment.dev => l10n.aboutEnvironmentDev,
      AppEnvironment.staging => l10n.aboutEnvironmentStaging,
      AppEnvironment.prod => l10n.aboutEnvironmentProd,
    };
