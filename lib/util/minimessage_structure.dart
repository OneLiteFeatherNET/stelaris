import 'package:flutter/services.dart';
import 'package:stelaris/util/minimessage_parser.dart';

/// A tag that opens or closes formatting, and where it sits in the text.
class MiniMessageTag {
  const MiniMessageTag({
    required this.start,
    required this.end,
    required this.name,
    required this.raw,
    required this.closing,
  });

  final int start;
  final int end;

  /// The same for every spelling, `b` for `<bold>` and `gradient` for
  /// `<gradient:red:blue>`.
  final String name;

  /// As written, e.g. `<gradient:red:blue>`.
  final String raw;
  final bool closing;

  /// The tag that closes this one, `</gradient>` for `<gradient:red:blue>`.
  String get closer =>
      '</${raw.substring(1, raw.length - 1).split(':').first}>';
}

/// The structure behind the edits that have to respect the nesting of the
/// tags: which tags are open where, and how to change the formatting of a
/// range without tags that cross each other.
///
/// Only tags that come in pairs count, colors, decorations, gradients and
/// rainbows. Others, like `<reset>` or unknown ones, are treated as text.
class MiniMessageStructure {
  const MiniMessageStructure._();

  static final RegExp _tagPattern = RegExp(r'<(/?[a-zA-Z0-9_#:.-]+)>');

  /// The names MiniMessage accepts for a decoration, by the short one.
  static const Map<String, String> _decorations = {
    'b': 'b',
    'bold': 'b',
    'i': 'i',
    'italic': 'i',
    'em': 'i',
    'u': 'u',
    'underlined': 'u',
    'st': 'st',
    'strikethrough': 'st',
  };

  /// The short name of a decoration, [tag] itself for anything else.
  static String nameOf(String tag) => _decorations[tag] ?? tag;

  static final RegExp _emptyPair = RegExp(
    r'<([a-zA-Z0-9_#.-]+)(?::[a-zA-Z0-9_#:.-]*)?></\1>',
  );

  /// The pair tags of [text], in order.
  static List<MiniMessageTag> tagsOf(String text) {
    final tags = <MiniMessageTag>[];
    for (final match in _tagPattern.allMatches(text)) {
      final inner = match.group(1)!.toLowerCase();
      final closing = inner.startsWith('/');
      final body = closing ? inner.substring(1) : inner;
      final head = body.split(':').first;
      final String name;
      if (_decorations.containsKey(head)) {
        name = _decorations[head]!;
      } else if (head == 'gradient' || head == 'rainbow') {
        name = head;
      } else if (head == 'color' || head == 'colour') {
        name = 'color';
      } else if (MiniMessageParser.colorOf(body) != null) {
        name = body;
      } else {
        continue;
      }
      tags.add(
        MiniMessageTag(
          start: match.start,
          end: match.end,
          name: name,
          raw: match.group(0)!,
          closing: closing,
        ),
      );
    }
    return tags;
  }

  /// Whether every pair tag in [text] is closed again inside it, in the
  /// order it was opened.
  static bool isBalanced(String text) {
    final open = <String>[];
    for (final tag in tagsOf(text)) {
      if (!tag.closing) {
        open.add(tag.name);
      } else if (open.isEmpty || open.removeLast() != tag.name) {
        return false;
      }
    }
    return open.isEmpty;
  }

  /// The opening tags still open at [offset], outermost first.
  static List<MiniMessageTag> openAt(List<MiniMessageTag> tags, int offset) {
    final open = <MiniMessageTag>[];
    for (final tag in tags) {
      if (tag.end > offset) break;
      _step(open, tag);
    }
    return open;
  }

  static void _step(List<MiniMessageTag> open, MiniMessageTag tag) {
    if (!tag.closing) {
      open.add(tag);
      return;
    }
    final index = open.lastIndexWhere((other) => other.name == tag.name);
    if (index >= 0) open.removeAt(index);
  }

  /// Whether all text in [range] has the formatting of [name], at the caret
  /// whether text typed there would get it.
  static bool isFormatted(String text, TextRange range, String name) {
    final tags = tagsOf(text);
    if (range.isCollapsed) {
      return openAt(tags, range.start).any((tag) => tag.name == name);
    }
    final open = <MiniMessageTag>[];
    var hasText = false;
    var from = 0;
    bool check(int to) {
      final start = from < range.start ? range.start : from;
      final end = to > range.end ? range.end : to;
      if (start >= end) return true;
      hasText = true;
      return open.any((tag) => tag.name == name);
    }

    for (final tag in tags) {
      if (!check(tag.start)) return false;
      _step(open, tag);
      from = tag.end;
    }
    return check(text.length) && hasText;
  }

