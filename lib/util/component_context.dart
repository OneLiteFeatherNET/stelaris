import 'package:material_ui/material_ui.dart';

/// Where a component is shown in game. Minecraft gives each place its own
/// default text color, which the preview uses.
enum ComponentContext {
  /// Item lore lines: dark purple.
  lore(Color(0xFFAA00AA)),

  /// A custom item name: white.
  itemName(Color(0xFFFFFFFF)),

  /// The title of an advancement toast: white.
  notificationTitle(Color(0xFFFFFFFF));

  const ComponentContext(this.defaultColor);

  final Color defaultColor;
}
