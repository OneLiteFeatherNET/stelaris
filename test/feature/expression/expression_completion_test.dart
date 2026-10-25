import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/feature/expression/expression_completion.dart';

void main() {
  group('identifierPrefixAt', () {
    test('gives no prefix at the start of the text', () {
      expect(identifierPrefixAt('radius', 0), isNull);
    });

    test('takes the identifier typed after an operator', () {
      final prefix = identifierPrefixAt('2 * ra', 6);

      expect(prefix?.text, 'ra');
      expect(prefix?.start, 4);
    });

    test('gives no prefix for a token that starts with a digit', () {
      expect(identifierPrefixAt('2abc', 4), isNull);
    });

    test('takes only the part left of the caret inside a word', () {
      final prefix = identifierPrefixAt('radius', 2);

      expect(prefix?.text, 'ra');
      expect(prefix?.start, 0);
    });

    test('gives no prefix for a caret beyond the text', () {
      expect(identifierPrefixAt('ra', 3), isNull);
    });
  });

  group('variableSuggestions', () {
    const variables = [
      ExpressionVariable(name: 'radius'),
      ExpressionVariable(name: 'Rate'),
      ExpressionVariable(name: 'height'),
    ];

    test('matches names that start with the prefix ignoring case', () {
      final names = variableSuggestions(variables, 'RA').map((v) => v.name);

      expect(names, ['radius', 'Rate']);
    });

    test('leaves out a name that equals the prefix', () {
      final names = variableSuggestions(variables, 'radius').map((v) => v.name);

      expect(names, isEmpty);
    });

    test('matches nothing for an empty prefix', () {
      expect(variableSuggestions(variables, ''), isEmpty);
    });
  });

  group('completeVariable', () {
    test('replaces the prefix with the name and puts the caret after it', () {
      final prefix = identifierPrefixAt('2 * ra + 1', 6);

      final edit = completeVariable('2 * ra + 1', prefix!, 6, 'radius');

      expect(edit.text, '2 * radius + 1');
      expect(edit.caret, 10);
    });
  });

  group('replaceFormulaRange', () {
    test('replaces a selection and puts the caret after the insert', () {
      final edit = replaceFormulaRange('a + b', 4, 5, 'radius');

      expect(edit.text, 'a + radius');
      expect(edit.caret, 10);
    });
  });
}