  /// Turns the formatting of [tag] off for the target range when all of it
  /// has it, on otherwise. Blocks that only partly overlap the range are
  /// split, so no tags cross.
  static TextEditingValue toggle(TextEditingValue value, String tag) {
    final range = _targetRange(value);
    final name = nameOf(tag);
    final on = !isFormatted(value.text, range, name);
    final tags = tagsOf(value.text);

    if (range.isCollapsed) {
      return on
          ? _insertAtCaret(value.text, range.start, '<$tag>', '</$tag>')
          : _splitAtCaret(value.text, tags, range.start, name);
    }

    final edits = <_Edit>[];
    for (final chunk in _chunks(tags, range)) {
      if (chunk.isCollapsed) continue;
      final open = openAt(tags, chunk.start);
      final formatted = open.any((other) => other.name == name);
      if (on && formatted) continue;
      // The pairs inside would only repeat the formatting, or keep it.
      edits.addAll(_pairsInside(tags, chunk, name));
      if (on) {
        edits
          ..add(_Edit.insert(chunk.start, '<$tag>'))
          ..add(_Edit.insert(chunk.end, '</$tag>'));
      } else if (formatted) {
        final (close, reopen) = _split(open, name);
        edits
          ..add(_Edit.insert(chunk.start, close))
          ..add(_Edit.insert(chunk.end, reopen));
      }
    }
    return _removeEmptyPairs(_apply(value.text, edits, range));
  }

  /// Wraps the target range in [open] and [close], each part between tags
  /// of the range that are closed or opened outside of it on its own.
  static TextEditingValue wrap(
    TextEditingValue value,
    String open,
    String close,
  ) {
    final range = _targetRange(value);
    if (range.isCollapsed) {
      return _insertAtCaret(value.text, range.start, open, close);
    }
    final edits = <_Edit>[];
    for (final chunk in _chunks(tagsOf(value.text), range)) {
      if (chunk.isCollapsed) continue;
      edits
        ..add(_Edit.insert(chunk.start, open))
        ..add(_Edit.insert(chunk.end, close));
    }
    return _apply(value.text, edits, range);
  }

  /// The selection, or the caret as an empty range; the end of the text
  /// when the field has no selection at all yet.
  static TextRange _targetRange(TextEditingValue value) {
    final selection = value.selection;
    if (!selection.isValid) return TextRange.collapsed(value.text.length);
    return TextRange(start: selection.start, end: selection.end);
  }

  static TextEditingValue _insertAtCaret(
    String text,
    int offset,
    String open,
    String close,
  ) {
    return TextEditingValue(
      text: text.replaceRange(offset, offset, '$open$close'),
      selection: TextSelection.collapsed(offset: offset + open.length),
    );
  }

  /// Ends the [name] formatting at the caret and starts it again right
  /// after, with the caret in between, so what is typed there doesn't get
  /// it but keeps every other formatting.
  static TextEditingValue _splitAtCaret(
    String text,
    List<MiniMessageTag> tags,
    int offset,
    String name,
  ) {
    final (close, reopen) = _split(openAt(tags, offset), name);
    final value = TextEditingValue(
      text: text.replaceRange(offset, offset, '$close$reopen'),
      selection: TextSelection.collapsed(offset: offset + close.length),
    );
    return _removeEmptyPairs(value);
  }

  /// What ends the [name] formatting of the tags in [open] for a while, and
  /// what starts it again. The tags opened after the outermost [name] tag
  /// are closed with it, so nothing crosses, and all but the [name] ones
  /// are opened again right away.
  static (String close, String reopen) _split(
    List<MiniMessageTag> open,
    String name,
  ) {
    final first = open.indexWhere((tag) => tag.name == name);
    final affected = open.sublist(first);
    final kept = [
      for (final tag in affected)
        if (tag.name != name) tag,
    ];
    String closers(List<MiniMessageTag> tags) =>
        tags.reversed.map((tag) => tag.closer).join();
    String openers(List<MiniMessageTag> tags) =>
        tags.map((tag) => tag.raw).join();
    return (
      closers(affected) + openers(kept),
      closers(kept) + openers(affected),
    );
  }

