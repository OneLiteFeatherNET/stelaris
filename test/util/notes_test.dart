import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/util/notes.dart';

void main() {
  group('notesSummary', () {
    test('returns null without text', () {
      expect(notesSummary(null), isNull);
      expect(notesSummary(''), isNull);
      expect(notesSummary('  \n \n'), isNull);
    });

    test('returns the first line, trimmed', () {
      expect(notesSummary('  Boss drop \nOnly in the nether'), 'Boss drop');
    });

    test('skips leading blank lines', () {
      expect(notesSummary('\n\n  Boss drop\nMore'), 'Boss drop');
    });
  });
}
