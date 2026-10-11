import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:vulpes_data/color.dart' as vdata;

/// A lightweight MiniMessage parser for rendering Minecraft rich text previews in Flutter.
class MiniMessageParser {
  const MiniMessageParser._();

  /// By their MiniMessage name, e.g. `dark_purple`.
  static final Map<String, Color> _namedColors = {
    for (final c in vdata.NamedTextColor.values) c.key: Color(c.color.argb),
  };

  static final RegExp _tagRegex = RegExp(
    r'<(/?[a-zA-Z0-9_#:.-]+|![a-zA-Z0-9_]+)>',
  );

  /// Parses a MiniMessage formatted string into a [TextSpan], starting from
  /// the default color of [componentContext]. Text is italic only where an
  /// italic tag says so.
  static TextSpan parse(
    String input, {
    ComponentContext componentContext = ComponentContext.notificationTitle,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return _parse(
      input,
      componentContext: componentContext,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// Like [parse], but keeps every character of [input], for showing the
  /// source in an input field: the tags it understands in [tagStyle], the
  /// ones Minecraft prints as text in the formatting around them, merged
  /// with [unknownTagStyle].
  static TextSpan highlight(
    String input, {
    required TextStyle tagStyle,
    required TextStyle unknownTagStyle,
    ComponentContext componentContext = ComponentContext.notificationTitle,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return _parse(
      input,
      componentContext: componentContext,
      fontSize: fontSize,
      fontWeight: fontWeight,
      tagStyle: tagStyle,
      unknownTagStyle: unknownTagStyle,
    );
  }

  /// Leaves the tags out without [tagStyle], and prints the unknown ones as
  /// text without [unknownTagStyle].
  static TextSpan _parse(
    String input, {
    required ComponentContext componentContext,
    required double fontSize,
    required FontWeight fontWeight,
    TextStyle? tagStyle,
    TextStyle? unknownTagStyle,
  }) {
    final defaultColor = componentContext.defaultColor;
    final root = TextStyle(
      color: defaultColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
    if (input.isEmpty) return TextSpan(text: '', style: root);

    final spans = <InlineSpan>[];
    for (final run in runs(input)) {
      if (run.kind == MiniMessageRunKind.tag) {
        if (tagStyle != null) {
          spans.add(TextSpan(text: run.text, style: tagStyle));
        }
        continue;
      }
      var style = _createStyle(
        color: run.color ?? defaultColor,
        isBold: run.bold ?? false,
        isItalic: run.italic ?? false,
        isUnderlined: run.underlined ?? false,
        isStrikethrough: run.strikethrough ?? false,
        fontSize: fontSize,
        fontWeight: fontWeight,
      );
      if (run.kind == MiniMessageRunKind.literal && unknownTagStyle != null) {
        style = style.merge(unknownTagStyle);
      }
      spans.add(TextSpan(text: run.text, style: style));
    }
    return TextSpan(style: root, children: spans);
  }

  /// Splits [input] into the parts it shows, each with how it looks.
  ///
  /// Like Adventure, which turns MiniMessage into the text in game, a
  /// gradient or rainbow spans every character up to its closing tag, also
  /// inside other tags, counted in code points. A color inside one keeps its
  /// own color, the characters still count.
  static List<MiniMessageRun> runs(String input) {
    // The first pass only counts the characters of each gradient and
    // rainbow, by the offset of its tag.
    final sizes = <int, int>{};
    _walk(input, sizes, counting: true);
    return _walk(input, sizes, counting: false);
  }

  static List<MiniMessageRun> _walk(
    String input,
    Map<int, int> sizes, {
    required bool counting,
  }) {
    final runs = <MiniMessageRun>[];
    // Open colors, gradients and rainbows, innermost last. The innermost
    // gives the color, closing one returns to the one outside.
    final colors = <_ColorEntry>[];
    final decorations = <String, bool>{};

    MiniMessageRun run(
      String text,
      MiniMessageRunKind kind,
      Color? color,
      String? key,
    ) => MiniMessageRun(
      text: text,
      kind: kind,
      color: color,
      colorKey: key,
      bold: decorations['bold'],
      italic: decorations['italic'],
      underlined: decorations['underlined'],
      strikethrough: decorations['strikethrough'],
    );

    void addText(String text, MiniMessageRunKind kind) {
      if (text.isEmpty) return;
      final changing = colors.whereType<_ChangingColor>().toList();
      if (changing.isEmpty) {
        final fixed = colors.lastOrNull as _FixedColor?;
        runs.add(run(text, kind, fixed?.color, fixed?.key));
        return;
      }
      for (final rune in text.runes) {
        final char = String.fromCharCode(rune);
        if (counting) {
          for (final entry in changing) {
            sizes[entry.id] = (sizes[entry.id] ?? 0) + 1;
          }
          continue;
        }
        final top = colors.last;
        final color = switch (top) {
          _FixedColor(:final color) => color,
          _ChangingColor() => top.colorAt(sizes[top.id] ?? 1),
        };
        final key = top is _FixedColor ? top.key : _hex(color);
        runs.add(run(char, kind, color, key));
        for (final entry in changing) {
          entry.index++;
        }
      }
    }

    void removeLast<T extends _ColorEntry>() {
      final index = colors.lastIndexWhere((entry) => entry is T);
      if (index >= 0) colors.removeAt(index);
    }

    var last = 0;
    for (final match in _tagRegex.allMatches(input)) {
      addText(input.substring(last, match.start), MiniMessageRunKind.text);
      last = match.end;
      final raw = match.group(0)!;
      final tag = match.group(1)!.toLowerCase();
      final closing = tag.startsWith('/');
      final negated = tag.startsWith('!');
      final name = closing || negated ? tag.substring(1) : tag;
      var known = true;

      if (tag == 'reset' || tag == 'r') {
        colors.clear();
        decorations.clear();
      } else if (_decorations[name] case final decoration?) {
        if (closing) {
          decorations.remove(decoration);
        } else {
          decorations[decoration] = !negated;
        }
      } else if (negated) {
        known = false;
      } else if (name.startsWith('gradient:') && !closing) {
        // Minecraft prints a gradient with a missing or unknown color as
        // plain text, so the preview does too.
        final stops = name.split(':').skip(1).map(_parseColor).toList();
        if (stops.length >= 2 && !stops.contains(null)) {
          colors.add(_Gradient(match.start, stops.whereType<Color>().toList()));
        } else {
          known = false;
        }
      } else if (tag == '/gradient') {
        removeLast<_Gradient>();
      } else if (tag == 'rainbow') {
        colors.add(_Rainbow(match.start));
      } else if (tag == '/rainbow') {
        removeLast<_Rainbow>();
      } else if (closing) {
        if (_parseColor(name) != null || name == 'color' || name == 'colour') {
          removeLast<_FixedColor>();
        } else {
          known = false;
        }
      } else if (_parseColor(name) case final color?) {
        colors.add(_FixedColor(color, _colorKey(name)));
      } else {
        known = false;
      }

      if (known) {
        if (!counting) runs.add(run(raw, MiniMessageRunKind.tag, null, null));
      } else {
        addText(raw, MiniMessageRunKind.literal);
      }
    }
    addText(input.substring(last), MiniMessageRunKind.text);
    return runs;
  }

  /// The decorations by every name MiniMessage accepts for them.
  static const Map<String, String> _decorations = {
    'b': 'bold',
    'bold': 'bold',
    'i': 'italic',
    'italic': 'italic',
    'em': 'italic',
    'u': 'underlined',
    'underlined': 'underlined',
    'st': 'strikethrough',
    'strikethrough': 'strikethrough',
  };

  /// How a color tag names its color in JSON: its name, or `#rrggbb`.
  static String _colorKey(String tag) {
    var value = tag;
    if (value.startsWith('color:') || value.startsWith('colour:')) {
      value = value.substring(value.indexOf(':') + 1).trim();
    }
    return value.startsWith('#') ? _hex(_parseColor(value)!) : value;
  }

  static String _hex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  /// The color a color tag sets, e.g. `gold`, `#ff0000` or `color:red`,
  /// null for anything else.
  static Color? colorOf(String tag) => _parseColor(tag);

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

  /// The color of the character at [index] of [length] in a gradient over
  /// [colors].
  ///
  /// Computed like Adventure: the position among the colors, and each
  /// channel blended in single precision and rounded.
  static Color gradientColor(List<Color> colors, int index, int length) {
    final multiplier = length == 1 ? 0.0 : (colors.length - 1) / (length - 1);
    final position = index * multiplier;
    final low = position.floor();
    final from = colors[low % colors.length].toARGB32();
    final to = colors[position.ceil() % colors.length].toARGB32();
    final t = _float(position - low).clamp(0.0, 1.0);
    int channel(int shift) {
      final a = (from >> shift) & 0xFF;
      final b = (to >> shift) & 0xFF;
      final blended = _float(a + _float(t * (b - a)));
      return _float(blended + 0.5).floor();
    }

    return Color.fromARGB(255, channel(16), channel(8), channel(0));
  }

  /// The color of the character at [index] of [length] in a rainbow.
  ///
  /// Computed like Adventure, which turns the MiniMessage into the text in
  /// game: the hue is the share of the index, at full saturation and value,
  /// in single precision, and each channel is cut, not rounded, to 0 to 255.
  static Color rainbowColor(int index, int length) {
    final hue = _float(_float(index.toDouble()) / length);
    final h = _float(hue * 6);
    final sector = h.floor();
    final f = _float(h - sector);
    final q = _float(1 - f);
    final (r, g, b) = switch (sector % 6) {
      0 => (1.0, f, 0.0),
      1 => (q, 1.0, 0.0),
      2 => (0.0, 1.0, f),
      3 => (0.0, q, 1.0),
      4 => (f, 0.0, 1.0),
      _ => (1.0, 0.0, q),
    };
    int channel(double value) => _float(value * 255).truncate();
    return Color.fromARGB(255, channel(r), channel(g), channel(b));
  }

  static final Float32List _single = Float32List(1);

  /// [value] at the precision of a Java float.
  static double _float(double value) {
    _single[0] = value;
    return _single[0];
  }

  /// How thick underlines and strikethroughs are, as a multiple of what the
  /// font says.
  static const double _decorationThickness = 2;

  static TextStyle _createStyle({
    required Color color,
    required bool isBold,
    required bool isItalic,
    required bool isUnderlined,
    required bool isStrikethrough,
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    final decorations = <TextDecoration>[
      if (isUnderlined) TextDecoration.underline,
      if (isStrikethrough) TextDecoration.lineThrough,
    ];

    return TextStyle(
      color: color,
      fontWeight: isBold ? FontWeight.bold : fontWeight,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: decorations.isEmpty
          ? TextDecoration.none
          : TextDecoration.combine(decorations),
      // The thickness of the font is often below a pixel, so the line can
      // vanish depending on where it lands. Minecraft draws it one pixel of
      // its eight pixel font thick, about twice as much.
      decorationThickness: decorations.isEmpty ? null : _decorationThickness,
      decorationColor: decorations.isEmpty ? null : color,
      fontSize: fontSize,
    );
  }
}

/// What a part of the text is in the source.
enum MiniMessageRunKind {
  /// Text, shown as it is.
  text,

  /// A tag Minecraft understands, not shown in game.
  tag,

  /// A tag Minecraft doesn't understand and prints as text.
  literal,
}

/// A part of a MiniMessage string with how it looks. Null decorations are
/// not set, false ones are switched off explicitly, like `<!i>`.
class MiniMessageRun {
  const MiniMessageRun({
    required this.text,
    required this.kind,
    this.color,
    this.colorKey,
    this.bold,
    this.italic,
    this.underlined,
    this.strikethrough,
  });

  final String text;
  final MiniMessageRunKind kind;

  /// Null for the default color of the context.
  final Color? color;

  /// The color as JSON writes it, a name like `gold` or `#rrggbb`.
  final String? colorKey;
  final bool? bold;
  final bool? italic;
  final bool? underlined;
  final bool? strikethrough;
}

sealed class _ColorEntry {}

final class _FixedColor extends _ColorEntry {
  _FixedColor(this.color, this.key);

  final Color color;
  final String key;
}

/// A gradient or rainbow, which gives each character its own color.
sealed class _ChangingColor extends _ColorEntry {
  _ChangingColor(this.id);

  /// The offset of its tag, to find its size from the first pass.
  final int id;
  int index = 0;

  Color colorAt(int size);
}

final class _Gradient extends _ChangingColor {
  _Gradient(super.id, this.stops);

  final List<Color> stops;

  @override
  Color colorAt(int size) =>
      MiniMessageParser.gradientColor(stops, index, size);
}

final class _Rainbow extends _ChangingColor {
  _Rainbow(super.id);

  @override
  Color colorAt(int size) => MiniMessageParser.rainbowColor(index, size);
}
