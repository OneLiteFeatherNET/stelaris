import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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
}
