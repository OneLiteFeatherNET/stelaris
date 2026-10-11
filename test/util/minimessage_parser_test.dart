import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/minimessage_parser.dart';

void main() {
  group('MiniMessageParser Tests', () {
    test('parses plain text without tags', () {
      final span = MiniMessageParser.parse('Hello World');
      expect(span.children?.length, equals(1));
      final first = span.children!.first as TextSpan;
      expect(first.text, equals('Hello World'));
      expect(first.style?.color, equals(Colors.white));
    });

    test('parses named colors', () {
      final span = MiniMessageParser.parse('<yellow>Yellow <green>Green');
      expect(span.children?.length, equals(2));

      final first = span.children![0] as TextSpan;
      expect(first.text, equals('Yellow '));
      expect(first.style?.color, equals(const Color(0xFFFFFF55)));

      final second = span.children![1] as TextSpan;
      expect(second.text, equals('Green'));
      expect(second.style?.color, equals(const Color(0xFF55FF55)));
    });

    test('parses colors with more than one word by their minecraft name', () {
      final span = MiniMessageParser.parse(
        '<dark_purple>Purple <light_purple>Pink',
      );

      final first = span.children![0] as TextSpan;
      expect(first.text, equals('Purple '));
      expect(first.style?.color, equals(const Color(0xFFAA00AA)));

      final second = span.children![1] as TextSpan;
      expect(second.text, equals('Pink'));
      expect(second.style?.color, equals(const Color(0xFFFF55FF)));
    });

    test('uses the given weight, bold stays bold', () {
      final span = MiniMessageParser.parse(
        'Thin <b>Thick',
        fontWeight: FontWeight.w500,
      );

      expect(
        (span.children![0] as TextSpan).style?.fontWeight,
        FontWeight.w500,
      );
      expect(
        (span.children![1] as TextSpan).style?.fontWeight,
        FontWeight.bold,
      );
    });

    test('parses hex colors', () {
      final span = MiniMessageParser.parse('<#ff00aa>Hex Text');
      expect(span.children?.length, equals(1));
      final first = span.children!.first as TextSpan;
      expect(first.text, equals('Hex Text'));
      expect(first.style?.color, equals(const Color(0xFFFF00AA)));
    });

    test('parses bold and italic decorations', () {
      final span = MiniMessageParser.parse('<b><italic>Styled</italic></b>');
      expect(span.children?.length, equals(1));
      final first = span.children!.first as TextSpan;
      expect(first.text, equals('Styled'));
      expect(first.style?.fontWeight, equals(FontWeight.bold));
      expect(first.style?.fontStyle, equals(FontStyle.italic));
    });

    test('parses negative/closing tags', () {
      final span = MiniMessageParser.parse('<b>Bold</b><!b>Normal');
      expect(span.children?.length, equals(2));
      final first = span.children![0] as TextSpan;
      expect(first.style?.fontWeight, equals(FontWeight.bold));
      final second = span.children![1] as TextSpan;
      expect(second.style?.fontWeight, equals(FontWeight.normal));
    });

    test('parses gradients into character spans', () {
      final span = MiniMessageParser.parse('<gradient:red:blue>AB</gradient>');
      expect(span.children?.length, equals(2));
      final charA = span.children![0] as TextSpan;
      final charB = span.children![1] as TextSpan;
      expect(charA.text, equals('A'));
      expect(charB.text, equals('B'));
      expect(charA.style?.color, isNot(equals(charB.style?.color)));
    });

    test('reset tag clears formatting', () {
      final span = MiniMessageParser.parse('<red><b>Text<reset>Clean');
      expect(span.children?.length, equals(2));
      final first = span.children![0] as TextSpan;
      expect(first.style?.fontWeight, equals(FontWeight.bold));
      expect(first.style?.color, equals(const Color(0xFFFF5555)));

      final second = span.children![1] as TextSpan;
      expect(second.style?.fontWeight, equals(FontWeight.normal));
      expect(second.style?.color, equals(Colors.white));
    });
  });

  group('ComponentContext defaults', () {
    TextSpan firstChild(TextSpan span) => span.children!.first as TextSpan;

    test('lore renders dark purple and not italic by default', () {
      final span = MiniMessageParser.parse(
        'Lore',
        componentContext: ComponentContext.lore,
      );
      expect(firstChild(span).style?.color, const Color(0xFFAA00AA));
      expect(firstChild(span).style?.fontStyle, FontStyle.normal);
    });

    test('item name renders white and not italic by default', () {
      final span = MiniMessageParser.parse(
        'Sword',
        componentContext: ComponentContext.itemName,
      );
      expect(firstChild(span).style?.color, const Color(0xFFFFFFFF));
      expect(firstChild(span).style?.fontStyle, FontStyle.normal);
    });

    test('notification title renders white and not italic', () {
      final span = MiniMessageParser.parse(
        'Title',
        componentContext: ComponentContext.notificationTitle,
      );
      expect(firstChild(span).style?.color, const Color(0xFFFFFFFF));
      expect(firstChild(span).style?.fontStyle, FontStyle.normal);
    });

    test('italic shows only where an italic tag is present', () {
      final span = MiniMessageParser.parse(
        'a<i>b</i>c',
        componentContext: ComponentContext.lore,
      );
      final styles = [
        for (final child in span.children!)
          (child as TextSpan).style?.fontStyle,
      ];
      expect(styles, [FontStyle.normal, FontStyle.italic, FontStyle.normal]);
    });

    test('<!i> keeps text upright', () {
      final span = MiniMessageParser.parse(
        '<!i>Plain',
        componentContext: ComponentContext.itemName,
      );
      expect(firstChild(span).style?.fontStyle, FontStyle.normal);
    });

    test('<reset> returns to the context color and upright text', () {
      final span = MiniMessageParser.parse(
        '<red><i>x<reset>y',
        componentContext: ComponentContext.lore,
      );
      final second = span.children![1] as TextSpan;
      expect(second.style?.color, const Color(0xFFAA00AA));
      expect(second.style?.fontStyle, FontStyle.normal);
    });
  });

  group('nested colors', () {
    List<Color?> colorsOf(String input) {
      final colors = <Color?>[];
      MiniMessageParser.parse(input).visitChildren((span) {
        if (span is TextSpan && span.text != null) {
          colors.add(span.style?.color);
        }
        return true;
      });
      return colors;
    }

    test('closing an inner color returns to the outer one', () {
      expect(colorsOf('<gold>A<red>B</red>C</gold>'), [
        const Color(0xFFFFAA00),
        const Color(0xFFFF5555),
        const Color(0xFFFFAA00),
      ]);
    });

    test('closing the outer color returns to the default', () {
      expect(colorsOf('<gold>A<red>B</red></gold>C'), [
        const Color(0xFFFFAA00),
        const Color(0xFFFF5555),
        const Color(0xFFFFFFFF),
      ]);
    });

    test('reset forgets all open colors', () {
      expect(colorsOf('<gold><red>A<reset>B</red>C'), [
        const Color(0xFFFF5555),
        const Color(0xFFFFFFFF),
        const Color(0xFFFFFFFF),
      ]);
    });
  });

  group('unknown tags', () {
    test('are rendered literally', () {
      final span = MiniMessageParser.parse('I <3> you');
      expect(span.toPlainText(), 'I <3> you');
    });

    test('unknown closing tags are rendered literally', () {
      final span = MiniMessageParser.parse('a</foo>b');
      expect(span.toPlainText(), 'a</foo>b');
    });

    test('invalid hex colors are rendered literally', () {
      final span = MiniMessageParser.parse('<#12>x');
      expect(span.toPlainText(), '<#12>x');
    });

    test(
      'a gradient with fewer than two valid colors is rendered literally',
      () {
        expect(
          MiniMessageParser.parse('<gradient:red>x').toPlainText(),
          '<gradient:red>x',
        );
        expect(
          MiniMessageParser.parse('<gradient:gold:redd>y').toPlainText(),
          '<gradient:gold:redd>y',
        );
      },
    );

    test('an unknown tag starting with gradient is rendered literally', () {
      expect(
        MiniMessageParser.parse('<gradientfoo>z').toPlainText(),
        '<gradientfoo>z',
      );
    });

    test('closing an invalid hex color is rendered literally', () {
      expect(MiniMessageParser.parse('</#zzz>w').toPlainText(), '</#zzz>w');
    });

    test('a valid gradient still hides its tags', () {
      expect(
        MiniMessageParser.parse('<gradient:red:blue>ab</gradient>')
            .toPlainText(),
        'ab',
      );
    });

    test('a lone < without a tag is kept', () {
      final span = MiniMessageParser.parse('a < b');
      expect(span.toPlainText(), 'a < b');
    });
  });

  group('MiniMessageParser.highlight', () {
    const tagStyle = TextStyle(color: Color(0xFF808080), fontSize: 12);
    const unknownTagStyle = TextStyle(
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.wavy,
    );

    TextSpan highlight(String input) => MiniMessageParser.highlight(
      input,
      componentContext: ComponentContext.lore,
      tagStyle: tagStyle,
      unknownTagStyle: unknownTagStyle,
    );

    TextSpan spanOf(TextSpan root, String text) =>
        root.children!.cast<TextSpan>().singleWhere((s) => s.text == text);

    for (final input in [
      '',
      'plain',
      '<gold>Epic <b>bold</b></gold> rest',
      '<gradient:red:blue>ab</gradient>',
      '<rainbow>abc</rainbow><reset>x',
      '<golld>typo',
      '<gradient:gold:redd>y',
      '</#zzz>w',
      'a < b',
    ]) {
      test('keeps every character of "$input"', () {
        expect(highlight(input).toPlainText(), input);
      });
    }

    test('shows the known tags in the tag style', () {
      final span = highlight('<gold>Epic</gold>');

      expect(spanOf(span, '<gold>').style, tagStyle);
      expect(spanOf(span, '</gold>').style, tagStyle);
      expect(spanOf(span, 'Epic').style?.color, const Color(0xFFFFAA00));
    });

    test('marks the tags minecraft prints as text', () {
      final span = highlight('<gold><golld>x');

      final typo = spanOf(span, '<golld>');
      expect(typo.style?.decorationStyle, TextDecorationStyle.wavy);
      // Printed in the color around it, like in game.
      expect(typo.style?.color, const Color(0xFFFFAA00));
    });

    test('parse still leaves the known tags out', () {
      expect(
        MiniMessageParser.parse('<gold>Epic</gold>').toPlainText(),
        'Epic',
      );
    });
  });

  group('rainbowColor', () {
    String hex(Color color) =>
        (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');

    test('six characters go once around the color wheel', () {
      expect(
        [for (var i = 0; i < 6; i++) hex(MiniMessageParser.rainbowColor(i, 6))],
        ['ff0000', 'ffff00', '00ff00', '00ffff', '0000ff', 'ff00ff'],
      );
    });

    test('channels are cut like in adventure, not rounded', () {
      // Hue 1/7: 6/7 of the way to yellow, 218.57 in green.
      expect(hex(MiniMessageParser.rainbowColor(1, 7)), 'ffda00');
    });

    test('a single character is red', () {
      expect(hex(MiniMessageParser.rainbowColor(0, 1)), 'ff0000');
    });

    test('the preview uses it for every character, spaces too', () {
      final span = MiniMessageParser.parse('<rainbow>a b');
      final colors = [
        for (final child in span.children!.cast<TextSpan>()) child.style!.color,
      ];
      expect(colors, [
        for (var i = 0; i < 3; i++) MiniMessageParser.rainbowColor(i, 3),
      ]);
      expect(hex(colors[1]!), '00ff00');
    });
  });
}
