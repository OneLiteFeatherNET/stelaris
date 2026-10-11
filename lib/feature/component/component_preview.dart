import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/minimessage_parser.dart';

/// Background of the preview in both app themes: a dark neutral, the kind
/// of background Minecraft draws its texts on, so their colors stay exact.
const Color previewBackground = Color(0xFF141418);

/// Thin border of the preview.
const Color previewBorder = Color(0xFF2C2C34);

/// Weight of the preview text. Minecraft's pixel font has thick strokes,
/// thin ones blend into the dark background and make every color look
/// darker than it is.
const FontWeight previewFontWeight = FontWeight.w500;

/// Placeholder and hint text on the preview background.
const Color previewPlaceholderColor = Color(0xFF9A9AA6);

/// Text with less contrast to [previewBackground] than this gets a light
/// outline instead of its shadow. Only black and dark blue are that dark.
const double _minContrast = 1.5;

/// Renders a MiniMessage string the way Minecraft shows it in
/// [componentContext].
class ComponentPreview extends StatelessWidget {
  const ComponentPreview({
    required this.text,
    required this.componentContext,
    this.singleLine = false,
    this.placeholder = emptyString,
    super.key,
  });

  final String text;
  final ComponentContext componentContext;

  /// Cuts the preview to one line with an ellipsis, for cards and rows.
  final bool singleLine;

  /// Shown in gray when [text] is empty.
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: previewBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: previewBorder),
      ),
      child: text.isEmpty
          ? Text(
              placeholder,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: previewPlaceholderColor,
                fontSize: 14,
              ),
            )
          : Text.rich(
              withTextShadow(
                MiniMessageParser.parse(
                  text,
                  componentContext: componentContext,
                  fontWeight: previewFontWeight,
                ),
              ),
              maxLines: singleLine ? 1 : null,
              overflow: singleLine ? TextOverflow.ellipsis : null,
            ),
    );
  }
}

/// Gives every part of [span] the shadow Minecraft draws under its texts:
/// the text color at a quarter of its brightness, a little down and right.
/// Colors too dark for [previewBackground] get a thin light outline instead,
/// a shadow even darker than them wouldn't show.
TextSpan withTextShadow(TextSpan span) {
  final color = span.style?.color;
  return TextSpan(
    text: span.text,
    style: color == null
        ? span.style
        : span.style!.copyWith(shadows: _shadowFor(color)),
    children: span.children
        ?.map((child) => withTextShadow(child as TextSpan))
        .toList(),
  );
}

List<Shadow> _shadowFor(Color color) {
  if (_contrast(color, previewBackground) < _minContrast) {
    return const [Shadow(color: Color(0x99FFFFFF), blurRadius: 1.5)];
  }
  return [
    Shadow(
      color: Color.from(
        alpha: color.a,
        red: color.r / 4,
        green: color.g / 4,
        blue: color.b / 4,
      ),
      offset: const Offset(1, 1),
    ),
  ];
}

double _contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}
