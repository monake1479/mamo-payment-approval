import 'package:flutter/material.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';

/// Shared body for a pushed, vertically scrolling page: top-aligned content
/// limited to the expanded content width, with the compact/expanded horizontal
/// page padding and section spacing above and below.
class ScrolledPageBody extends StatelessWidget {
  const ScrolledPageBody({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
              child: child,
            ),
          ),
        );
      },
    );
  }
}
