import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/api/state/actions/block_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/util/navigation.dart';

import '../../util/constants.dart';
import 'button/theme_switcher_toggle.dart';

const double maxXOffset = 180;
const double minXOffset = 50;
const navigationEntries = NavigationEntry.values;
const navigationEntryTextStyle = TextStyle(fontSize: 16);

class BasePage extends StatefulWidget {
  final Widget child;

  const BasePage({Key? key, required this.child}) : super(key: key);

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  bool _navOpen = true;

  double _xOffset = maxXOffset;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(onInit: (store) {
      store.dispatch(InitBlockAction());
    }, converter: (store) {
      return store.state;
    }, builder: (context, vm) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _navOpen = !_navOpen;
              _toggleSidebarState();
            },
          ),
          elevation: 0,
          title: appTitle,
          centerTitle: true,
          actions: [
            ThemeSwitcherToggle(),
            spaceTenBox,
            IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("You can find the wiki under LINK HERE"),
                    behavior: SnackBarBehavior.floating,
                    width: 500.0,
                    elevation: 0.0,
                  ));
                },
                icon: const Icon(Icons.help_center)),
          ],
        ),
        body: Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNavigationContainer(),
            Expanded(child: widget.child)
          ],
        ),
      );
    });
  }

  void _toggleSidebarState() {
    setState(() {
      _xOffset = _navOpen ? maxXOffset : minXOffset;
    });
  }

  Widget _buildNavigationContainer() {
    final router = GoRouter.of(context);
    final index = navigationEntries.indexWhere((element) {
      return element.route == router.location;
    });
    return NavigationRail(
      minExtendedWidth: maxXOffset,
      extended: _navOpen,
      onDestinationSelected: (index) {
        router.push(navigationEntries[index].route);
      },
      labelType: NavigationRailLabelType.none,
      destinations: _buildNavigationView(),
      selectedIndex: index != -1 ? index : 0,
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
    /*builder(
      itemCount: navigationEntries.length,
      itemBuilder: (context, index) {
        var display = navigationEntries[index].display;
        var leadingIcon = Icon(navigationEntries[index].data);
        var title = (_xOffset == maxXOffset
            ? Text(
                display,
                style: navigationEntryTextStyle,
              )
            : Text(""));
        var selected = router.location == navigationEntries[index].route;
        return ListTile(
          title: title,
          dense: true,
          leading: leadingIcon,
          selected: selected,
        );
      },
    );*/
  }
}
