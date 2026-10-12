import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/util/minimessage_editing.dart';
import 'package:stelaris/util/minimessage_parser.dart';
import 'package:stelaris/util/minimessage_structure.dart';
import 'package:vulpes_data/color.dart';

/// Why the tags of [text] don't nest, null when they do.
String? crossing(String text) {
  final open = <MiniMessageTag>[];
  for (final tag in MiniMessageStructure.tagsOf(text)) {
    if (!tag.closing) {
      open.add(tag);
    } else if (open.isEmpty || open.removeLast().name != tag.name) {
      return '${tag.raw} at ${tag.start} closes the wrong tag';
    }
  }
  return open.isEmpty ? null : 'tags left open';
}

String plain(String text) => MiniMessageParser.parse(text).toPlainText();

/// A text of letters and tags that nest, from [random].
String randomText(Random random) {
  const tags = ['b', 'bold', 'i', 'u', 'gold', 'gradient:red:blue'];
  final buffer = StringBuffer();
  final open = <String>[];
  for (var i = 0; i < 12; i++) {
    switch (random.nextInt(4)) {
      case 0:
        final tag = tags[random.nextInt(tags.length)];
        buffer.write('<$tag>');
        open.add(tag.split(':').first);
      case 1 when open.isNotEmpty:
        buffer.write('</${open.removeLast()}>');
      default:
        buffer.write('abc'[random.nextInt(3)]);
    }
  }
  for (final tag in open.reversed) {
    buffer.write('</$tag>');
  }
  return buffer.toString();
}

/// A selection in [text] that starts and ends outside of tags.
TextSelection randomSelection(Random random, String text) {
  final offsets = [
    0,
    for (final match in RegExp('<[^>]+>|.').allMatches(text)) match.end,
  ];
  final a = offsets[random.nextInt(offsets.length)];
  final b = offsets[random.nextInt(offsets.length)];
  return TextSelection(baseOffset: min(a, b), extentOffset: max(a, b));
}

void main() {
  test('isBalanced', () {
    expect(MiniMessageStructure.isBalanced('<b>a</b><i>b</i>'), isTrue);
    expect(MiniMessageStructure.isBalanced('a<b>b'), isFalse);
    expect(MiniMessageStructure.isBalanced('a</b><b>b'), isFalse);
    expect(MiniMessageStructure.isBalanced('<b><i>a</b></i>'), isFalse);
    // Not pair tags, so they don't count.
    expect(MiniMessageStructure.isBalanced('<reset>a<golld>'), isTrue);
  });

  test('a block is only replaced when its content nests', () {
    final result = MiniMessageEditing.applyColorTag(
      const TextEditingValue(
        text: 'ab<gold>bc<gold></gold></gold>',
        selection: TextSelection(baseOffset: 8, extentOffset: 16),
      ),
      NamedTextColor.red.key,
    );
    expect(crossing(result.text), isNull);
  });

  test('toggle off reaches the formatting of an outer block too', () {
    final value = const TextEditingValue(
      text: '<b><u><b>ab</b></u></b>',
      selection: TextSelection(baseOffset: 9, extentOffset: 11),
    );
    final result = MiniMessageEditing.toggle(value, 'b');
    expect(MiniMessageEditing.isActive(result, 'b'), isFalse);
    expect(plain(result.text), 'ab');
  });

  test('random edits keep the tags nested and the text the same', () {
    final random = Random(1);
    for (var i = 0; i < 2000; i++) {
      final text = randomText(random);
      final value = TextEditingValue(
        text: text,
        selection: randomSelection(random, text),
      );
      final where = '"$text" at ${value.selection}';

      final colored = MiniMessageEditing.applyColorTag(
        value,
        NamedTextColor.red.key,
      );
      expect(crossing(colored.text), isNull, reason: 'color on $where');
      expect(plain(colored.text), plain(text), reason: 'color on $where');

      for (final tag in ['b', 'i']) {
        final once = MiniMessageEditing.toggle(value, tag);
        final reason = '$tag on $where -> "${once.text}"';
        expect(crossing(once.text), isNull, reason: reason);
        expect(plain(once.text), plain(text), reason: reason);

        final hasText =
            value.selection.isCollapsed ||
            plain(value.selection.textInside(text)).isNotEmpty;
        if (hasText) {
          expect(
            MiniMessageEditing.isActive(once, tag),
            !MiniMessageEditing.isActive(value, tag),
            reason: reason,
          );
        }

        final twice = MiniMessageEditing.toggle(once, tag);
        expect(crossing(twice.text), isNull, reason: '$reason twice');
      }
    }
  });
}
