import 'package:material_ui/material_ui.dart';
import 'package:vulpes_data/color/named_text_color.dart' as vdata;

/// A lightweight MiniMessage parser for rendering Minecraft rich text previews in Flutter.
class MiniMessageParser {
  const MiniMessageParser._();

  static final Map<String, Color> _namedColors = {
    for (final c in vdata.NamedTextColor.values)
      c.name: Color(c.color.value | 0xFF000000),
  };

  static final RegExp _tagRegex =
      RegExp(r'<(/?[a-zA-Z0-9_#:.-]+|![a-zA-Z0-9_]+)>');

  /// Parses a MiniMessage formatted string into a [TextSpan].
  static TextSpan parse(
    String input, {
    Color defaultColor = Colors.white,
    double fontSize = 14,
    String fontFamily = 'monospace',
  }) {
    if (input.isEmpty) {
      return TextSpan(
        text: '',
        style: TextStyle(
          color: defaultColor,
          fontSize: fontSize,
          fontFamily: fontFamily,
        ),
      );
    }

    final spans = <InlineSpan>[];
    final matches = _tagRegex.allMatches(input).toList();

    Color? currentColor;
    bool isBold = false;
    bool isItalic = false;
    bool isUnderlined = false;
    bool isStrikethrough = false;
    _GradientConfig? activeGradient;
    bool activeRainbow = false;

    int lastIndex = 0;

    void addTextChunk(String text) {
      if (text.isEmpty) return;

      if (activeGradient != null && activeGradient!.colors.length >= 2) {
        final chars = text.split('');
        final colors = activeGradient!.colors;
        for (int i = 0; i < chars.length; i++) {
          final t = chars.length == 1 ? 0.0 : i / (chars.length - 1);
          final color = _interpolateMultiColor(colors, t);
          spans.add(
            TextSpan(
              text: chars[i],
              style: _createStyle(
                color: color,
                isBold: isBold,
                isItalic: isItalic,
                isUnderlined: isUnderlined,
                isStrikethrough: isStrikethrough,
                fontSize: fontSize,
                fontFamily: fontFamily,
              ),
            ),
          );
        }
      } else if (activeRainbow) {
        final chars = text.split('');
        for (int i = 0; i < chars.length; i++) {
          final hue = (i / (chars.length == 1 ? 1 : chars.length)) * 360;
          final color = HSLColor.fromAHSL(1.0, hue, 0.8, 0.6).toColor();
          spans.add(
            TextSpan(
              text: chars[i],
              style: _createStyle(
                color: color,
                isBold: isBold,
                isItalic: isItalic,
                isUnderlined: isUnderlined,
                isStrikethrough: isStrikethrough,
                fontSize: fontSize,
                fontFamily: fontFamily,
              ),
            ),
          );
        }
      } else {
        spans.add(
          TextSpan(
            text: text,
            style: _createStyle(
              color: currentColor ?? defaultColor,
              isBold: isBold,
              isItalic: isItalic,
              isUnderlined: isUnderlined,
              isStrikethrough: isStrikethrough,
              fontSize: fontSize,
              fontFamily: fontFamily,
            ),
          ),
        );
      }
    }

    for (final match in matches) {
      if (match.start > lastIndex) {
        addTextChunk(input.substring(lastIndex, match.start));
      }

      final rawTag = match.group(1)!;
      final tag = rawTag.toLowerCase();

      if (tag == 'reset' || tag == 'r') {
        currentColor = null;
        isBold = false;
        isItalic = false;
        isUnderlined = false;
        isStrikethrough = false;
        activeGradient = null;
        activeRainbow = false;
      } else if (tag == 'b' || tag == 'bold') {
        isBold = true;
      } else if (tag == '/b' || tag == '/bold' || tag == '!b' || tag == '!bold') {
        isBold = false;
      } else if (tag == 'i' || tag == 'italic' || tag == 'em') {
        isItalic = true;
      } else if (tag == '/i' || tag == '/italic' || tag == '/em' || tag == '!i' || tag == '!italic') {
        isItalic = false;
      } else if (tag == 'u' || tag == 'underlined') {
        isUnderlined = true;
      } else if (tag == '/u' || tag == '/underlined' || tag == '!u' || tag == '!underlined') {
        isUnderlined = false;
      } else if (tag == 'st' || tag == 'strikethrough') {
        isStrikethrough = true;
      } else if (tag == '/st' || tag == '/strikethrough' || tag == '!st' || tag == '!strikethrough') {
        isStrikethrough = false;
      } else if (tag.startsWith('gradient')) {
        final parts = tag.split(':');
        if (parts.length >= 3) {
          final colors = parts.skip(1).map(_parseColor).whereType<Color>().toList();
          if (colors.length >= 2) {
            activeGradient = _GradientConfig(colors);
          }
        }
      } else if (tag == '/gradient') {
        activeGradient = null;
      } else if (tag == 'rainbow') {
        activeRainbow = true;
      } else if (tag == '/rainbow') {
        activeRainbow = false;
      } else if (tag.startsWith('/')) {
        final closed = tag.substring(1);
        if (_namedColors.containsKey(closed) || closed.startsWith('#') || closed == 'color' || closed == 'colour') {
          currentColor = null;
        }
      } else {
        final color = _parseColor(tag);
        if (color != null) {
          currentColor = color;
        }
      }

      lastIndex = match.end;
    }

    if (lastIndex < input.length) {
      addTextChunk(input.substring(lastIndex));
    }

    return TextSpan(
      style: TextStyle(
        color: defaultColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
      ),
      children: spans,
    );
  }

  static Color? _parseColor(String raw) {
    var tag = raw.trim();
    if (tag.startsWith('color:') || tag.startsWith('colour:')) {
      tag = tag.substring(tag.indexOf(':') + 1).trim();
    }

    if (tag.startsWith('#')) {
      final hex = tag.substring(1);
      if (hex.length == 6) {
        final val = int.tryParse(hex, radix: 16);
        if (val != null) return Color(val | 0xFF000000);
      } else if (hex.length == 3) {
        final expanded = hex.split('').map((c) => '$c$c').join();
        final val = int.tryParse(expanded, radix: 16);
        if (val != null) return Color(val | 0xFF000000);
      }
    }

    return _namedColors[tag];
  }

  static Color _interpolateMultiColor(List<Color> colors, double t) {
    final clamped = t.clamp(0.0, 1.0);
    if (colors.isEmpty) return Colors.white;
    if (colors.length == 1) return colors.first;

    final segment = 1.0 / (colors.length - 1);
    final index = (clamped / segment).floor().clamp(0, colors.length - 2);
    final localT = (clamped - (index * segment)) / segment;

    return Color.lerp(colors[index], colors[index + 1], localT) ?? colors[index];
  }

  static TextStyle _createStyle({
    required Color color,
    required bool isBold,
    required bool isItalic,
    required bool isUnderlined,
    required bool isStrikethrough,
    required double fontSize,
    required String fontFamily,
  }) {
    final decorations = <TextDecoration>[
      if (isUnderlined) TextDecoration.underline,
      if (isStrikethrough) TextDecoration.lineThrough,
    ];

    return TextStyle(
      color: color,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: decorations.isEmpty
          ? TextDecoration.none
          : TextDecoration.combine(decorations),
      fontSize: fontSize,
      fontFamily: fontFamily,
    );
  }
}

class _GradientConfig {
  const _GradientConfig(this.colors);
  final List<Color> colors;
}
