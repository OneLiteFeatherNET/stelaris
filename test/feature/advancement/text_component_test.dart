import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/advancement/text_component.dart';

void main() {
  group('plainTextOf', () {
    test('reads a string component', () {
      expect(plainTextOf('"First Kill"'), 'First Kill');
    });

    test('reads the text of an object component', () {
      expect(plainTextOf('{"text":"First Kill","color":"gold"}'), 'First Kill');
    });

    test('returns an empty string for a missing component', () {
      expect(plainTextOf(null), '');
      expect(plainTextOf(''), '');
    });

    test('keeps a value that is no text component', () {
      expect(plainTextOf('First Kill'), 'First Kill');
      expect(plainTextOf('{"translate":"a.b"}'), '{"translate":"a.b"}');
    });
  });

  group('textComponentOf', () {
    test('writes a string component', () {
      expect(textComponentOf('First Kill'), '"First Kill"');
    });

    test('escapes quotes', () {
      expect(textComponentOf('Say "hi"'), r'"Say \"hi\""');
    });

    test('returns null for an empty text', () {
      expect(textComponentOf(''), isNull);
    });

    test('keeps the other keys of an object component', () {
      expect(
        textComponentOf('Second', previous: '{"text":"First","color":"gold"}'),
        '{"text":"Second","color":"gold"}',
      );
    });

    test('replaces a previous value that is no component', () {
      expect(textComponentOf('Second', previous: 'First'), '"Second"');
    });
  });
}
