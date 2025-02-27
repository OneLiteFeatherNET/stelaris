import 'package:flutter/material.dart';
import 'package:stelaris/feature/base/button/build_button.dart';
import 'package:stelaris/feature/base/button/settings_button.dart';
import 'package:stelaris/feature/base/button/toggle_navigation_button.dart';
import 'package:stelaris/feature/build/build_drawer.dart';
import 'package:stelaris/feature/navigation/navigation_side_bar.dart';
import 'package:stelaris/util/constants.dart';

/// A base page layout that provides a consistent structure across the application.
///
/// This widget implements the main layout structure including:
/// - An app bar with navigation toggle, title, and action buttons
/// - A side navigation bar
/// - A main content area
/// - An end drawer for build-related functionality
class BasePage extends StatelessWidget {
  const BasePage({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: const ToggleNavigationBar(),
        elevation: 0,
        title: appTitle,
        centerTitle: true,
        actions: const [
          BuildButton(),
          SettingsButton(),
        ],
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
