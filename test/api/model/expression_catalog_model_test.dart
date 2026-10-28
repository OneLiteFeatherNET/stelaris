import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/api/model/expression_function_model.dart';
import 'package:stelaris/api/model/expression_model.dart';

void main() {
  const json = {
    'evalexVersion': '3.8.0',
    'functions': [
      {
        'name': 'ROUND',
        'category': 'BASIC',
        'parameters': [
          {
            'name': 'value',
            'varArg': false,
            'lazy': false,
            'nonZero': false,
            'nonNegative': false,
          },
          {'name': 'precision', 'varArg': false},
        ],
      },
      {
        'name': 'MAX',
        'category': 'BASIC',
        'parameters': [
          {'name': 'value', 'varArg': true},
        ],
      },
    ],
    'operators': [
      {
        'symbol': '+',
        'kind': 'INFIX',
        'precedence': 20,
        'leftAssociative': true,
      },
    ],
    'constants': [
      {'name': 'PI', 'type': 'NUMBER', 'value': '3.14159'},
    ],
  };

  test('parses the version, functions, operators and constants', () {
    final catalog = ExpressionCatalog.fromJson(json);

    expect(catalog.evalexVersion, '3.8.0');
    expect(catalog.functions.map((f) => f.name), ['ROUND', 'MAX']);
    expect(catalog.operators.single.symbol, '+');
    expect(catalog.operators.single.kind, CatalogOperatorKind.infix);
    expect(catalog.operators.single.precedence, 20);
    expect(catalog.constants.single.value, '3.14159');
  });

  test('reads a function category and its parameters', () {
    final round = ExpressionCatalog.fromJson(json).functions.first;

    expect(round.category, CatalogFunctionCategory.basic);
    expect(round.parameters.map((p) => p.name), ['value', 'precision']);
    expect(round.parameters.first.varArg, isFalse);
  });

  test('reads a vararg parameter as a vararg', () {
    final max = ExpressionCatalog.fromJson(json).functions.last;

    expect(max.parameters.single.varArg, isTrue);
  });

  test('an unknown function category reads as other', () {
    final function = CatalogFunction.fromJson(const {
      'name': 'WEEKDAY',
      'category': 'SOMETHING_NEW',
    });

    expect(function.category, CatalogFunctionCategory.other);
  });

  test('a date category maps to its own value', () {
    final function = CatalogFunction.fromJson(const {
      'name': 'NOW',
      'category': 'DATE_TIME',
    });

    expect(function.category, CatalogFunctionCategory.dateTime);
  });

  test('an unknown operator kind and constant type read as other', () {
    final operator = CatalogOperator.fromJson(const {
      'symbol': '~',
      'kind': 'CIRCUMFIX',
    });
    final constant = CatalogConstant.fromJson(const {
      'name': 'WHO',
      'type': 'COLOR',
      'value': 'red',
    });

    expect(operator.kind, CatalogOperatorKind.other);
    expect(constant.type, CatalogConstantType.other);
  });

  test('a catalog with no lists reads as empty lists', () {
    final catalog = ExpressionCatalog.fromJson(const {
      'evalexVersion': '3.8.0',
    });

    expect(catalog.functions, isEmpty);
    expect(catalog.operators, isEmpty);
    expect(catalog.constants, isEmpty);
  });

  test(
    'reads a project function with its kind, return type and parameter types',
    () {
      final function = CatalogFunction.fromJson(const {
        'name': 'damage_bonus',
        'category': 'PROJECT',
        'description': 'Bonus damage for a hit',
        'kind': 'FORMULA',
        'returnType': 'NUMBER',
        'parameters': [
          {'name': 'base', 'type': 'NUMBER'},
          {'name': 'crit', 'type': 'BOOLEAN'},
        ],
      });

      expect(function.category, CatalogFunctionCategory.project);
      expect(function.description, 'Bonus damage for a hit');
      expect(function.kind, ExpressionFunctionKind.FORMULA);
      expect(function.returnType, ExpressionFunctionReturnType.NUMBER);
      expect(function.parameters.map((p) => p.type), [
        ExpressionVariableType.NUMBER,
        ExpressionVariableType.BOOLEAN,
      ]);
    },
  );

  test('an interface project function reads its kind', () {
    final function = CatalogFunction.fromJson(const {
      'name': 'hit',
      'category': 'PROJECT',
      'kind': 'INTERFACE',
    });

    expect(function.kind, ExpressionFunctionKind.INTERFACE);
    expect(function.description, isNull);
  });

  test('a project function with an unknown kind reads the kind as absent', () {
    final function = CatalogFunction.fromJson(const {
      'name': 'hit',
      'category': 'PROJECT',
      'kind': 'MACRO',
    });

    expect(function.kind, isNull);
  });

  test('a built-in parameter has no type', () {
    final function = CatalogFunction.fromJson(const {
      'name': 'ROUND',
      'category': 'BASIC',
      'parameters': [
        {'name': 'value'},
      ],
    });

    expect(function.parameters.single.type, isNull);
  });
}
