import 'package:flutter/material.dart';

enum NavigationEntry {

  dashboard("Dashboard", Icons.abc_outlined),
  items("Items", Icons.abc),
  entities("Entities", Icons.add_moderator),
  quests("Quests", Icons.access_time_filled_outlined),
  build("Build", Icons.construction);

  final String display;
  final IconData data;

  const NavigationEntry(this.display, this.data);
}