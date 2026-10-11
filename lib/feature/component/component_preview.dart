import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/minimessage_parser.dart';

/// Background of the preview in both app themes. No single color keeps all
/// 16 Minecraft colors readable, so this mid gray is paired with a
/// [_contrastHalo] for the colors that come too close to it.
const Color previewBackground = Color(0xFF5A5A66);

/// Thin border of the preview.
const Color previewBorder = Color(0xFF6E6E7A);

/// Placeholder and hint text on the preview background.
const Color previewPlaceholderColor = Color(0xFFD0D0D8);

/// Text with less contrast to [previewBackground] than this gets a halo.
const double _minContrast = 3;

/// Luminance below which text counts as dark and gets a light halo.
const double _darkTextLuminance = 0.18;

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
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            )
          : Text.rich(
              withContrastHalo(
                MiniMessageParser.parse(
                  text,
                  componentContext: componentContext,
                ),
              ),
              maxLines: singleLine ? 1 : null,
              overflow: singleLine ? TextOverflow.ellipsis : null,
            ),
    );
  }
}

/// Gives every part of [span] whose color lacks contrast to
/// [previewBackground] a halo: dark text a light one, light text a dark one.
TextSpan withContrastHalo(TextSpan span) {
  final color = span.style?.color;
  return TextSpan(
    text: span.text,
    style: color == null
        ? span.style
        : span.style!.copyWith(shadows: _contrastHalo(color)),
    children: span.children
        ?.map((child) => withContrastHalo(child as TextSpan))
        .toList(),
  );
}

List<Shadow> _contrastHalo(Color color) {
  if (_contrast(color, previewBackground) >= _minContrast) return const [];
  final halo = color.computeLuminance() < _darkTextLuminance
      ? const Color(0xF2FFFFFF)
      : const Color(0xF2000000);
  return [
    Shadow(color: halo, blurRadius: 2),
    Shadow(color: halo, blurRadius: 4),
  ];
}

double _contrast(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}
