import 'package:flutter/material.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/features/settings/widgets/about_bullet_list.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// The static part of the About section: what the application does and what
/// has been delivered. It is the in-app counterpart of the repository handover
/// notes.
class AboutSummaryCard extends StatelessWidget {
  const AboutSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final TextStyle? headingStyle = theme.textTheme.titleSmall;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.compactPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(l10n.aboutAppDescription, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppTheme.itemGap),
            Semantics(
              header: true,
              child: Text(l10n.aboutDeliveredHeading, style: headingStyle),
            ),
            const SizedBox(height: AppTheme.smallGap),
            AboutBulletList(
              items: <String>[
                l10n.aboutFeaturePaymentScreens,
                l10n.aboutFeatureApprovalFlow,
                l10n.aboutFeatureDeviceAuthentication,
                l10n.aboutFeatureReviewerDelivery,
                l10n.aboutFeatureAppearance,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
