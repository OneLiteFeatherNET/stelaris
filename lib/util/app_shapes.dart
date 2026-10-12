import 'package:material_ui/material_ui.dart';

/// The corner radii of the app, the shape scale of Material 3. Widgets take
/// their corners from here or from the theme, never a number of their own.
abstract final class AppShapes {
  /// Text fields, previews, badges.
  static const double extraSmall = 4;

  /// Small blocks inside a card or form, chips.
  static const double small = 8;

  /// Cards.
  static const double medium = 12;

  /// Larger surfaces like a search bar or a panel.
  static const double large = 16;

  /// Dialogs.
  static const double extraLarge = 28;

  /// Fully rounded ends, for pills like a badge.
  static const double full = 1000;

  /// Text fields and dropdowns, one value for all of them. Change it here to
  /// compare, e.g. [extraSmall] against [small].
  static const double field = small;

  static const BorderRadius fieldRadius = BorderRadius.all(
    Radius.circular(field),
  );

  /// The outline of a field, with [side] for its color and width.
  static OutlineInputBorder fieldBorder([
    BorderSide side = const BorderSide(),
  ]) => OutlineInputBorder(borderRadius: fieldRadius, borderSide: side);

  static RoundedRectangleBorder rounded(double radius) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}
