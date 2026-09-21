import 'package:flutter/material.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';

class PaymentDetailField extends StatelessWidget {
  const PaymentDetailField({
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
    );
  }
}
