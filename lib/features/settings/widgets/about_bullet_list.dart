import 'package:flutter/material.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';

/// A short static bulleted list. Each item is one text node for assistive
/// technology; the bullet glyph is decorative.
class AboutBulletList extends StatelessWidget {
  const AboutBulletList({required this.items, super.key});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodyMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final String item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.smallGap),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ExcludeSemantics(child: Text('•', style: style)),
                const SizedBox(width: AppTheme.smallGap),
                Expanded(child: Text(item, style: style)),
              ],
            ),
          ),
      ],
    );
  }
}
