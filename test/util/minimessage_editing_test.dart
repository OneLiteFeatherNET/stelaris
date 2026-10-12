import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/util/minimessage_editing.dart';
import 'package:vulpes_data/color.dart';

TextEditingValue selected(String text, int start, int end) => TextEditingValue(
  text: text,
  selection: TextSelection(baseOffset: start, extentOffset: end),
);

TextEditingValue all(String text) => selected(text, 0, text.length);

TextEditingValue caretAt(String text, int offset) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: offset),
);

TextEditingValue caretAtEnd(String text) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: text.length),
);

void expectSelection(TextEditingValue value, int start, int end) {
  expect(value.selection.start, start);
  expect(value.selection.end, end);
}

void main() {
  group('wrap', () {
    test('wraps the selection and selects the wrapped content', () {
      final result = MiniMessageEditing.wrap(
        selected('Epic Sword', 5, 10),
        '<b>',
        '</b>',
      );
      expect(result.text, 'Epic <b>Sword</b>');
      expectSelection(result, 8, 13);
    });

    test('inserts an empty pair at the caret without a selection', () {
      final result = MiniMessageEditing.wrap(
        caretAt('Epic Sword', 4),
        '<b>',
        '</b>',
      );
      expect(result.text, 'Epic<b></b> Sword');
      expect(result.selection.isCollapsed, isTrue);
      expect(result.selection.baseOffset, 7);
    });

    test('puts the caret between the tags for empty text', () {
      final result = MiniMessageEditing.wrap(caretAtEnd(''), '<b>', '</b>');
      expect(result.text, '<b></b>');
      expect(result.selection.isCollapsed, isTrue);
      expect(result.selection.baseOffset, 3);
    });

    test('supports chaining because the content stays selected', () {
      final colored = MiniMessageEditing.applyColorTag(
        all('Sword'),
        NamedTextColor.gold.key,
      );
      final bold = MiniMessageEditing.wrap(colored, '<b>', '</b>');
      expect(bold.text, '<gold><b>Sword</b></gold>');
    });
  });

  group('applyColor', () {
    test('wraps plain text in the color tag', () {
      final result = MiniMessageEditing.applyColorTag(
        all('Epic'),
        NamedTextColor.gold.key,
      );
      expect(result.text, '<gold>Epic</gold>');
      expectSelection(result, 6, 10);
    });

    test('uses the Minecraft name of the color', () {
      final result = MiniMessageEditing.applyColorTag(
        all('x'),
        NamedTextColor.darkAqua.key,
      );
      expect(result.text, '<dark_aqua>x</dark_aqua>');
    });

    test('replaces a color that wraps the whole text', () {
      final result = MiniMessageEditing.applyColorTag(
        all('<gold>Epic</gold>'),
        NamedTextColor.red.key,
      );
      expect(result.text, '<red>Epic</red>');
      expectSelection(result, 5, 9);
    });

    test('replaces a color block that is exactly selected', () {
      final result = MiniMessageEditing.applyColorTag(
        selected('a <gold>b</gold> c', 2, 16),
        NamedTextColor.red.key,
      );
      expect(result.text, 'a <red>b</red> c');
      expectSelection(result, 7, 8);
    });

    test('replaces the color of an empty color block', () {
      final result = MiniMessageEditing.applyColorTag(
        caretAt('<gold></gold>', 6),
        NamedTextColor.red.key,
      );
      expect(result.text, '<red></red>');
      expect(result.selection.isCollapsed, isTrue);
      expect(result.selection.baseOffset, 5);
    });

    test('nests when the text holds two separate color blocks', () {
      final result = MiniMessageEditing.applyColorTag(
        all('<gold>a</gold> b <gold>c</gold>'),
        NamedTextColor.red.key,
      );
      expect(result.text, '<red><gold>a</gold> b <gold>c</gold></red>');
    });

    test('replaces the color around exactly selected content', () {
      final result = MiniMessageEditing.applyColorTag(
        selected('<gold>Test</gold>', 6, 10),
        NamedTextColor.red.key,
      );
      expect(result.text, '<red>Test</red>');
      expectSelection(result, 5, 9);
    });

    test('repeated color clicks replace instead of nesting', () {
      var value = MiniMessageEditing.applyColorTag(
        all('Test'),
        NamedTextColor.green.key,
      );
      for (var i = 0; i < 3; i++) {
        value = MiniMessageEditing.applyColorTag(
          value,
          NamedTextColor.aqua.key,
        );
      }
      expect(value.text, '<aqua>Test</aqua>');
      expectSelection(value, 6, 10);
    });

    test('replaces only the inner color of nested blocks', () {
      final result = MiniMessageEditing.applyColorTag(
        selected('<gold>a <red>b</red></gold>', 13, 14),
        NamedTextColor.aqua.key,
      );
      expect(result.text, '<gold>a <aqua>b</aqua></gold>');
    });

    test('nests when the surrounding color is not closed right after', () {
      final result = MiniMessageEditing.applyColorTag(
        selected('<gold>Test</gold>', 6, 8),
        NamedTextColor.red.key,
      );
      expect(result.text, '<gold><red>Te</red>st</gold>');
    });

    test('does not treat surrounding style tags as a color', () {
      final result = MiniMessageEditing.applyColorTag(
        selected('<b>Test</b>', 3, 7),
        NamedTextColor.red.key,
      );
      expect(result.text, '<b><red>Test</red></b>');
    });

    test('does not treat style tags as colors', () {
      final result = MiniMessageEditing.applyColorTag(
        all('<b>x</b>'),
        NamedTextColor.red.key,
      );
      expect(result.text, '<red><b>x</b></red>');
    });
  });

  group('toggle', () {
    test('wraps text that has no such tag', () {
      final result = MiniMessageEditing.toggle(all('Test'), 'b');
      expect(result.text, '<b>Test</b>');
      expectSelection(result, 3, 7);
    });

    test('a second toggle removes the tag again', () {
      final once = MiniMessageEditing.toggle(all('Test'), 'b');
      final twice = MiniMessageEditing.toggle(once, 'b');
      expect(twice.text, 'Test');
      expectSelection(twice, 0, 4);
    });

    test('removes the tag when the whole text is that block', () {
      final result = MiniMessageEditing.toggle(all('<b>Test</b>'), 'b');
      expect(result.text, 'Test');
    });

    test('removes the tag when its whole block is selected', () {
      final result = MiniMessageEditing.toggle(
        selected('a <u>b</u> c', 2, 10),
        'u',
      );
      expect(result.text, 'a b c');
      expectSelection(result, 2, 3);
    });

    test('removes an inner tag without touching the outer one', () {
      final result = MiniMessageEditing.toggle(
        selected('<i><b>Test</b></i>', 6, 10),
        'b',
      );
      expect(result.text, '<i>Test</i>');
      expectSelection(result, 3, 7);
    });

    test('adds a different tag inside an existing one', () {
      final result = MiniMessageEditing.toggle(
        selected('<b>Test</b>', 3, 7),
        'i',
      );
      expect(result.text, '<b><i>Test</i></b>');
    });

    test('formats a partly formatted selection once, not twice', () {
      final result = MiniMessageEditing.toggle(
        selected('<b>Te</b>st', 0, 11),
        'b',
      );
      expect(result.text, '<b>Test</b>');
    });
  });

  group('without a selection', () {
    test('a color starts new text and leaves the old one alone', () {
      final result = MiniMessageEditing.applyColorTag(
        caretAtEnd('<green>Test</green> Neu'),
        NamedTextColor.red.key,
      );
      expect(result.text, '<green>Test</green> Neu<red></red>');
      expect(result.selection.isCollapsed, isTrue);
      expect(result.selection.baseOffset, 28);
    });

    test('a color right after an existing block does not replace it', () {
      final result = MiniMessageEditing.applyColorTag(
        caretAtEnd('<green>Test</green>'),
        NamedTextColor.red.key,
      );
      expect(result.text, '<green>Test</green><red></red>');
    });

    test('a second color at the same caret replaces the empty pair', () {
      final red = MiniMessageEditing.applyColorTag(
        caretAtEnd('Hi '),
        NamedTextColor.red.key,
      );
      final gold = MiniMessageEditing.applyColorTag(
        red,
        NamedTextColor.gold.key,
      );
      expect(gold.text, 'Hi <gold></gold>');
      expect(gold.selection.baseOffset, 9);
    });

    test('a second toggle at the same caret removes the empty pair', () {
      final once = MiniMessageEditing.toggle(caretAt('ab', 1), 'b');
      expect(once.text, 'a<b></b>b');
      final twice = MiniMessageEditing.toggle(once, 'b');
      expect(twice.text, 'ab');
      expect(twice.selection.baseOffset, 1);
    });

    test('a gradient is inserted at the caret', () {
      final result = MiniMessageEditing.applyGradientStops(caretAtEnd('Hi '), [
        NamedTextColor.gold.key,
        NamedTextColor.red.key,
      ]);
      expect(result.text, 'Hi <gradient:gold:red></gradient>');
    });

    test('an unfocused field inserts at the end', () {
      final result = MiniMessageEditing.toggle(
        const TextEditingValue(text: 'Hi'),
        'b',
      );
      expect(result.text, 'Hi<b></b>');
    });
  });

  group('gradient and rainbow', () {
    test('applyGradient wraps with both colors', () {
      final result = MiniMessageEditing.applyGradientStops(all('Hi'), [
        NamedTextColor.gold.key,
        NamedTextColor.darkRed.key,
      ]);
      expect(result.text, '<gradient:gold:dark_red>Hi</gradient>');
    });

    test('a new gradient replaces the one around the selection', () {
      final result = MiniMessageEditing.applyGradientStops(
        selected('<gradient:gold:red>Hi</gradient>', 19, 21),
        [NamedTextColor.aqua.key, NamedTextColor.blue.key],
      );
      expect(result.text, '<gradient:aqua:blue>Hi</gradient>');
      expectSelection(result, 20, 22);
    });

    test('a new gradient replaces one that wraps the whole text', () {
      final result = MiniMessageEditing.applyGradientStops(
        all('<gradient:gold:red>Hi</gradient>'),
        [NamedTextColor.aqua.key, NamedTextColor.blue.key],
      );
      expect(result.text, '<gradient:aqua:blue>Hi</gradient>');
    });

    test('applyRainbow twice removes the rainbow again', () {
      final once = MiniMessageEditing.toggle(all('Hi'), 'rainbow');
      expect(MiniMessageEditing.toggle(once, 'rainbow').text, 'Hi');
    });

    test('applyRainbow wraps the selection', () {
      final result = MiniMessageEditing.toggle(
        selected('a b', 2, 3),
        'rainbow',
      );
      expect(result.text, 'a <rainbow>b</rainbow>');
    });
  });

  group('stripTags', () {
    test('removes all tags without a selection', () {
      final result = MiniMessageEditing.stripTags(
        caretAtEnd('<gold><b>Epic</b></gold>'),
      );
      expect(result.text, 'Epic');
      expectSelection(result, 0, 4);
    });

    test('removes tags only inside the selection', () {
      final result = MiniMessageEditing.stripTags(
        selected('<red>a</red> <b>b</b>', 13, 21),
      );
      expect(result.text, '<red>a</red> b');
      expectSelection(result, 13, 14);
    });

    test('removes the blocks around exactly selected content', () {
      final result = MiniMessageEditing.stripTags(
        selected('<gold><b>Epic</b></gold>', 9, 13),
      );
      expect(result.text, 'Epic');
      expectSelection(result, 0, 4);
    });

    test('clears right after an action, while its content is selected', () {
      final colored = MiniMessageEditing.applyColorTag(
        all('Test'),
        NamedTextColor.gold.key,
      );
      final bold = MiniMessageEditing.toggle(colored, 'b');
      expect(MiniMessageEditing.stripTags(bold).text, 'Test');
    });

    test('keeps blocks that only surround part of the text', () {
      final result = MiniMessageEditing.stripTags(
        selected('<gold>a <red>b</red></gold>', 13, 14),
      );
      expect(result.text, '<gold>a b</gold>');
    });

    test('leaves empty text empty', () {
      final result = MiniMessageEditing.stripTags(caretAtEnd(''));
      expect(result.text, '');
    });
  });

  group('inside a block', () {
    test('toggle ends the formatting at the caret', () {
      final result = MiniMessageEditing.toggle(caretAt('a<b>bcd</b>e', 5), 'b');
      expect(result.text, 'a<b>b</b><b>cd</b>e');
      expect(result.selection.isCollapsed, isTrue);
      expect(result.selection.baseOffset, 9);
      expect(MiniMessageEditing.isActive(result, 'b'), isFalse);
    });

    test('toggle splits the block around the selected part', () {
      final result = MiniMessageEditing.toggle(
        selected('<b>Sharp</b>', 4, 6),
        'b',
      );
      expect(result.text, '<b>S</b>ha<b>rp</b>');
      expect(result.selection.textInside(result.text), 'ha');
    });

    test('toggle keeps the long name of a tag', () {
      final result = MiniMessageEditing.toggle(
        caretAt('<bold>ab</bold>', 7),
        'b',
      );
      expect(result.text, '<bold>a</bold><bold>b</bold>');
    });

    test('toggle ends every level of nested blocks', () {
      final result = MiniMessageEditing.toggle(
        caretAt('<i>a<i>b</i>c</i>', 7),
        'i',
      );
      expect(result.text, '<i>a</i><i><i>b</i>c</i>');
      expect(result.selection.baseOffset, 8);
    });

    test('the caret keeps the other formatting of the block', () {
      final result = MiniMessageEditing.toggle(
        caretAt('<b><gold>ab</gold></b>', 10),
        'b',
      );
      expect(
        result.text,
        '<b><gold>a</gold></b><gold></gold><b><gold>b</gold></b>',
      );
      // Between <gold> and </gold>, so what is typed there is gold.
      expect(result.selection.baseOffset, 27);
    });

    test('toggle adds the formatting only where it is missing', () {
      final result = MiniMessageEditing.toggle(
        selected('<b>ab</b>cd', 4, 10),
        'b',
      );
      expect(result.text, '<b>ab</b><b>c</b>d');
      expect(MiniMessageEditing.isActive(result, 'b'), isTrue);
    });

    test('toggle closes and reopens the tags inside the block', () {
      final result = MiniMessageEditing.toggle(
        selected('<b><i>abc</i></b>', 7, 8),
        'b',
      );
      expect(result.text, '<b><i>a</i></b><i>b</i><b><i>c</i></b>');
      expect(result.selection.textInside(result.text), 'b');
    });
  });

  group('across tags', () {
    test('wrap does not cross a tag opened inside the selection', () {
      final result = MiniMessageEditing.wrap(
        selected('x<i>yz</i>', 0, 5),
        '<b>',
        '</b>',
      );
      expect(result.text, '<b>x</b><i><b>y</b>z</i>');
    });

    test('wrap does not cross a tag closed inside the selection', () {
      final result = MiniMessageEditing.wrap(
        selected('<i>xy</i>z', 4, 10),
        '<b>',
        '</b>',
      );
      expect(result.text, '<i>x<b>y</b></i><b>z</b>');
    });

    test('a color does not cross a decoration', () {
      final result = MiniMessageEditing.applyColorTag(
        selected('<b>ab</b>cd', 4, 10),
        NamedTextColor.red.key,
      );
      expect(result.text, '<b>a<red>b</red></b><red>c</red>d');
    });

    test('toggle off across two blocks removes the tags between', () {
      final result = MiniMessageEditing.toggle(
        selected('<b>ab</b><b>cd</b>', 4, 13),
        'b',
      );
      expect(result.text, '<b>a</b>bc<b>d</b>');
    });
  });

  group('isActive', () {
    for (final (name, value, active) in [
      ('in a block', caretAt('a<b>bc</b>d', 5), true),
      ('in an empty pair', caretAt('<b></b>', 3), true),
      ('on the selected block', selected('<b>x</b>', 0, 8), true),
      ('with a long name', caretAt('<bold>x</bold>', 6), true),
      ('before a block', caretAt('a<b>bc</b>', 1), false),
      ('after a block', caretAt('<b>bc</b>d', 9), false),
      ('partly formatted', selected('<b>ab</b>cd', 4, 10), false),
      ('in another tag', caretAt('<i>ab</i>', 4), false),
    ]) {
      test(name, () {
        expect(MiniMessageEditing.isActive(value, 'b'), active);
      });
    }

    test('a second toggle at the caret undoes the first', () {
      final once = MiniMessageEditing.toggle(caretAt('ab', 1), 'u');
      expect(MiniMessageEditing.isActive(once, 'u'), isTrue);
      final twice = MiniMessageEditing.toggle(once, 'u');
      expect(MiniMessageEditing.isActive(twice, 'u'), isFalse);
    });
  });

  group('colorAt', () {
    for (final (name, value, color) in [
      ('without a color', caretAt('ab', 1), null),
      ('in a named color', caretAt('<yellow>ab', 9), const Color(0xFFFFFF55)),
      ('in a hex color', caretAt('<#123456>a', 9), const Color(0xFF123456)),
      (
        'in the innermost of two',
        caretAt('<gold>a<dark_aqua>b', 19),
        const Color(0xFF00AAAA),
      ),
      (
        'after the inner one closed',
        caretAt('<gold>a<red>b</red>c', 19),
        const Color(0xFFFFAA00),
      ),
      ('after a reset', caretAt('<gold>a<reset>b', 15), null),
      ('right before the tag', caretAt('a<gold>b', 1), null),
      (
        'at the start of a selection',
        selected('<gold>ab</gold>', 6, 8),
        const Color(0xFFFFAA00),
      ),
    ]) {
      test(name, () {
        expect(MiniMessageEditing.colorAt(value), color);
      });
    }
  });

  group('hex colors and longer gradients', () {
    test('a hex color wraps the selection', () {
      final result = MiniMessageEditing.applyColorTag(all('Epic'), '#ff00aa');
      expect(result.text, '<#ff00aa>Epic</#ff00aa>');
      expectSelection(result, 9, 13);
    });

    test('a hex color replaces a named one instead of nesting', () {
      final result = MiniMessageEditing.applyColorTag(
        all('<gold>Epic</gold>'),
        '#ff00aa',
      );
      expect(result.text, '<#ff00aa>Epic</#ff00aa>');
    });

    test('a named color replaces a hex one', () {
      final result = MiniMessageEditing.applyColorTag(
        selected('<#ff00aa>Epic</#ff00aa>', 9, 13),
        NamedTextColor.gold.key,
      );
      expect(result.text, '<gold>Epic</gold>');
    });

    test('a gradient over three colors', () {
      final result = MiniMessageEditing.applyGradientStops(all('Fire'), [
        'gold',
        '#ff5555',
        'light_purple',
      ]);
      expect(
        result.text,
        '<gradient:gold:#ff5555:light_purple>Fire</gradient>',
      );
    });

    test('a new gradient replaces one with other stops', () {
      final result = MiniMessageEditing.applyGradientStops(
        all('<gradient:red:blue>Fire</gradient>'),
        ['#000000', '#ffffff'],
      );
      expect(result.text, '<gradient:#000000:#ffffff>Fire</gradient>');
    });

    for (final (tag, color) in [
      ('#ff00aa', true),
      ('#f0a', true),
      ('gold', true),
      ('#ff00a', false),
      ('b', false),
      ('gradient', false),
    ]) {
      test('$tag is ${color ? '' : 'not '}a color tag', () {
        expect(MiniMessageEditing.isColorTag(tag), color);
      });
    }
  });
}
