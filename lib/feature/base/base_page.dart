import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/actions/app_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/base/button/info_button.dart';
import 'package:stelaris_ui/feature/base/button/theme_switcher_toggle.dart';
import 'package:stelaris_ui/feature/base/navigation_side_bar.dart';
import 'package:stelaris_ui/util/constants.dart';

class BasePage extends StatefulWidget {
  final Widget child;

  const BasePage({super.key, required this.child});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
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
          actions: const [
            ThemeSwitcherToggle(),
            InfoButton()
          ],
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NavigationSideBar(openNavigation: vm.openNavigation),
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

}
