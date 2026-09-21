import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_approval/features/settings/states/theme_mode/theme_mode_cubit.dart';
import 'package:mamo_approval/features/settings/states/theme_mode/theme_mode_state.dart';
import 'package:mamo_approval/features/settings/widgets/theme_mode_selector.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// Settings screen. Currently hosts the appearance-mode chooser; it is the
/// discoverable home for future application preferences.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double horizontalPadding =
                constraints.maxWidth >= AppTheme.expandedBreakpoint
                ? AppTheme.pagePadding
                : AppTheme.compactPadding;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTheme.expandedContentWidth,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppTheme.sectionGap,
                    horizontalPadding,
                    AppTheme.sectionGap,
                  ),
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
                          builder:
                              (BuildContext context, ThemeModeState state) {
                                return ThemeModeSelector(
                                  selected: state.preference,
                                  onSelected: (ThemePreference preference) =>
                                      unawaited(
                                        context.read<ThemeModeCubit>().select(
                                          preference,
                                        ),
                                      ),
                                );
                              },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
