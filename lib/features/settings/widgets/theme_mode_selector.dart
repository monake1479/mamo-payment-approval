import 'package:flutter/material.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

/// A mutually exclusive appearance-mode chooser offering System, Light, and
/// Dark. The selected option is conveyed by both a filled indicator icon and
/// accessibility state, never by colour alone, and every option is a full-width
/// target taller than the minimum touch size at large text scales.
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
    final List<_ThemeModeOptionData> options = <_ThemeModeOptionData>[
      _ThemeModeOptionData(
        value: ThemePreference.system,
        icon: Icons.brightness_auto_outlined,
        label: l10n.themeModeSystemLabel,
        description: l10n.themeModeSystemDescription,
      ),
      _ThemeModeOptionData(
        value: ThemePreference.light,
        icon: Icons.light_mode_outlined,
        label: l10n.themeModeLightLabel,
        description: l10n.themeModeLightDescription,
      ),
      _ThemeModeOptionData(
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
            for (final (int index, _ThemeModeOptionData option)
                in options.indexed) ...<Widget>[
              if (index > 0) const Divider(height: 1),
              _ThemeModeOption(
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

class _ThemeModeOptionData {
  const _ThemeModeOptionData({
    required this.value,
    required this.icon,
    required this.label,
    required this.description,
  });

  final ThemePreference value;
  final IconData icon;
  final String label;
  final String description;
}

class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.data,
    required this.isSelected,
    required this.onSelected,
  });

  final _ThemeModeOptionData data;
  final bool isSelected;
  final ValueChanged<ThemePreference> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color leadingColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return Semantics(
      identifier: 'settings.themeMode.${data.value.storageValue}',
      inMutuallyExclusiveGroup: true,
      selected: isSelected,
      child: InkWell(
        onTap: () => onSelected(data.value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppTheme.minimumTouchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.compactPadding,
              vertical: AppTheme.itemGap,
            ),
            child: Row(
              children: <Widget>[
                Icon(data.icon, color: leadingColor),
                const SizedBox(width: AppTheme.itemGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(data.label, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: AppTheme.smallGap),
                      Text(
                        data.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.itemGap),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
