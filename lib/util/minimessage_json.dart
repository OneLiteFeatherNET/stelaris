import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/minimessage_parser.dart';

/// Converts between MiniMessage and the vanilla JSON text component, the
/// format the backend stores components in.
///
/// [encode] reads MiniMessage through [MiniMessageParser.runs], so the
/// stored text looks exactly like the preview. JSON has no gradients or rainbows,
/// they become one hex color per character. [decode] finds those runs again
/// and writes them as a gradient or rainbow, as long as they are three or
/// more characters, fewer can't be told from plain hex colors.
class MiniMessageJson {
  const MiniMessageJson._();

  /// The short tag of each decoration, in the order they are written.
  static const Map<String, String> _shortTags = {
    'bold': 'b',
    'italic': 'i',
    'underlined': 'u',
    'strikethrough': 'st',
  };

  /// The text component for [input]: a plain string without formatting,
  /// otherwise an object, its parts in `extra`.
  static Object encode(String input) {
    final runs = _merge(_runsOf(input));
    if (runs.isEmpty) return '';
    if (runs.length == 1) {
      final run = runs.single;
      return run.style.isPlain ? run.text : run.toJson();
    }
    return {
      'text': '',
      'extra': [for (final run in runs) run.toJson()],
    };
  }

  /// The MiniMessage for a text component, a string, an object or a list.
  /// Parts it doesn't know, like translations, keep only their text.
  static String decode(Object? component) {
    final runs = _merge(_flatten(component, const _Style()));
    return _write(_segmentsOf(runs));
  }

  static List<_Run> _runsOf(String input) => [
    for (final run in MiniMessageParser.runs(input))
      if (run.kind != MiniMessageRunKind.tag)
        _Run(
          run.text,
          _Style(
            color: run.colorKey,
            bold: run.bold,
            italic: run.italic,
            underlined: run.underlined,
            strikethrough: run.strikethrough,
          ),
        ),
  ];

  static String _hex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  /// Joins neighbours that look the same.
  static List<_Run> _merge(List<_Run> runs) {
    final merged = <_Run>[];
    for (final run in runs) {
      if (run.text.isEmpty) continue;
      final previous = merged.lastOrNull;
      if (previous != null && previous.style == run.style) {
        merged[merged.length - 1] = _Run(previous.text + run.text, run.style);
      } else {
        merged.add(run);
      }
    }
    return merged;
  }

  static List<_Run> _flatten(Object? component, _Style inherited) {
    return switch (component) {
      null => const [],
      final String text => [_Run(text, inherited)],
      // The first one is the parent of the others, they get its style.
      [final first, ...final rest] => [
        ..._flatten(first, inherited),
        for (final child in rest)
          ..._flatten(child, _styleOf(first, inherited)),
      ],
      [] => const [],
      final Map<dynamic, dynamic> map => [
        _Run(
          (map['text'] ?? map['translate'] ?? map['keybind'] ?? '') as String,
          _styleOf(map, inherited),
        ),
        for (final child in (map['extra'] as List?) ?? const [])
          ..._flatten(child, _styleOf(map, inherited)),
      ],
      _ => [_Run('$component', inherited)],
    };
  }

  static _Style _styleOf(Object? component, _Style inherited) {
    if (component is! Map) return inherited;
    final color = component['color'] as String?;
    return _Style(
      color: color == null ? inherited.color : color.toLowerCase(),
      bold: component['bold'] as bool? ?? inherited.bold,
      italic: component['italic'] as bool? ?? inherited.italic,
      underlined: component['underlined'] as bool? ?? inherited.underlined,
      strikethrough:
          component['strikethrough'] as bool? ?? inherited.strikethrough,
    );
  }

  /// Groups the runs into what MiniMessage writes with one color tag: a
  /// plain run, or the characters of a gradient or rainbow.
  static List<_Segment> _segmentsOf(List<_Run> runs) {
    final segments = <_Segment>[];
    var index = 0;
    while (index < runs.length) {
      final found = _colorRunAt(runs, index);
      if (found != null) {
        segments.add(found.segment);
        index += found.length;
      } else {
        final run = runs[index];
        final color = run.style.color;
        segments.add(
          _Segment(
            run.text,
            run.style,
            color == null ? null : '<$color>',
            color == null ? null : '</$color>',
          ),
        );
        index++;
      }
    }
    return segments;
  }

