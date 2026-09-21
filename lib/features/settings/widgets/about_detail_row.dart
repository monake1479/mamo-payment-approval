import 'package:flutter/material.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';

/// One labelled value in the About details card, mirroring the payment detail
/// field. The value is selectable so a reviewer can copy the package
/// identifier or version; the label and value stay separate accessibility
/// nodes so the selectable value keeps its own actions.
class AboutDetailRow extends StatelessWidget {
  const AboutDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.semanticIdentifier,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final String semanticIdentifier;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      identifier: semanticIdentifier,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.compactPadding,
          vertical: AppTheme.itemGap,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: AppTheme.itemGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppTheme.smallGap),
                  SelectableText(value, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
