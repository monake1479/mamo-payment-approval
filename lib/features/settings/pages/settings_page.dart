import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/common/data/appearance/error_handling/appearance_failure.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_approval/common/widgets/scrolled_page_body.dart';
import 'package:mamo_approval/features/settings/states/theme_mode/theme_mode_cubit.dart';
import 'package:mamo_approval/features/settings/states/theme_mode/theme_mode_state.dart';
import 'package:mamo_approval/features/settings/widgets/about_section.dart';
import 'package:mamo_approval/features/settings/widgets/theme_mode_selector.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// Settings screen. Hosts the appearance-mode chooser and the About section;
/// it is the discoverable home for application preferences and information.
/// It reads the process-wide `ThemeModeCubit` from above; the About section
/// owns its own state.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  /// Resolves the appearance failure to safe localized copy; the failure
  /// contract itself carries no user-facing text.
  String _appearanceFailureMessage(
    AppearanceFailure failure,
    AppLocalizations l10n,
  ) => switch (failure) {
    AppearancePersistenceFailedFailure() => l10n.appearancePersistenceFailed,
  };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          identifier: 'settings.back',
          child: IconButton(
            tooltip: l10n.settingsBackLabel,
            onPressed: () => unawaited(Navigator.of(context).maybePop()),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        title: Text(l10n.settingsTitle),
      ),
      body: SafeArea(
        child: BlocListener<ThemeModeCubit, ThemeModeState>(
          listenWhen: (ThemeModeState previous, ThemeModeState current) =>
              previous.persistenceFailure == null &&
              current.persistenceFailure != null,
          listener: (BuildContext context, ThemeModeState state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _appearanceFailureMessage(state.persistenceFailure!, l10n),
                ),
              ),
            );
          },
          child: ScrolledPageBody(
            child: Semantics(
              identifier: 'settings.page',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.settingsAppearanceSectionTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: AppTheme.itemGap),
                  BlocBuilder<ThemeModeCubit, ThemeModeState>(
                    builder: (BuildContext context, ThemeModeState state) {
                      return ThemeModeSelector(
                        selected: state.preference,
                        onSelected: (ThemePreference preference) => unawaited(
                          context.read<ThemeModeCubit>().select(preference),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.sectionGap),
                  const AboutSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