  /// The longest gradient or rainbow from [start], at least three single
  /// characters with hex colors and otherwise the same style.
  static ({_Segment segment, int length})? _colorRunAt(
    List<_Run> runs,
    int start,
  ) {
    var end = start;
    while (end < runs.length &&
        runs[end].text.runes.length == 1 &&
        (runs[end].style.color?.startsWith('#') ?? false) &&
        runs[end].style.withoutColor == runs[start].style.withoutColor) {
      end++;
    }
    for (var stop = end; stop - start >= 3; stop--) {
      final part = runs.sublist(start, stop);
      final colors = [for (final run in part) run.style.color!];
      final text = part.map((run) => run.text).join();
      final style = part.first.style.withoutColor;
      final length = part.length;

      final from = MiniMessageParser.colorOf(colors.first)!;
      final to = MiniMessageParser.colorOf(colors.last)!;
      final isGradient =
          [
            for (var i = 0; i < length; i++)
              _hex(MiniMessageParser.gradientColor([from, to], i, length)),
          ].join() ==
          colors.join();
      if (isGradient) {
        final open = '<gradient:${colors.first}:${colors.last}>';
        return (
          segment: _Segment(text, style, open, '</gradient>'),
          length: length,
        );
      }

      final isRainbow =
          [
            for (var i = 0; i < length; i++)
              _hex(MiniMessageParser.rainbowColor(i, length)),
          ].join() ==
          colors.join();
      if (isRainbow) {
        return (
          segment: _Segment(text, style, '<rainbow>', '</rainbow>'),
          length: length,
        );
      }
    }
    return null;
  }

  /// Writes the segments, opening and closing only the tags that change
  /// from one to the next. The color tag is the outermost, so a new color
  /// keeps the decorations around it as long as possible.
  static String _write(List<_Segment> segments) {
    final buffer = StringBuffer();
    final open = <(String open, String? close)>[];
    for (final segment in segments) {
      final wanted = segment.tags;
      var same = 0;
      // A gradient or rainbow spans only its own characters, the next one
      // starts over even with the same tag.
      while (!segment.spansCharacters &&
          same < open.length &&
          same < wanted.length &&
          open[same].$1 == wanted[same].$1) {
        same++;
      }
      final toClose = open.sublist(same);
      if (toClose.any((tag) => tag.$2 == null)) {
        // A negation like <!i> has no closing tag, only a reset ends it.
        buffer.write('<reset>');
        open.clear();
        same = 0;
      } else {
        for (final tag in toClose.reversed) {
          buffer.write(tag.$2);
        }
        open.removeRange(same, open.length);
      }
      for (final tag in wanted.sublist(same)) {
        buffer.write(tag.$1);
        open.add(tag);
      }
      buffer.write(segment.text);
    }
    return buffer.toString();
  }
}

/// How a piece of text looks, in the terms of a text component. Null means
/// not set, false switched off explicitly.
class _Style {
  const _Style({
    this.color,
    this.bold,
    this.italic,
    this.underlined,
    this.strikethrough,
  });

  /// A color name like `gold`, or `#rrggbb`.
  final String? color;
  final bool? bold;
  final bool? italic;
  final bool? underlined;
  final bool? strikethrough;

  bool get isPlain =>
      color == null &&
      bold == null &&
      italic == null &&
      underlined == null &&
      strikethrough == null;

  _Style get withoutColor => _Style(
    bold: bold,
    italic: italic,
    underlined: underlined,
    strikethrough: strikethrough,
  );

  Map<String, bool?> get decorations => {
    'bold': bold,
    'italic': italic,
    'underlined': underlined,
    'strikethrough': strikethrough,
  };

  @override
  bool operator ==(Object other) =>
      other is _Style &&
      other.color == color &&
      other.bold == bold &&
      other.italic == italic &&
      other.underlined == underlined &&
      other.strikethrough == strikethrough;

  @override
  int get hashCode =>
      Object.hash(color, bold, italic, underlined, strikethrough);
}

class _Run {
  const _Run(this.text, this.style);

  final String text;
  final _Style style;

  Map<String, Object> toJson() => {
    'text': text,
    'color': ?style.color,
    for (final MapEntry(:key, :value) in style.decorations.entries) key: ?value,
  };
}

/// Text with the tags it is written in: a color tag (or gradient, or
/// rainbow), then the decorations.
class _Segment {
  const _Segment(this.text, this.style, this.colorOpen, this.colorClose);

  final String text;

  /// Only the decorations count, the color comes from the color tag.
  final _Style style;
  final String? colorOpen;
  final String? colorClose;

  bool get spansCharacters =>
      colorClose == '</gradient>' || colorClose == '</rainbow>';

  /// The opening tags, outermost first, each with its closing tag, null for
  /// a negation which has none.
  List<(String, String?)> get tags => [
    if (colorOpen != null) (colorOpen!, colorClose),
    for (final MapEntry(:key, :value) in style.decorations.entries)
      if (value != null)
        value
            ? (
                '<${MiniMessageJson._shortTags[key]}>',
                '</${MiniMessageJson._shortTags[key]}>',
              )
            : ('<!${MiniMessageJson._shortTags[key]}>', null),
  ];
}
