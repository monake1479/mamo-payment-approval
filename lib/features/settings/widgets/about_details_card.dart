import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/features/settings/about_failure_messages.dart';
import 'package:mamo_approval/features/settings/app_environment_labels.dart';
import 'package:mamo_approval/features/settings/states/about/about_cubit.dart';
import 'package:mamo_approval/features/settings/states/about/about_state.dart';
import 'package:mamo_approval/features/settings/widgets/about_detail_row.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// The dynamic part of the About section: installed version, build number,
/// launch environment, package identifier, and a read-only indicator of
/// device-authentication availability. Renders the loading, failed (with
/// retry), and loaded states of [AboutCubit].
class AboutDetailsCard extends StatelessWidget {
  const AboutDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: BlocBuilder<AboutCubit, AboutState>(
        builder: (BuildContext context, AboutState state) => switch (state) {
          AboutLoading() => Padding(
            padding: const EdgeInsets.all(AppTheme.compactPadding),
            child: Semantics(
              identifier: 'settings.about.loading',
              liveRegion: true,
              child: Row(
                children: <Widget>[
                  const SizedBox.square(
                    dimension: AppTheme.sectionGap,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: AppTheme.itemGap),
                  Expanded(
                    child: Text(
                      l10n.aboutDetailsLoading,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AboutFailed(:final failure) => Padding(
            padding: const EdgeInsets.all(AppTheme.compactPadding),
            child: Semantics(
              identifier: 'settings.about.error',
              liveRegion: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.error_outline, color: theme.colorScheme.error),
                      const SizedBox(width: AppTheme.itemGap),
                      Expanded(
                        child: Text(
                          aboutFailureMessage(failure, l10n),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.itemGap),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Semantics(
                      identifier: 'settings.about.retry',
                      child: FilledButton.tonalIcon(
                        onPressed: () =>
                            unawaited(context.read<AboutCubit>().load()),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retryAction),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AboutLoaded(
            :final buildInfo,
            :final environment,
            :final isDeviceAuthenticationAvailable,
          ) =>
            Column(
              children: <Widget>[
                AboutDetailRow(
                  icon: Icons.tag,
                  label: l10n.aboutVersionLabel,
                  value: buildInfo.version,
                  semanticIdentifier: 'settings.about.version',
                ),
                const Divider(height: 1),
                AboutDetailRow(
                  icon: Icons.build_outlined,
                  label: l10n.aboutBuildNumberLabel,
                  value: buildInfo.buildNumber,
                  semanticIdentifier: 'settings.about.build',
                ),
                const Divider(height: 1),
                AboutDetailRow(
                  icon: Icons.layers_outlined,
                  label: l10n.aboutEnvironmentLabel,
                  value: appEnvironmentLabel(environment, l10n),
                  semanticIdentifier: 'settings.about.environment',
                ),
                const Divider(height: 1),
                AboutDetailRow(
                  icon: Icons.inventory_2_outlined,
                  label: l10n.aboutPackageIdLabel,
                  value: buildInfo.packageName,
                  semanticIdentifier: 'settings.about.packageId',
                ),
                const Divider(height: 1),
                AboutDetailRow(
                  icon: isDeviceAuthenticationAvailable
                      ? Icons.fingerprint
                      : Icons.block_outlined,
                  label: l10n.aboutDeviceAuthenticationLabel,
                  value: isDeviceAuthenticationAvailable
                      ? l10n.aboutDeviceAuthenticationAvailable
                      : l10n.aboutDeviceAuthenticationUnavailable,
                  semanticIdentifier: 'settings.about.deviceAuthentication',
                ),
              ],
            ),
        },
      ),
    );
  }
}
