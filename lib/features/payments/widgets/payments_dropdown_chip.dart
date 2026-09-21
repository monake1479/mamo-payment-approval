import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';

/// One entry of a [PaymentsDropdownChip] menu.
class PaymentsDropdownOption<T> {
  const PaymentsDropdownOption({
    required this.value,
    required this.label,
    required this.identifier,
  });

  final T value;
  final String label;

  /// Stable semantics identifier for the menu item.
  final String identifier;
}

/// Chip that opens a menu of [options]. It is an [ActionChip], so its ink
/// response is clipped to the chip's own shape while the padded touch target
/// stays at least 48 logical pixels. The menu is a route on the root
/// navigator, anchored under the chip, so it never lands inside the
/// Home/Payments pager.
class PaymentsDropdownChip<T> extends StatelessWidget {
  const PaymentsDropdownChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.tooltip,
    required this.options,
    required this.onSelected,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final String tooltip;
  final List<PaymentsDropdownOption<T>> options;
  final ValueChanged<T> onSelected;

  Future<void> _open(BuildContext context) async {
    final RenderBox chip = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(
              context,
              rootNavigator: true,
            ).overlay!.context.findRenderObject()!
            as RenderBox;
    final Offset topLeft = chip.localToGlobal(
      Offset(0, chip.size.height),
      ancestor: overlay,
    );
    final Offset bottomRight = chip.localToGlobal(
      chip.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    final T? picked = await showMenu<T>(
      context: context,
      useRootNavigator: true,
      position: RelativeRect.fromRect(
        Rect.fromPoints(topLeft, bottomRight),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry<T>>[
        for (final PaymentsDropdownOption<T> option in options)
          PopupMenuItem<T>(
            value: option.value,
            child: Semantics(
              identifier: option.identifier,
              child: Text(option.label),
            ),
          ),
      ],
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(icon),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppTheme.smallGap / 2,
        children: <Widget>[
          // A long label gives way instead of pushing the arrow out of the
          // chip at large text sizes.
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
      tooltip: tooltip,
      backgroundColor: selected ? colors.primaryContainer : null,
      onPressed: () => unawaited(_open(context)),
    );
  }
}
