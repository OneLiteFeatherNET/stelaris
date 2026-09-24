import 'package:flutter/widgets.dart';

/// Stelaris' own icons, drawn from Minecraft's imagery in Material's style.
///
/// The glyphs live in the `StelarisIcons` font, which
/// `tool/generate_icons.sh` builds from the SVGs in `design/icons/navigation`.
/// The code points below must match `tool/icons.fantasticonrc.json`.
abstract final class StelarisIcons {
  static const String _family = 'StelarisIcons';

  /// Attributes: the health bar's heart.
  static const IconData heartOutlined = IconData(0xe000, fontFamily: _family);
  static const IconData heart = IconData(0xe001, fontFamily: _family);

  /// Items: a pickaxe.
  static const IconData pickaxeOutlined = IconData(0xe002, fontFamily: _family);
  static const IconData pickaxe = IconData(0xe003, fontFamily: _family);

  /// Notifications: an advancement toast with a star.
  static const IconData advancementOutlined = IconData(
    0xe004,
    fontFamily: _family,
  );
  static const IconData advancement = IconData(0xe005, fontFamily: _family);

  /// Fonts: the letters "Aa".
  static const IconData lettersOutlined = IconData(0xe006, fontFamily: _family);
  static const IconData letters = IconData(0xe007, fontFamily: _family);

  /// Sound: a note block.
  static const IconData noteBlockOutlined = IconData(
    0xe008,
    fontFamily: _family,
  );
  static const IconData noteBlock = IconData(0xe009, fontFamily: _family);
}
