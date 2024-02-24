import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/api/util/navigation.dart';

const double maxXOffset = 180;
const navigationEntries = NavigationEntry.values;
const navigationEntryTextStyle = TextStyle(fontSize: 16);

class NavigationSideBar extends StatelessWidget {
  const NavigationSideBar({
    required this.openNavigation,
    super.key,
  });

  final bool openNavigation;

  @override
  Widget build(BuildContext context) {
    final router = GoRouterState.of(context);
    final index = navigationEntries.indexWhere((element) {
      return element.route == router.uri.toString();
    });
    return NavigationRail(
      minExtendedWidth: maxXOffset,
      extended:
          MediaQuery.of(context).size.width < 1000 ? false : openNavigation,
      onDestinationSelected: (index) {
        context.go(navigationEntries[index].route);
      },
      labelType: NavigationRailLabelType.none,
      destinations: _buildNavigationView(),
      selectedIndex: index != -1 ? index : 0,
    );
  }

  List<NavigationRailDestination> _buildNavigationView() {
    return List.generate(
      navigationEntries.length,
      (index) {
        var display = navigationEntries[index].display;
        var leadingIcon = Icon(navigationEntries[index].data);
        return NavigationRailDestination(
          icon: leadingIcon,
          label: Text(display, style: navigationEntryTextStyle),
        );
      },
    );
  }
}
