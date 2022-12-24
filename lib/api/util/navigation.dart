import 'package:flutter/material.dart';

/// The enum class contains all relevant item for the navigation widget.
enum NavigationEntry {

  //dashboard("Dashboard", "/dashboard", Icons.abc_outlined),
  items("Items", "/items", Icons.games),
  blocks("Blocks", "/blocks", Icons.square),
  //entities("Entities", "/entities", Icons.add_moderator),
  //quests("Quests", "/quests",Icons.access_time_filled_outlined),
  notifications("Notifications", "/notifications", Icons.notification_add),
  font("Fonts", "/fonts", Icons.font_download_outlined),
  //plugins("Plugins", "/plugins", Icons.extension),
  build("Build", "/build", Icons.build);

  final String display;
  final String route;
  final IconData data;

  /// Creates a new enum entry with the given value
  const NavigationEntry(this.display, this.route, this.data);
}