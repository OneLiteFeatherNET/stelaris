import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/base/button/build_button.dart';
import 'package:stelaris_ui/feature/base/button/settings_button.dart';
import 'package:stelaris_ui/feature/base/button/toggle_navigation_button.dart';
import 'package:stelaris_ui/feature/build/build_drawer.dart';
import 'package:stelaris_ui/feature/navigation/navigation_side_bar.dart';
import 'package:stelaris_ui/util/constants.dart';

class BasePage extends StatelessWidget {
  final Widget child;

  const BasePage({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: const ToggleNavigationBar(),
        elevation: 0,
        title: appTitle,
        centerTitle: true,
        actions: const [BuildButton(), SettingsButton()],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NavigationSideBar(),
          Expanded(child: child),
        ],
      ),
      endDrawer: const BuildDrawer(),
    );
  }
}
