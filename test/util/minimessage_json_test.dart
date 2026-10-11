import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/minimessage_json.dart';
import 'package:stelaris/util/minimessage_parser.dart';

/// Every character of [input] with how the preview draws it, the color at
/// the precision of JSON, eight bits a channel.
List<String> looks(String input) {
  final result = <String>[];
  MiniMessageParser.parse(input).visitChildren((span) {
    if (span is TextSpan && span.text != null) {
      final style = span.style!;
      for (final char in span.text!.split('')) {
        result.add(
          '$char ${style.color?.toARGB32()} ${style.fontWeight} '
          '${style.fontStyle} '
          '${style.decoration}',
        );
      }
    }
    return true;
  });
  return result;
}

void main() {
  group('encode', () {
    test('plain text stays a string', () {
      expect(MiniMessageJson.encode('Epic'), 'Epic');
      expect(MiniMessageJson.encode(''), '');
    });

    test('one formatted part is a single object', () {
      expect(MiniMessageJson.encode('<gold>Epic'), {
        'text': 'Epic',
        'color': 'gold',
      });
    });

    test('several parts go into extra', () {
      expect(MiniMessageJson.encode('<gold>Epic <b>Sword'), {
        'text': '',
        'extra': [
          {'text': 'Epic ', 'color': 'gold'},
          {'text': 'Sword', 'color': 'gold', 'bold': true},
        ],
      });
    });

    test('closing a tag ends its formatting', () {
      expect(MiniMessageJson.encode('<u>a</u>b'), {
        'text': '',
        'extra': [
          {'text': 'a', 'underlined': true},
          {'text': 'b'},
        ],
      });
    });

    test('hex colors are written in six lower case digits', () {
      expect(MiniMessageJson.encode('<#F0A>x'), {
        'text': 'x',
        'color': '#ff00aa',
      });
      expect(MiniMessageJson.encode('<color:#00FF00>y'), {
        'text': 'y',
        'color': '#00ff00',
      });
    });

    test('a negation switches the decoration off explicitly', () {
      expect(MiniMessageJson.encode('<!i>Name'), {
        'text': 'Name',
        'italic': false,
      });
    });

    test('a gradient colors every character on its own', () {
      final json = MiniMessageJson.encode('<gradient:red:blue>abc</gradient>');
      final extra = (json as Map)['extra'] as List;
      expect(extra, hasLength(3));
      expect(extra.first, {'text': 'a', 'color': '#ff5555'});
      expect(extra.last, {'text': 'c', 'color': '#5555ff'});
    });

    test('unknown tags stay text, like in game', () {
      expect(MiniMessageJson.encode('<golld>x'), '<golld>x');
    });

    test('reset ends everything', () {
      expect(MiniMessageJson.encode('<red><b>a<reset>b'), {
        'text': '',
        'extra': [
          {'text': 'a', 'color': 'red', 'bold': true},
          {'text': 'b'},
        ],
      });
    });
  });

  group('decode', () {
    test('a string is the text', () {
      expect(MiniMessageJson.decode('Epic'), 'Epic');
      expect(MiniMessageJson.decode(null), '');
    });

    test('an object with its style', () {
      expect(
        MiniMessageJson.decode({'text': 'Epic', 'color': 'gold', 'bold': true}),
        '<gold><b>Epic',
      );
    });

    test('extra parts inherit the style of their parent', () {
      expect(
        MiniMessageJson.decode({
          'text': 'Epic ',
          'color': 'gold',
          'extra': [
            {'text': 'Sword', 'bold': true},
          ],
        }),
        '<gold>Epic <b>Sword',
      );
    });

    test('in a list the first one is the parent of the others', () {
      expect(
        MiniMessageJson.decode([
          {'text': 'a', 'color': 'red'},
          'b',
          {'text': 'c', 'color': 'blue'},
        ]),
        '<red>ab</red><blue>c',
      );
    });

    test('a changed color keeps the decorations open', () {
      expect(
        MiniMessageJson.decode({
          'text': '',
          'extra': [
            {'text': 'a', 'color': 'red', 'bold': true},
            {'text': 'b', 'bold': true},
          ],
        }),
        '<red><b>a</b></red><b>b',
      );
    });

    test('a negation is ended with a reset', () {
      expect(
        MiniMessageJson.decode({
          'text': '',
          'extra': [
            {'text': 'a', 'italic': false},
            {'text': 'b'},
          ],
        }),
        '<!i>a<reset>b',
      );
    });

    test('upper case hex colors work', () {
      expect(
        MiniMessageJson.decode({'text': 'x', 'color': '#FF00AA'}),
        '<#ff00aa>x',
      );
    });

    test('a translation keeps its key as text', () {
      expect(
        MiniMessageJson.decode({'translate': 'item.minecraft.stone'}),
        'item.minecraft.stone',
      );
    });
  });

  group('round trip', () {
    for (final (input, output) in [
      ('Epic', 'Epic'),
      ('<gold>Epic <b>Sword', '<gold>Epic <b>Sword'),
      ('<gold><!i>Name', '<gold><!i>Name'),
      (
        '<#00aaaa><u>Deep</u></#00aaaa> sea',
        '<#00aaaa><u>Deep</u></#00aaaa> sea',
      ),
      // Tags still open at the end are left open.
      (
        '<gradient:#ff5555:#5555ff>Burning Blade</gradient>',
        '<gradient:#ff5555:#5555ff>Burning Blade',
      ),
      ('<rainbow>Party Hat</rainbow>', '<rainbow>Party Hat'),
    ]) {
      test('"$input" comes back the same', () {
        expect(MiniMessageJson.decode(MiniMessageJson.encode(input)), output);
      });
    }

    test('a gradient of named colors comes back with hex colors', () {
      expect(
        MiniMessageJson.decode(
          MiniMessageJson.encode('<gradient:red:blue>Fire</gradient>'),
        ),
        '<gradient:#ff5555:#5555ff>Fire',
      );
    });

    test('two characters stay hex colors, a gradient can not be told', () {
      expect(
        MiniMessageJson.decode(
          MiniMessageJson.encode('<gradient:red:blue>ab</gradient>'),
        ),
        '<#ff5555>a</#ff5555><#5555ff>b',
      );
    });

    test('a rainbow over decorations is stored per character', () {
      final json = MiniMessageJson.encode('<rainbow>ab<b>cd</b></rainbow>');
      final extra = (json as Map)['extra'] as List;
      expect(extra, hasLength(4));
      expect((extra[2] as Map)['bold'], isTrue);
      expect(extra.map((part) => (part as Map)['color']).toSet(), hasLength(4));
    });

    test('an emoji counts as one character when loading', () {
      expect(
        MiniMessageJson.decode(
          MiniMessageJson.encode('<rainbow>a\u{1F600}bc</rainbow>'),
        ),
        '<rainbow>a\u{1F600}bc',
      );
    });

    test('random texts look the same after a round trip', () {
      const tags = [
        '<b>',
        '</b>',
        '<i>',
        '</i>',
        '<!i>',
        '<u>',
        '<st>',
        '</st>',
        '<gold>',
        '</gold>',
        '<#55ccff>',
        '<reset>',
        '<rainbow>',
        '</rainbow>',
        '<gradient:red:blue>',
        '</gradient>',
        '<golld>',
      ];
      final random = Random(3);
      for (var i = 0; i < 2000; i++) {
        final buffer = StringBuffer();
        for (var k = 0; k < 10; k++) {
          buffer.write(
            random.nextBool()
                ? tags[random.nextInt(tags.length)]
                : ['a', 'b', 'c', ' ', '\u{1F600}'][random.nextInt(5)],
          );
        }
        final input = buffer.toString();
        final output = MiniMessageJson.decode(MiniMessageJson.encode(input));
        expect(looks(output), looks(input), reason: '"$input" -> "$output"');
      }
    });
  });
}
