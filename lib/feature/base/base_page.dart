import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/base/button/info_button.dart';
import 'package:stelaris_ui/feature/base/button/toggle_navigation_button.dart';
import 'package:stelaris_ui/feature/base/button/theme_switcher_toggle.dart';
import 'package:stelaris_ui/feature/base/navigation_side_bar.dart';
import 'package:stelaris_ui/util/constants.dart';

class BasePage extends StatelessWidget {
  final Widget child;

  const BasePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(converter: (store) {
      return store.state;
    }, builder: (context, vm) {
      return Scaffold(
        appBar: AppBar(
          leading: ToggleNavigationBar(navigationState: vm.openNavigation),
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
            Expanded(child: child),
          ],
        ),
      );
    });
  }
}
