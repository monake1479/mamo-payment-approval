import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_approval/app/theme/app_motion.dart';
import 'package:mamo_approval/app/theme/app_theme.dart';
import 'package:mamo_approval/l10n/generated/app_localizations.dart';

class PaymentNavigationShell extends StatelessWidget {
  const PaymentNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _selectDestination(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // Branch switches (nav controls, swipe, or "View all") do not push a route,
    // so a system Back on a secondary destination would otherwise leave the app.
    // Return to Home first — the standard "back to the start destination"
    // pattern — and only let Back exit once Home is showing.
    return PopScope<Object?>(
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        _selectDestination(0);
      },
      child: _buildShell(context, l10n),
    );
  }

  Widget _buildShell(BuildContext context, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= AppTheme.expandedBreakpoint) {
          return Scaffold(
            body: SafeArea(
              child: Semantics(
                identifier: 'navigation.expanded',
                container: true,
                explicitChildNodes: true,
                child: Row(
                  children: <Widget>[
                    NavigationRail(
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: _selectDestination,
                      labelType: NavigationRailLabelType.all,
                      destinations: <NavigationRailDestination>[
                        NavigationRailDestination(
                          icon: const _DestinationIcon(
                            identifier: 'navigation.destination.home',
                            icon: Icons.home_outlined,
                          ),
                          selectedIcon: const _DestinationIcon(
                            identifier: 'navigation.destination.home',
                            icon: Icons.home,
                          ),
                          label: Text(l10n.homeNavigationLabel),
                        ),
                        NavigationRailDestination(
                          icon: const _DestinationIcon(
                            identifier: 'navigation.destination.payments',
                            icon: Icons.receipt_long_outlined,
                          ),
                          selectedIcon: const _DestinationIcon(
                            identifier: 'navigation.destination.payments',
                            icon: Icons.receipt_long,
                          ),
                          label: Text(l10n.paymentsNavigationLabel),
                        ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: navigationShell),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: Semantics(
            identifier: 'navigation.compact',
            container: true,
            explicitChildNodes: true,
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _selectDestination,
              destinations: <NavigationDestination>[
                NavigationDestination(
                  icon: const _DestinationIcon(
                    identifier: 'navigation.destination.home',
                    icon: Icons.home_outlined,
                  ),
                  selectedIcon: const _DestinationIcon(
                    identifier: 'navigation.destination.home',
                    icon: Icons.home,
                  ),
                  label: l10n.homeNavigationLabel,
                ),
                NavigationDestination(
                  icon: const _DestinationIcon(
                    identifier: 'navigation.destination.payments',
                    icon: Icons.receipt_long_outlined,
                  ),
                  selectedIcon: const _DestinationIcon(
                    identifier: 'navigation.destination.payments',
                    icon: Icons.receipt_long,
                  ),
                  label: l10n.paymentsNavigationLabel,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PaymentBranchNavigatorContainer extends StatefulWidget {
  const PaymentBranchNavigatorContainer({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.children,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> children;

  @override
  State<PaymentBranchNavigatorContainer> createState() =>
      _PaymentBranchNavigatorContainerState();
}

class _PaymentBranchNavigatorContainerState
    extends State<PaymentBranchNavigatorContainer> {
  late List<int> _activationCounts = List<int>.filled(
    widget.children.length,
    0,
  );
  int? _transitionTarget;

  /// Index the pager is leaving. Kept alive until the transition settles so the
  /// outgoing surface stays fully painted while it slides off screen instead of
  /// snapping to its pre-entrance (hidden) state once [currentIndex] commits to
  /// the destination at the half-way point.
  int? _transitionOrigin;

  @override
  void didUpdateWidget(PaymentBranchNavigatorContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_activationCounts.length != widget.children.length) {
      _activationCounts = List<int>.generate(
        widget.children.length,
        (int index) =>
            index < _activationCounts.length ? _activationCounts[index] : 0,
      );
    }
    if (oldWidget.currentIndex != widget.currentIndex) {
      if (_transitionTarget != widget.currentIndex) {
        _activationCounts[widget.currentIndex] += 1;
      }
      _transitionOrigin ??= oldWidget.currentIndex;
      _transitionTarget = widget.currentIndex;
    }
  }

  void _startTransition(int targetIndex) {
    if (_transitionTarget == targetIndex || !mounted) {
      return;
    }
    setState(() {
      _transitionOrigin ??= widget.currentIndex;
      _transitionTarget = targetIndex;
      _activationCounts[targetIndex] += 1;
    });
  }

  void _completeTransition(int settledIndex) {
    if (mounted && (_transitionTarget != null || _transitionOrigin != null)) {
      setState(() {
        _transitionTarget = null;
        _transitionOrigin = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageTransitionSwitcher(
      currentIndex: widget.currentIndex,
      onPageChanged: widget.onDestinationSelected,
      onTransitionStarted: _startTransition,
      onTransitionCompleted: _completeTransition,
      children: <Widget>[
        for (final (int index, Widget child) in widget.children.indexed)
          _motionScope(
            index,
            child,
            startAnimation:
                index == widget.currentIndex ||
                index == _transitionTarget ||
                index == _transitionOrigin,
          ),
      ],
    );
  }

  Widget _motionScope(
    int index,
    Widget child, {
    required bool startAnimation,
  }) => AppIndexedPageMotionScope(
    activation: _activationCounts[index],
    startAnimation: startAnimation,
    child: child,
  );
}

class _DestinationIcon extends StatelessWidget {
  const _DestinationIcon({required this.identifier, required this.icon});

  final String identifier;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Semantics(
    identifier: identifier,
    child: ExcludeSemantics(child: Icon(icon)),
  );
}
