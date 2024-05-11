import 'package:flutter/material.dart';

/// The enum class contains all relevant item for the navigation widget.
enum NavigationEntry {
  attributes(
    'Attributes',
    '/attributes',
    Icons.badge_outlined,
    Icons.badge,
  ),
  items(
    'Items',
    '/items',
    Icons.games_outlined,
    Icons.games,
  ),
  notifications(
    'Notifications',
    '/notifications',
    Icons.message_outlined,
    Icons.message,
  ),
  font(
    'Fonts',
    '/fonts',
    Icons.font_download_outlined,
    Icons.font_download,
  );

  final String display;
  final String route;
  final IconData data;
  final IconData selected;

  /// Creates a new enum entry with the given value
  const NavigationEntry(
    this.display,
    this.route,
    this.data,
    this.selected,
  );
}
