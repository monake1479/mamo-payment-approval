import 'package:flutter/material.dart';
import 'package:mamo_approval/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_approval/features/settings/models/theme_mode_option_data.dart';
import 'package:mamo_approval/features/settings/widgets/theme_mode_option.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

/// A mutually exclusive appearance-mode chooser offering System, Light, and
/// Dark. Each option is rendered by a [ThemeModeOption] and the group carries a
/// stable semantics identifier for end-to-end journeys.
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final ThemePreference selected;
  final ValueChanged<ThemePreference> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<ThemeModeOptionData> options = <ThemeModeOptionData>[
      ThemeModeOptionData(
        value: ThemePreference.system,
        icon: Icons.brightness_auto_outlined,
        label: l10n.themeModeSystemLabel,
        description: l10n.themeModeSystemDescription,
      ),
      ThemeModeOptionData(
        value: ThemePreference.light,
        icon: Icons.light_mode_outlined,
        label: l10n.themeModeLightLabel,
        description: l10n.themeModeLightDescription,
      ),
      ThemeModeOptionData(
        value: ThemePreference.dark,
        icon: Icons.dark_mode_outlined,
        label: l10n.themeModeDarkLabel,
        description: l10n.themeModeDarkDescription,
      ),
    ];
    return Semantics(
      identifier: 'settings.themeMode',
      container: true,
      explicitChildNodes: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            for (final (int index, ThemeModeOptionData option)
                in options.indexed) ...<Widget>[
              if (index > 0) const Divider(height: 1),
              ThemeModeOption(
                data: option,
                isSelected: option.value == selected,
                onSelected: onSelected,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
