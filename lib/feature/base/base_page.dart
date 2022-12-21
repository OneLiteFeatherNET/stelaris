import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/api/state/actions/app_actions.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(converter: (store) {
      return store.state;
    }, builder: (context, vm) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _toggleSidebarState(vm.openNavigation);
            },
          ),
          elevation: 0,
          title: appTitle,
          centerTitle: true,
        ),
        body: Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNavigationContainer(vm.openNavigation),
            Expanded(flex: 1, child: widget.child),
          ],
        ),
      );
    });
  }

  void _toggleSidebarState(bool openNavigation) {
    setState(() {
      StoreProvider.dispatch(context, UpdateNavigationAction(!openNavigation));
    });
  }

  Widget _buildNavigationContainer(bool openNavigation) {
    final router = GoRouter.of(context);
    final index = navigationEntries.indexWhere((element) {
      return element.route == router.location;
    });
    final actionChild = [
      const ThemeSwitcherToggle(),
      IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("You can find the wiki under LINK HERE"),
              behavior: SnackBarBehavior.floating,
              width: 500.0,
              elevation: 0.0,
            ));
          },
          icon: const Icon(Icons.help_outline))
    ];
    return NavigationRail(
      minExtendedWidth: maxXOffset,
      extended: openNavigation,
      onDestinationSelected: (index) {
        router.push(navigationEntries[index].route);
      },
      labelType: NavigationRailLabelType.none,
      destinations: _buildNavigationView(),
      selectedIndex: index != -1 ? index : 0,
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
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
