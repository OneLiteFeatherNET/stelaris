import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/api/util/navigation.dart';
import 'package:stelaris_ui/feature/base/button/theme_switcher_toggle.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';

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
    final router = GoRouter.of(context);
    final index = navigationEntries.indexWhere((element) {
      return element.route == router.location;
    });
    final actionChild = [
      const ThemeSwitcherToggle(),
      IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.text_wiki),
                behavior: SnackBarBehavior.floating,
                width: 500.0,
                elevation: 0.0,
              ),
            );
          },
          icon: const Icon(Icons.help_outline))
    ];
    return NavigationRail(
      minExtendedWidth: maxXOffset,
      extended:
          MediaQuery.of(context).size.width < 1000 ? false : openNavigation,
      onDestinationSelected: (index) {
        router.push(navigationEntries[index].route);
      },
      labelType: NavigationRailLabelType.none,
      destinations: _buildNavigationView(),
      selectedIndex: index != -1 ? index : 0,
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: openNavigation
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actionChild,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actionChild,
                  ),
          ),
        ),
      ),
    );
  }

  List<NavigationRailDestination> _buildNavigationView() {
    return List.generate(navigationEntries.length, (index) {
      var display = navigationEntries[index].display;
      var leadingIcon = Icon(navigationEntries[index].data);
      return NavigationRailDestination(
          icon: leadingIcon,
          label: Text(display, style: navigationEntryTextStyle));
    });
  }
}
