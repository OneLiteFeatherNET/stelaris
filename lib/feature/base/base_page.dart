import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: const ToggleNavigationBar(),
        elevation: 0,
        title: appTitle,
        centerTitle: true,
        actions: const [ThemeSwitcherToggle(), InfoButton()],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationSideBar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
