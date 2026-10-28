import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/feature/expression/expression_tex.dart';

/// The project functions of the catalog the examples call.
const _project = {'attribute_value', 'crit_multiplier', 'armor_reduction'};

String _tex(String formula, {Set<String> functionNames = const {}}) {
  final tex = expressionToTex(formula, functionNames: functionNames);
  expect(tex, isNotNull, reason: 'the formula "$formula" must convert');
  return tex!;
}

void main() {
  group('operators', () {
    test('parentheses around a fraction grow with it', () {
      expect(
        expressionToTex('2 * (a / b + 1)'),
        r'2 \cdot \left(\frac{\mathit{a}}{\mathit{b}} + 1\right)',
        reason: 'plain parentheses would stay small next to the fraction',
      );
    });

    test('division becomes a fraction of its operands', () {
      expect(
        _tex('armor / (armor + 100)'),
        r'\frac{\mathit{armor}}{\mathit{armor} + 100}',
        reason: 'a / b must be a fraction without parentheses in it',
      );
    });

    test('multiplication becomes a centred dot', () {
      expect(_tex('a * b'), r'\mathit{a} \cdot \mathit{b}');
    });

    test('modulo becomes bmod', () {
      expect(_tex('a % b'), r'\mathit{a} \bmod \mathit{b}');
    });

    test('power becomes a braced exponent', () {
      expect(_tex('level ^ 2'), r'{\mathit{level}}^{2}');
    });

    test('a power base that is not atomic is parenthesized', () {
      expect(
        _tex('(a + b) ^ 2'),
        r'{(\mathit{a} + \mathit{b})}^{2}',
        reason: 'a sum as base must keep its parentheses',
      );
    });

    test('a power exponent is written without parentheses', () {
      expect(_tex('2 ^ (a * b)'), r'{2}^{\mathit{a} \cdot \mathit{b}}');
    });

    test('parentheses are dropped when the precedence does not need them', () {
      expect(_tex('(a * b) + c'), r'\mathit{a} \cdot \mathit{b} + \mathit{c}');
    });

    test('a same-level right operand keeps its parentheses', () {
      expect(
        _tex('a - (b + c)'),
        r'\mathit{a} - (\mathit{b} + \mathit{c})',
        reason: 'a - (b + c) is not a - b + c',
      );
    });

    test('unary minus binds looser than power', () {
      expect(_tex('-x ^ 2'), r'-{\mathit{x}}^{2}');
    });

    test('a unary operand that binds looser gets parentheses', () {
      expect(_tex('-(a + b)'), r'-(\mathit{a} + \mathit{b})');
    });
  });

  group('comparisons and logic', () {
    test('a single equals sign and a double one both become =', () {
      expect(_tex('a = b'), r'\mathit{a} = \mathit{b}');
      expect(_tex('a == b'), r'\mathit{a} = \mathit{b}');
    });

    test('angle brackets written together become neq', () {
      expect(_tex('a <> b'), r'\mathit{a} \neq \mathit{b}');
    });

    test('not-equal becomes neq', () {
      expect(_tex('a != b'), r'\mathit{a} \neq \mathit{b}');
    });

    test('less or equal and greater or equal become leq and geq', () {
      expect(_tex('a <= b'), r'\mathit{a} \leq \mathit{b}');
      expect(_tex('a >= b'), r'\mathit{a} \geq \mathit{b}');
    });

    test('less than and greater than keep their symbols', () {
      expect(_tex('a < b'), r'\mathit{a} < \mathit{b}');
      expect(_tex('a > b'), r'\mathit{a} > \mathit{b}');
    });

    test('and becomes land', () {
      expect(_tex('a && b'), r'\mathit{a} \land \mathit{b}');
    });

    test('or becomes lor', () {
      expect(_tex('a || b'), r'\mathit{a} \lor \mathit{b}');
    });

    test('not becomes lnot', () {
      expect(_tex('!a'), r'\lnot \mathit{a}');
    });

    test('and binds tighter than or, so no parentheses are added', () {
      expect(
        _tex('a || b && c'),
        r'\mathit{a} \lor \mathit{b} \land \mathit{c}',
      );
    });

    test('a comparison binds looser than addition', () {
      expect(_tex('a + 1 > b'), r'\mathit{a} + 1 > \mathit{b}');
    });
  });

  group('built-in functions', () {
    test('SQRT becomes a square root', () {
      expect(_tex('SQRT(x)'), r'\sqrt{\mathit{x}}');
    });

    test('ABS becomes absolute value bars', () {
      expect(_tex('ABS(x)'), r'\left| \mathit{x} \right|');
    });

    test('ROUND becomes an operator name with its arguments', () {
      expect(
        _tex('ROUND(x, n)'),
        r'\mathrm{round}(\mathit{x}, \mathit{n})',
      );
    });

    test('MIN and MAX become min and max with their arguments', () {
      expect(_tex('MIN(a, b)'), r'\min(\mathit{a}, \mathit{b})');
      expect(_tex('MAX(a, b)'), r'\max(\mathit{a}, \mathit{b})');
    });

    test('FLOOR becomes floor brackets', () {
      expect(_tex('FLOOR(x)'), r'\lfloor \mathit{x} \rfloor');
    });

    test('CEILING becomes ceiling brackets', () {
      expect(_tex('CEILING(x)'), r'\lceil \mathit{x} \rceil');
    });

    test('LOG becomes the natural logarithm', () {
      expect(_tex('LOG(x)'), r'\ln(\mathit{x})');
    });

    test('LOG10 becomes a logarithm to base 10', () {
      expect(_tex('LOG10(x)'), r'\log_{10}(\mathit{x})');
    });

    test('SIN, COS and TAN become their trigonometric names', () {
      expect(_tex('SIN(x)'), r'\sin(\mathit{x})');
      expect(_tex('COS(x)'), r'\cos(\mathit{x})');
      expect(_tex('TAN(x)'), r'\tan(\mathit{x})');
    });

    test('IF becomes a cases block with its condition', () {
      expect(
        _tex('IF(a > b, 1, 2)'),
        r'\begin{cases} 1 & \text{if } \mathit{a} > \mathit{b} \\ 2 & \text{otherwise} \end{cases}',
      );
    });

    test('a built-in with the wrong number of arguments does not convert', () {
      expect(expressionToTex('ROUND(1)'), isNull);
    });
  });

  group('project and unknown functions', () {
    test('a function of the given names is set as an operator name', () {
      expect(
        _tex('armor_reduction(armor)', functionNames: _project),
        r'\mathrm{armor\_reduction}(\mathit{armor})',
      );
    });

    test('a function name is matched ignoring case', () {
      expect(
        _tex('Armor_Reduction(1)', functionNames: _project),
        r'\mathrm{armor\_reduction}(1)',
      );
    });

    test('a call to a function nobody knows does not convert', () {
      expect(expressionToTex('mystery(1)'), isNull);
    });
  });

  group('names and literals', () {
    test('a variable is set as one word with its underscores escaped', () {
      expect(_tex('base_damage'), r'\mathit{base\_damage}');
    });

    test('PI becomes pi', () {
      expect(_tex('PI'), r'\pi');
    });

    test('E becomes e', () {
      expect(_tex('E'), 'e');
    });

    test('TRUE becomes the text true', () {
      expect(_tex('TRUE'), r'\text{true}');
    });

    test('a string keeps its quotes as text', () {
      expect(_tex('"strength"'), r'\text{"strength"}');
    });

    test('TeX characters in a string are escaped', () {
      expect(_tex('"50%_#"'), r'\text{"50\%\_\#"}');
    });

    test('a number is written as it is', () {
      expect(_tex('1.5e3'), '1.5e3');
    });
  });

  group('formulas that do not convert', () {
    test('a formula ending in an operator does not convert', () {
      expect(expressionToTex('1 +'), isNull);
    });

    test('an unclosed parenthesis does not convert', () {
      expect(expressionToTex('(1 + 2'), isNull);
    });

    test('two operands without an operator do not convert', () {
      expect(expressionToTex('a b'), isNull);
    });

    test('an unterminated string does not convert', () {
      expect(expressionToTex('"abc'), isNull);
    });

    test('an unknown character does not convert', () {
      expect(expressionToTex('a \$ b'), isNull);
    });

    test('an empty formula does not convert', () {
      expect(expressionToTex('  '), isNull);
    });
  });

  group('reference formulas', () {
    test('a rounded power of a level', () {
      expect(
        _tex('ROUND(100 * level ^ 1.5, 0)'),
        r'\mathrm{round}(100 \cdot {\mathit{level}}^{1.5}, 0)',
      );
    });

    test('a rounded damage with project functions', () {
      expect(
        _tex(
          'ROUND((base_damage + attribute_value("strength") * 0.8) * '
          'crit_multiplier(luck) * (1 - armor_reduction(armor)), 2)',
          functionNames: _project,
        ),
        r'\mathrm{round}((\mathit{base\_damage} + '
        r'\mathrm{attribute\_value}(\text{"strength"}) \cdot 0.8) \cdot '
        r'\mathrm{crit\_multiplier}(\mathit{luck}) \cdot '
        r'(1 - \mathrm{armor\_reduction}(\mathit{armor})), 2)',
      );
    });

    test('a strength check with IF', () {
      expect(
        _tex('IF(attribute == "strength", 12, 5)'),
        r'\begin{cases} 12 & \text{if } \mathit{attribute} = \text{"strength"} \\ 5 & \text{otherwise} \end{cases}',
      );
    });
  });

  group('function definitions', () {
    test('the name is an operator name and the parameters are variables', () {
      expect(
        functionToTex('damage_bonus', ['base', 'bonus_rate'], 'base * 2'),
        r'\mathrm{damage\_bonus}(\mathit{base}, \mathit{bonus\_rate}) = '
        r'\mathit{base} \cdot 2',
      );
    });

    test('a body that does not convert gives no definition', () {
      expect(functionToTex('f', ['a'], 'a +'), isNull);
    });

    test('a name that is not an identifier gives no definition', () {
      expect(functionToTex('my function', ['a'], 'a'), isNull);
    });
  });

  group('catalog names', () {
    test('every catalog function is named, EvalEx and project alike', () {
      const catalog = ExpressionCatalog(
        functions: [
          CatalogFunction(name: 'ROUND'),
          CatalogFunction(
            name: 'armor_reduction',
            category: CatalogFunctionCategory.project,
          ),
        ],
      );

      expect(catalogFunctionNames(catalog), {'ROUND', 'armor_reduction'});
    });

    test('no catalog gives no names', () {
      expect(catalogFunctionNames(null), isEmpty);
    });
  });
}
