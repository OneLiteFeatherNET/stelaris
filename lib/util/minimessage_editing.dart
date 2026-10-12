import 'package:flutter/services.dart';
import 'package:stelaris/util/minimessage_parser.dart';
import 'package:stelaris/util/minimessage_structure.dart';
import 'package:vulpes_data/color.dart';

/// Pure text operations behind the component editor toolbar.
///
/// Every operation works on the selected range of a [TextEditingValue] and
/// returns the new value with the edited content selected again, so actions
/// can be chained. Without a selection the tags are inserted as an empty
/// pair at the caret, so what the user types next gets the formatting and
/// existing text stays as it is. Only [stripTags] falls back to the whole
/// text, as a reset.
///
/// A "block" is an opening tag, its content and the matching closing tag,
/// e.g. `<gold>…</gold>` or `<gradient:red:blue>…</gradient>`. When the
/// target range is exactly one block, or exactly the content of one, the
/// operations change that block instead of nesting a new one. Otherwise
/// they split blocks where the range only covers part of them, so tags
/// never cross, see [MiniMessageStructure].
class MiniMessageEditing {
  const MiniMessageEditing._();

  static final RegExp _tagPattern = RegExp(
    r'<(/?[a-zA-Z0-9_#:.-]+|![a-zA-Z0-9_]+)>',
  );

  /// A whole block; group 1 is the tag name, group 2 the content.
  static final RegExp _block = RegExp(
    r'^<([a-z0-9_#]+)(?::[a-z0-9_#:]+)?>(.*)</\1>$',
    dotAll: true,
  );

  /// An opening tag at the end of a string; group 1 is the tag name.
  static final RegExp _openTagAtEnd = RegExp(
    r'<([a-z0-9_#]+)(?::[a-z0-9_#:]+)?>$',
  );

  static final Set<String> _colorNames = {
    for (final color in NamedTextColor.values) color.key,
  };

  /// A hex color as MiniMessage writes it, `#rgb` or `#rrggbb`.
  static final RegExp _hexColor = RegExp(r'^#([0-9a-f]{3}|[0-9a-f]{6})$');

  /// Whether [name] is a color tag, a named or a hex color.
  static bool isColorTag(String name) =>
      _colorNames.contains(name) || _hexColor.hasMatch(name);

  static TextEditingValue wrap(
    TextEditingValue value,
    String open,
    String close,
  ) => MiniMessageStructure.wrap(value, open, close);

  /// The names MiniMessage accepts for a tag, e.g. `<bold>` for `<b>`.
  static const Map<String, Set<String>> _aliases = {
    'b': {'b', 'bold'},
    'i': {'i', 'italic', 'em'},
    'u': {'u', 'underlined'},
    'st': {'st', 'strikethrough'},
  };

  static Set<String> _namesOf(String tag) => _aliases[tag] ?? {tag};

  /// Removes the formatting of [tag] from the target range when all of it
  /// has it, adds it otherwise.
  static TextEditingValue toggle(TextEditingValue value, String tag) {
    final unwrapped = _replaceBlock(value, _namesOf(tag).contains, '', '');
    // A block of the same tag around it would keep the formatting.
    if (unwrapped != null && !isActive(unwrapped, tag)) return unwrapped;
    return MiniMessageStructure.toggle(value, tag);
  }

  /// Whether [toggle] would remove [tag], so the target range has its
  /// formatting.
  static bool isActive(TextEditingValue value, String tag) {
    final names = _namesOf(tag);
    final text = value.text;
    final range = _targetRange(value);
    return _surroundingBlock(text, range, names.contains) != null ||
        _blockContent(range.textInside(text), names.contains) != null ||
        MiniMessageStructure.isFormatted(
          text,
          range,
          MiniMessageStructure.nameOf(tag),
        );
  }

  /// Wraps the target range in [color], replacing a color block instead of
  /// nesting.
  static TextEditingValue applyColor(
    TextEditingValue value,
    NamedTextColor color,
  ) => applyColorTag(value, color.key);

  /// Wraps the target range in the color [tag], a name like `gold` or a hex
  /// color like `#ff00aa`, replacing a color block instead of nesting.
  static TextEditingValue applyColorTag(TextEditingValue value, String tag) {
    final open = '<$tag>';
    final close = '</$tag>';
    return _replaceBlock(value, isColorTag, open, close) ??
        wrap(value, open, close);
  }

  /// Wraps the target range in a gradient, replacing an existing gradient
  /// block instead of nesting.
  static TextEditingValue applyGradient(
    TextEditingValue value,
    NamedTextColor from,
    NamedTextColor to,
  ) => applyGradientStops(value, [from.key, to.key]);

