import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/navigation_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';

const double maxXOffset = 180;
const List<NavigationEntry> navigationEntries = NavigationEntry.values;
const TextStyle navigationEntryTextStyle = TextStyle(fontSize: 16);

/// A widget that represents a navigation sidebar for the application.
///
/// The [NavigationSideBar] allows users to navigate between different
/// sections of the application using a [NavigationRail].
class NavigationSideBar extends StatelessWidget {
  const NavigationSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    final routerUri = GoRouterState.of(context).uri.toString();
    final selectedIndex = navigationEntries.indexWhere((element) {
      return element.route == routerUri;
    });

    return StoreConnector<AppState, NavigationViewModel>(
      vm: () => NavigationStateFactory(),
      builder: (context, vm) {
        return NavigationRail(
          minExtendedWidth: maxXOffset,
          extended: MediaQuery.of(context).size.width >= 1000 ? vm.openNavigation : false,
          onDestinationSelected: (index) => _onDestinationSelected(context, index),
          labelType: NavigationRailLabelType.none,
          destinations: _buildNavigationView(),
          selectedIndex: selectedIndex != -1 ? selectedIndex : 0,
        );
      },
    );
  }

  /// Handles the selection of a navigation destination.
  void _onDestinationSelected(BuildContext context, int index) {
    context.go(navigationEntries[index].route);
  }

  /// Builds the list of navigation destinations for the [NavigationRail].
  List<NavigationRailDestination> _buildNavigationView() {
    return List.generate(
      navigationEntries.length,
          (index) {
        final navigationValue = navigationEntries[index];
        return NavigationRailDestination(
          selectedIcon: Icon(navigationValue.selected),
          icon: Icon(navigationValue.data),
          label: Text(navigationValue.display, style: navigationEntryTextStyle),
        );
      },
    );
  }
}