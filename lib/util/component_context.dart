import 'package:material_ui/material_ui.dart';

/// The dark neutral Minecraft draws most texts on, in both app themes, so
/// their colors stay exact.
const Color darkTextBackground = Color(0xFF141418);

/// Thin border around [darkTextBackground].
const Color darkTextBorder = Color(0xFF2C2C34);

/// The paper of a book page.
const Color bookPaper = Color(0xFFF3E9D2);

/// Thin border around [bookPaper].
const Color bookPaperBorder = Color(0xFFD6C6A0);

/// Where a component is shown in game. Minecraft gives each place its own
/// default text color and background, which the preview uses.
enum ComponentContext {
  /// Item lore lines: dark purple.
  lore(Color(0xFFAA00AA)),

  /// A custom item name: white.
  itemName(Color(0xFFFFFFFF)),

  /// The title of an advancement toast: white.
  notificationTitle(Color(0xFFFFFFFF)),

  /// The description of a task or goal advancement: green, the color of
  /// its frame.
  advancementDescription(Color(0xFF55FF55)),

  /// The description of a challenge advancement: dark purple.
  challengeDescription(Color(0xFFAA00AA)),

  /// A page of a written book: black on paper, without a shadow.
  bookPage(
    Color(0xFF000000),
    background: bookPaper,
    border: bookPaperBorder,
    shadow: false,
  );

  const ComponentContext(
    this.defaultColor, {
    this.background = darkTextBackground,
    this.border = darkTextBorder,
    this.shadow = true,
  });

  final Color defaultColor;
  final Color background;
  final Color border;

  /// Whether Minecraft draws the text with its shadow.
  final bool shadow;
}
