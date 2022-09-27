import 'package:flutter/material.dart';

enum NavigationEntry {

  dashboard("Dashboard", "/dashboard", Icons.abc_outlined),
  items("Items", "/item", Icons.abc),
  entities("Entities", "/entities", Icons.add_moderator),
  quests("Quests", "/quests",Icons.access_time_filled_outlined),
  build("Build", "/build", Icons.construction);

  final String display;
  final String route;
  final IconData data;

  const NavigationEntry(this.display, this.route, this.data);
}