  /// Wraps the target range in a gradient over [stops], two or more color
  /// tags like `gold` or `#ff00aa`, replacing an existing gradient block
  /// instead of nesting.
  static TextEditingValue applyGradientStops(
    TextEditingValue value,
    List<String> stops,
  ) {
    assert(stops.length >= 2, 'a gradient needs two colors at least');
    final open = '<gradient:${stops.join(':')}>';
    const close = '</gradient>';
    return _replaceBlock(value, (name) => name == 'gradient', open, close) ??
        wrap(value, open, close);
  }

  /// The color text at the start of the target range gets, null for the
  /// default of the context. Like the parser, a closing color tag returns
  /// to the color around it, whichever color it names.
  static Color? colorAt(TextEditingValue value) {
    final offset = _targetRange(value).start;
    final colors = <Color>[];
    for (final match in _tagPattern.allMatches(value.text)) {
      if (match.end > offset) break;
      final tag = match.group(1)!.toLowerCase();
      if (tag == 'reset' || tag == 'r') {
        colors.clear();
      } else if (tag.startsWith('/')) {
        final closed = tag.substring(1);
        final closesColor =
            closed == 'color' ||
            closed == 'colour' ||
            MiniMessageParser.colorOf(closed) != null;
        if (closesColor && colors.isNotEmpty) colors.removeLast();
      } else {
        final color = MiniMessageParser.colorOf(tag);
        if (color != null) colors.add(color);
      }
    }
    return colors.isEmpty ? null : colors.last;
  }

  static TextEditingValue applyRainbow(TextEditingValue value) =>
      toggle(value, 'rainbow');

  /// Removes every tag from the target range, including the blocks the
  /// range is exactly the content of (what stays selected after an action).
  static TextEditingValue stripTags(TextEditingValue value) {
    final selection = value.selection;
    var range = selection.isValid && !selection.isCollapsed
        ? TextRange(start: selection.start, end: selection.end)
        : TextRange(start: 0, end: value.text.length);
    for (
      var block = _surroundingBlock(value.text, range, _anyName);
      block != null;
      block = _surroundingBlock(value.text, range, _anyName)
    ) {
      range = block;
    }
    final stripped = range.textInside(value.text).replaceAll(_tagPattern, '');
    return TextEditingValue(
      text: value.text.replaceRange(range.start, range.end, stripped),
      selection: TextSelection(
        baseOffset: range.start,
        extentOffset: range.start + stripped.length,
      ),
    );
  }

  static bool _anyName(String name) => true;

  /// The selection, or the caret as an empty range; the end of the text
  /// when the field has no selection at all yet.
  static TextRange _targetRange(TextEditingValue value) {
    final selection = value.selection;
    if (!selection.isValid) {
      return TextRange.collapsed(value.text.length);
    }
    return TextRange(start: selection.start, end: selection.end);
  }

  static TextEditingValue _wrapRange(
    String text,
    TextRange range,
    String open,
    String close,
  ) {
    final inner = range.textInside(text);
    final contentStart = range.start + open.length;
    return TextEditingValue(
      text: text.replaceRange(range.start, range.end, '$open$inner$close'),
      selection: TextSelection(
        baseOffset: contentStart,
        extentOffset: contentStart + inner.length,
      ),
    );
  }

  /// Replaces the tags of the block the target range is, or is the content
  /// of, with [open] and [close] (both empty to remove them). Returns null
  /// when there is no such block whose name [accepts].
  static TextEditingValue? _replaceBlock(
    TextEditingValue value,
    bool Function(String name) accepts,
    String open,
    String close,
  ) {
    final text = value.text;
    final range = _targetRange(value);
    var block = _surroundingBlock(text, range, accepts);
    var content = range.textInside(text);
    if (block == null) {
      final inner = _blockContent(content, accepts);
      if (inner == null) return null;
      block = range;
      content = inner;
    }
    return _wrapRange(
      text.replaceRange(block.start, block.end, content),
      TextRange(start: block.start, end: block.start + content.length),
      open,
      close,
    );
  }

  /// The whole block when [range] is exactly its content, i.e. directly
  /// preceded by an opening tag and followed by its closing tag.
  static TextRange? _surroundingBlock(
    String text,
    TextRange range,
    bool Function(String name) accepts,
  ) {
    final match = _openTagAtEnd.firstMatch(text.substring(0, range.start));
    if (match == null) return null;
    final name = match.group(1)!;
    final close = '</$name>';
    if (!accepts(name) ||
        !text.startsWith(close, range.end) ||
        !MiniMessageStructure.isBalanced(range.textInside(text))) {
      return null;
    }
    return TextRange(start: match.start, end: range.end + close.length);
  }

  /// The content of [text] when it is exactly one block, otherwise null.
  static String? _blockContent(
    String text,
    bool Function(String name) accepts,
  ) {
    final match = _block.firstMatch(text);
    if (match == null) return null;
    final name = match.group(1)!;
    final content = match.group(2)!;
    if (!accepts(name) || !MiniMessageStructure.isBalanced(content)) {
      return null;
    }
    return content;
  }
}
