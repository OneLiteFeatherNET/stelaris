import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/command_palette/command_search.dart';

void main() {
  group('scoreMatch', () {
    test('matches non-adjacent characters in order', () {
      expect(scoreMatch('gtit', 'Go to Items'), isNotNull);
    });

    test('does not match characters out of order', () {
      expect(scoreMatch('tig', 'Go to Items'), isNull);
    });

    test('does not match a character that is absent', () {
      expect(scoreMatch('xyz', 'Go to Items'), isNull);
    });

    test('ignores case', () {
      expect(scoreMatch('DARK', 'Toggle dark mode'), isNotNull);
      expect(scoreMatch('dark', 'TOGGLE DARK MODE'), isNotNull);
    });

    test('an empty query matches everything', () {
      expect(scoreMatch('', 'anything'), 0);
      expect(scoreMatch('   ', 'anything'), 0);
    });

    test('ranks a prefix above a scattered match', () {
      final int prefix = scoreMatch('item', 'Items')!;
      final int scattered = scoreMatch('item', 'Reload git release metadata')!;
      expect(prefix, greaterThan(scattered));
    });

    test('ranks a word-start match above a mid-word match', () {
      final int wordStart = scoreMatch('so', 'Go to Sound')!;
      final int midWord = scoreMatch('so', 'Reload lessons')!;
      expect(wordStart, greaterThan(midWord));
    });

    test('ranks consecutive characters above spread-out ones', () {
      final int consecutive = scoreMatch('dark', 'Toggle darkmode')!;
      final int spread = scoreMatch('dark', 'Toggle dxaxrxk')!;
      expect(consecutive, greaterThan(spread));
    });

    test('prefers the best placement over the first one', () {
      // The first 's' in "lessons" is followed by another 's', not by 'o';
      // the adjacent "so" further on is the placement that should count.
      final int adjacent = scoreMatch('so', 'lessons')!;
      final int apart = scoreMatch('so', 'lessxon')!;
      expect(adjacent, greaterThan(apart));
    });

    test('ignores spaces in the query', () {
      expect(scoreMatch('go items', 'Go to Items'), isNotNull);
    });
  });
}
