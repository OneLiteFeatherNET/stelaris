import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/util/font_part.dart';

void main() {
  group('isFontPart', () {
    test('accepts the bounds of all three Private Use Areas', () {
      for (final codePoint in [
        0xE000,
        0xF8FF,
        0xF0000,
        0xFFFFD,
        0x100000,
        0x10FFFD,
      ]) {
        expect(
          isFontPart(codePoint),
          isTrue,
          reason: codePoint.toRadixString(16),
        );
      }
    });

    test('rejects code points next to and outside the areas', () {
      for (final codePoint in [
        0x0000,
        0x0041,
        0xDFFF,
        0xF900,
        0xEFFFF,
        0xFFFFE,
        0x10FFFE,
      ]) {
        expect(
          isFontPart(codePoint),
          isFalse,
          reason: codePoint.toRadixString(16),
        );
      }
    });
  });

  group('parseCodePoints', () {
    test('parses hex of 4 to 6 digits separated by whitespace', () {
      expect(parseCodePoints(' E000  e001\tF0000 10FFFD '), [
        0xE000,
        0xE001,
        0xF0000,
        0x10FFFD,
      ]);
    });

    test('returns null for blank input or malformed parts', () {
      expect(parseCodePoints(''), isNull);
      expect(parseCodePoints('   '), isNull);
      expect(parseCodePoints('E00'), isNull);
      expect(parseCodePoints('1000000'), isNull);
      expect(parseCodePoints('E000 XYZ0'), isNull);
      expect(parseCodePoints('E000,E001'), isNull);
    });
  });

  group('formatCodePoints', () {
    test('formats every character as uppercase hex', () {
      expect(formatCodePoints(''), 'E000 E0AB');
    });

    test('formats a code point above FFFF as one value', () {
      expect(
        formatCodePoints(String.fromCharCodes([0xF0000, 0x10FFFD])),
        'F0000 10FFFD',
      );
    });

    test('round trips with parseCodePoints', () {
      final line = String.fromCharCodes([0xE000, 0xF0000]);
      expect(
        String.fromCharCodes(parseCodePoints(formatCodePoints(line))!),
        line,
      );
    });
  });

  group('rowLengths', () {
    test('returns one length for lines of the same length', () {
      expect(rowLengths(['\uE000\uE001', '\uE002\uE003']), [2]);
    });

    test('returns every distinct length in ascending order', () {
      expect(rowLengths(['\uE000\uE001\uE002', '\uE003', '\uE004']), [1, 3]);
    });

    test('counts a code point above FFFF as one character', () {
      final plane15 = String.fromCharCodes([0xF0000]);
      expect(rowLengths([plane15, '\uE000']), [1]);
    });

    test('returns nothing for no lines', () {
      expect(rowLengths([]), isEmpty);
    });
  });

  group('expectedRowLength', () {
    test('returns the most common length', () {
      expect(expectedRowLength(['\uE000', '\uE001\uE002', '\uE003']), 1);
    });

    test('takes the length that comes first on a tie', () {
      expect(expectedRowLength(['\uE000\uE001\uE002', '\uE003']), 3);
    });

    test('returns null for no lines', () {
      expect(expectedRowLength([]), isNull);
    });
  });
}
