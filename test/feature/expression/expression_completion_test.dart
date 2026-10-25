import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
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

  group('formulaSuggestions', () {
    const variables = [
      ExpressionVariable(name: 'radius'),
      ExpressionVariable(name: 'Rate'),
    ];
    const catalog = ExpressionCatalog(
      functions: [
        CatalogFunction(name: 'ROUND', category: CatalogFunctionCategory.basic),
        CatalogFunction(name: 'RANDOM'),
        CatalogFunction(name: 'MAX'),
      ],
      constants: [
        CatalogConstant(name: 'RAD2DEG', value: '57.29'),
        CatalogConstant(name: 'PI', value: '3.14159'),
      ],
    );

    test('lists variables, then constants, then functions', () {
      final names = formulaSuggestions(
        prefix: 'r',
        variables: variables,
        catalog: catalog,
      ).map((s) => s.name);

      expect(names, ['radius', 'Rate', 'RAD2DEG', 'RANDOM', 'ROUND']);
    });

    test('sorts each group by name, ignoring case', () {
      final suggestions = formulaSuggestions(
        prefix: 'ra',
        variables: const [
          ExpressionVariable(name: 'rate'),
          ExpressionVariable(name: 'Radius'),
        ],
        catalog: catalog,
      );

      expect(suggestions.map((s) => s.name), [
        'Radius',
        'rate',
        'RAD2DEG',
        'RANDOM',
      ]);
    });

    test('matches constants and functions ignoring case', () {
      final names = formulaSuggestions(
        prefix: 'ro',
        variables: const [],
        catalog: catalog,
      ).map((s) => s.name);

      expect(names, ['ROUND']);
    });

    test('offers only variables while the catalog is not loaded', () {
      final names = formulaSuggestions(
        prefix: 'r',
        variables: variables,
      ).map((s) => s.name);

      expect(names, ['radius', 'Rate']);
    });

    test('offers nothing for an empty prefix', () {
      expect(
        formulaSuggestions(prefix: '', variables: variables, catalog: catalog),
        isEmpty,
      );
    });
  });

  group('completeSuggestion', () {
    const round = CatalogFunction(name: 'ROUND');
    const pi = CatalogConstant(name: 'PI', value: '3.14159');

    test('a function is inserted with an opening parenthesis', () {
      final prefix = identifierPrefixAt('2 * ro', 6)!;

      final edit = completeSuggestion(
        '2 * ro',
        prefix,
        6,
        const FunctionSuggestion(round),
      );

      expect(edit.text, '2 * ROUND(');
      expect(edit.caret, 10);
    });

    test('a function is not given a second parenthesis', () {
      const text = 'ro(a)';
      final prefix = identifierPrefixAt(text, 2)!;

      final edit = completeSuggestion(
        text,
        prefix,
        2,
        const FunctionSuggestion(round),
      );

      expect(edit.text, 'ROUND(a)');
      expect(edit.caret, 5);
    });

    test('a constant is inserted by its name', () {
      final prefix = identifierPrefixAt('p', 1)!;

      final edit = completeSuggestion(
        'p',
        prefix,
        1,
        const ConstantSuggestion(pi),
      );

      expect(edit.text, 'PI');
      expect(edit.caret, 2);
    });
  });

  group('enclosingCall', () {
    test('finds the call and counts the commas before the caret', () {
      final call = enclosingCall('ROUND(a, ', 9);

      expect(call?.name, 'ROUND');
      expect(call?.argumentIndex, 1);
    });

    test('finds the innermost call of a nested pair', () {
      final call = enclosingCall('MAX(ROUND(a', 11);

      expect(call?.name, 'ROUND');
      expect(call?.argumentIndex, 0);
    });

    test('gives the outer call again once the inner call is closed', () {
      final call = enclosingCall('MAX(ROUND(a, 2), ', 17);

      expect(call?.name, 'MAX');
      expect(call?.argumentIndex, 1);
    });

    test('ignores a comma inside a string literal', () {
      final call = enclosingCall('STR_LEFT("a,b"', 14);

      expect(call?.name, 'STR_LEFT');
      expect(call?.argumentIndex, 0);
    });

    test('ignores a comma inside an open string literal', () {
      final call = enclosingCall("STR_LEFT('a,", 11);

      expect(call?.argumentIndex, 0);
    });

    test('a grouping bracket does not hide the call around it', () {
      final call = enclosingCall('ROUND(1, (2 + 3', 15);

      expect(call?.name, 'ROUND');
      expect(call?.argumentIndex, 1);
    });

    test('gives null outside any call', () {
      expect(enclosingCall('a + b', 5), isNull);
    });

    test('gives null when the call is closed before the caret', () {
      expect(enclosingCall('ROUND(a) + ', 11), isNull);
    });
  });

  group('signatureHelpAt', () {
    const catalog = ExpressionCatalog(
      functions: [
        CatalogFunction(
          name: 'ROUND',
          parameters: [
            CatalogParameter(name: 'value'),
            CatalogParameter(name: 'precision'),
          ],
        ),
        CatalogFunction(
          name: 'MAX',
          parameters: [CatalogParameter(name: 'value', varArg: true)],
        ),
      ],
    );

    test('highlights the parameter the caret is at', () {
      final help = signatureHelpAt('ROUND(a, ', 9, catalog);

      expect(help?.text, 'ROUND(value, precision)');
      expect(help?.highlighted, 1);
    });

    test('matches the function name ignoring case', () {
      final help = signatureHelpAt('round(a, ', 9, catalog);

      expect(help?.function.name, 'ROUND');
    });

    test('keeps the vararg parameter highlighted for every later argument', () {
      final help = signatureHelpAt('MAX(1, 2, ', 10, catalog);

      expect(help?.text, 'MAX(value…)');
      expect(help?.highlighted, 0);
    });

    test('highlights nothing past the last parameter of a fixed call', () {
      final help = signatureHelpAt('ROUND(1, 2, ', 12, catalog);

      expect(help?.highlighted, isNull);
    });

    test('gives null for a function the catalog does not know', () {
      expect(signatureHelpAt('SQRT(a, ', 8, catalog), isNull);
    });

    test('gives null without a catalog', () {
      expect(signatureHelpAt('ROUND(a, ', 9, null), isNull);
    });
  });
}
