import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/debug_action/debug_action_cubit.dart';
import 'package:mamo_payment_approval_challenge/features/payments/states/debug_action/debug_action_state.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

class DebugPaymentAction extends StatelessWidget {
  const DebugPaymentAction({
    required this.positionCubit,
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final DebugActionCubit positionCubit;
  final bool enabled;
  final Future<void> Function() onPressed;

  static const double _extent = 56;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return BlocBuilder<DebugActionCubit, DebugActionPosition?>(
      bloc: positionCubit,
      builder: (BuildContext context, DebugActionPosition? savedPosition) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final EdgeInsets safe = MediaQuery.paddingOf(context);
            final bool expanded =
                constraints.maxWidth >= AppTheme.expandedBreakpoint;
            final double minX = safe.left + AppTheme.smallGap;
            final double minY = safe.top + AppTheme.smallGap;
            final double maxX =
                (constraints.maxWidth -
                        safe.right -
                        _extent -
                        AppTheme.smallGap)
                    .clamp(minX, double.infinity);
            final double maxY =
                (constraints.maxHeight -
                        safe.bottom -
                        _extent -
                        AppTheme.smallGap)
                    .clamp(minY, double.infinity);
            final double defaultY = expanded
                ? maxY
                : (maxY - AppTheme.compactNavigationHeight).clamp(minY, maxY);
            final DebugActionPosition position = _clamp(
              savedPosition ?? DebugActionPosition(x: maxX, y: defaultY),
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
            );
            if (savedPosition != null && savedPosition != position) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!positionCubit.isClosed) {
                  positionCubit.moveTo(position);
                }
              });
            }
            return Stack(
              children: <Widget>[
                Positioned(
                  left: position.x,
                  top: position.y,
                  child: IgnorePointer(
                    ignoring: !enabled,
                    child: GestureDetector(
                      onPanUpdate: (DragUpdateDetails details) {
                        final DebugActionPosition current =
                            positionCubit.state ?? position;
                        positionCubit.moveTo(
                          _clamp(
                            DebugActionPosition(
                              x: current.x + details.delta.dx,
                              y: current.y + details.delta.dy,
                            ),
                            minX: minX,
                            maxX: maxX,
                            minY: minY,
                            maxY: maxY,
                          ),
                        );
                      },
                      child: Semantics(
                        identifier: 'debug.incomingRequest',
                        excludeSemantics: true,
                        button: true,
                        enabled: enabled,
                        label: l10n.debugIncomingRequestLabel,
                        onTap: enabled ? () => unawaited(onPressed()) : null,
                        child: FloatingActionButton(
                          backgroundColor: enabled
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainerHighest,
                          foregroundColor: enabled
                              ? theme.colorScheme.onPrimary
                              : theme.disabledColor,
                          onPressed: enabled
                              ? () => unawaited(onPressed())
                              : null,
                          child: const Icon(Icons.add_card),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  DebugActionPosition _clamp(
    DebugActionPosition position, {
    required double minX,
    required double maxX,
    required double minY,
    required double maxY,
  }) => DebugActionPosition(
    x: position.x.clamp(minX, maxX),
    y: position.y.clamp(minY, maxY),
  );
}
