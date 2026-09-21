import 'package:flutter/material.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/common/data/appearance/models/theme_preference.dart';
import 'package:mamo_payment_approval_challenge/features/settings/models/theme_mode_option_data.dart';

/// A single row of the appearance-mode chooser. The selected state is conveyed
/// by a filled indicator icon and radio selection semantics, never by colour
/// alone, and the row stays at least the minimum touch-target height.
class ThemeModeOption extends StatelessWidget {
  const ThemeModeOption({
    required this.data,
    required this.isSelected,
    required this.onSelected,
    super.key,
  });

  final ThemeModeOptionData data;
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
