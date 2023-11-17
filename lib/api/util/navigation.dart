import 'package:flutter/material.dart';

/// The enum class contains all relevant item for the navigation widget.
enum NavigationEntry {

  attributes("Attributes", "/attributes", Icons.badge_sharp),
  items("Items", "/items", Icons.games),
  notifications("Notifications", "/notifications", Icons.notification_add),
  font("Fonts", "/fonts", Icons.font_download_outlined),
  build("Build", "/build", Icons.build);

  final String display;
  final String route;
  final IconData data;

  /// Creates a new enum entry with the given value
  const NavigationEntry(this.display, this.route, this.data);
}