  /// Splits [range] at the tags in it that are opened or closed outside of
  /// it. Each part has the same tags open at its start and end.
  static List<TextRange> _chunks(List<MiniMessageTag> tags, TextRange range) {
    final open = <MiniMessageTag>[];
    final cuts = <MiniMessageTag>[];
    for (final tag in tags) {
      if (tag.start < range.start || tag.end > range.end) continue;
      if (!tag.closing) {
        open.add(tag);
        continue;
      }
      final index = open.lastIndexWhere((other) => other.name == tag.name);
      if (index >= 0) {
        open.removeAt(index);
      } else {
        cuts.add(tag);
      }
    }
    cuts
      ..addAll(open)
      ..sort((a, b) => a.start.compareTo(b.start));

    final chunks = <TextRange>[];
    var start = range.start;
    for (final cut in cuts) {
      chunks.add(TextRange(start: start, end: cut.start));
      start = cut.end;
    }
    chunks.add(TextRange(start: start, end: range.end));
    return chunks;
  }

  /// Removals of the [name] tags that open and close inside [chunk].
  static List<_Edit> _pairsInside(
    List<MiniMessageTag> tags,
    TextRange chunk,
    String name,
  ) {
    final edits = <_Edit>[];
    final open = <MiniMessageTag>[];
    for (final tag in tags) {
      if (tag.name != name) continue;
      if (tag.start < chunk.start || tag.end > chunk.end) continue;
      if (!tag.closing) {
        open.add(tag);
      } else if (open.isNotEmpty) {
        final opener = open.removeLast();
        edits
          ..add(_Edit.remove(opener.start, opener.end))
          ..add(_Edit.remove(tag.start, tag.end));
      }
    }
    return edits;
  }

  /// Applies [edits] to [text] and selects what [range] held. What is
  /// inserted at its start lands before the selection, at its end after it.
  static TextEditingValue _apply(
    String text,
    List<_Edit> edits,
    TextRange range,
  ) {
    // Inserts before a removal at the same offset, the sort isn't stable.
    edits.sort(
      (a, b) => a.start != b.start
          ? a.start.compareTo(b.start)
          : (a.end - a.start).compareTo(b.end - b.start),
    );
    final buffer = StringBuffer();
    var from = 0;
    var start = range.start;
    var end = range.end;
    var shiftStart = 0;
    var shiftEnd = 0;
    for (final edit in edits) {
      buffer
        ..write(text.substring(from, edit.start))
        ..write(edit.text);
      from = edit.end;
      final delta = edit.text.length - (edit.end - edit.start);
      if (edit.end <= range.start) shiftStart += delta;
      if (edit.start < range.end) shiftEnd += delta;
    }
    buffer.write(text.substring(from));
    start += shiftStart;
    end += shiftEnd;
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection(
        baseOffset: start,
        extentOffset: end < start ? start : end,
      ),
    );
  }

  /// Drops the pairs with nothing between them, which the splits leave
  /// behind, except the one the caret is in, ready to type into.
  static TextEditingValue _removeEmptyPairs(TextEditingValue value) {
    var text = value.text;
    var start = value.selection.start;
    var end = value.selection.end;
    final collapsed = value.selection.isCollapsed;
    var searchFrom = 0;
    while (true) {
      final match = _emptyPair.allMatches(text, searchFrom).firstOrNull;
      if (match == null) break;
      if (collapsed && match.start < start && start < match.end) {
        searchFrom = match.end;
        continue;
      }
      final length = match.end - match.start;
      int shift(int offset) {
        if (offset >= match.end) return offset - length;
        if (offset > match.start) return match.start;
        return offset;
      }

      start = shift(start);
      end = shift(end);
      text = text.replaceRange(match.start, match.end, '');
      // A removed pair can leave another one empty around it.
      searchFrom = 0;
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: start, extentOffset: end),
    );
  }
}

/// Replaces [start] to [end] with [text].
class _Edit {
  const _Edit(this.start, this.end, this.text);

  const _Edit.insert(int offset, String text) : this(offset, offset, text);

  const _Edit.remove(int start, int end) : this(start, end, '');

  final int start;
  final int end;
  final String text;
}
