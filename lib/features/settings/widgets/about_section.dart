import 'package:flutter/material.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/features/settings/widgets/about_details_card.dart';
import 'package:mamo_approval/features/settings/widgets/about_summary_card.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// The About section of the settings screen: a heading, the loaded build and
/// device-authentication details, and the static description of the app.
/// Requires an `AboutCubit` above it in the tree.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Semantics(
      identifier: 'settings.about',
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              l10n.settingsAboutSectionTitle,
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: AppTheme.itemGap),
          const AboutDetailsCard(),
          const SizedBox(height: AppTheme.itemGap),
          const AboutSummaryCard(),
        ],
      ),
    );
  }
}
