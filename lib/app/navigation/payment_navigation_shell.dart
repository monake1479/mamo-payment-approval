import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mamo_payment_approval_challenge/app/theme/app_theme.dart';
import 'package:mamo_payment_approval_challenge/l10n/generated/app_localizations.dart';

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
