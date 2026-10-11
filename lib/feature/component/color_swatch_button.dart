import 'package:material_ui/material_ui.dart';
import 'package:vulpes_data/color.dart';

/// The named colors in the order Minecraft lists them (§0 to §f).
const List<NamedTextColor> minecraftColorOrder = [
  NamedTextColor.black,
  NamedTextColor.darkBlue,
  NamedTextColor.darkGreen,
  NamedTextColor.darkAqua,
  NamedTextColor.darkRed,
  NamedTextColor.darkPurple,
  NamedTextColor.gold,
  NamedTextColor.gray,
  NamedTextColor.darkGray,
  NamedTextColor.blue,
  NamedTextColor.green,
  NamedTextColor.aqua,
  NamedTextColor.red,
  NamedTextColor.lightPurple,
  NamedTextColor.yellow,
  NamedTextColor.white,
];

/// A round, tappable swatch for one of Minecraft's named text colors.
class ColorSwatchButton extends StatelessWidget {
  const ColorSwatchButton({
    required this.color,
    required this.onTap,
    this.selected = false,
    this.size = 20,
    super.key,
  });

  final NamedTextColor color;
  final VoidCallback onTap;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: color.displayName,
      child: InkResponse(
        onTap: onTap,
        radius: size,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(color.color.argb),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2.5 : 1,
            ),
          ),
        ),
      ),
    );
  }
}
