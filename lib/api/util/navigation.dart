import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/stelaris_icons.dart';

/// The enum class contains all relevant item for the navigation widget.
enum NavigationEntry {
  attributes(
    'Attributes',
    '/attributes',
    StelarisIcons.heartOutlined,
    StelarisIcons.heart,
  ),
  items(
    'Items',
    '/items',
    StelarisIcons.pickaxeOutlined,
    StelarisIcons.pickaxe,
  ),
  notifications(
    'Notifications',
    '/notifications',
    StelarisIcons.advancementOutlined,
    StelarisIcons.advancement,
  ),
  font(
    'Fonts',
    '/fonts',
    StelarisIcons.lettersOutlined,
    StelarisIcons.letters,
  ),
  sound(
    'Sound',
    '/sound',
    StelarisIcons.noteBlockOutlined,
    StelarisIcons.noteBlock,
  )
  ;

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

/// The section [location] belongs to — its own route or one nested below
/// it (e.g. `/items/detail`) — or null outside the sections.
NavigationEntry? entryForLocation(String location) {
  for (final entry in NavigationEntry.values) {
    if (location == entry.route || location.startsWith('${entry.route}/')) {
      return entry;
    }
  }
  return null;
}
