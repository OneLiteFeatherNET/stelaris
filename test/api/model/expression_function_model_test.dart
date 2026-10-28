import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/expression_function_model.dart';
import 'package:stelaris/api/model/expression_model.dart';

void main() {
  const json = {
    'id': 'f1',
    'projectId': 'p1',
    'uiName': 'Damage bonus',
    'name': 'damage_bonus',
    'kind': 'FORMULA',
    'returnType': 'NUMBER',
    'parameters': [
      {'name': 'base', 'type': 'NUMBER', 'testValue': '2'},
      {'name': 'crit', 'type': 'BOOLEAN'},
    ],
    'body': 'base * 2',
    'comment': 'Doubles the base',
    'creationDate': '2026-01-02T03:04:05.000Z',
    'modificationDate': '2026-01-03T03:04:05.000Z',
  };

  test('reads every field of the backend JSON', () {
    final function = ExpressionFunctionModel.fromJson(json);

    expect(function.id, 'f1');
    expect(function.projectId, 'p1');
    expect(function.uiName, 'Damage bonus');
    expect(function.name, 'damage_bonus');
    expect(function.kind, ExpressionFunctionKind.FORMULA);
    expect(function.returnType, ExpressionFunctionReturnType.NUMBER);
    expect(function.body, 'base * 2');
    expect(function.comment, 'Doubles the base');
    expect(function.parameters.map((p) => p.name), ['base', 'crit']);
    expect(function.parameters.first.testValue, '2');
    expect(function.parameters.last.type, ExpressionVariableType.BOOLEAN);
  });

  test('reads an interface kind from its wire name', () {
    final function = ExpressionFunctionModel.fromJson({
      ...json,
      'kind': 'INTERFACE',
    });

    expect(function.kind, ExpressionFunctionKind.INTERFACE);
  });

  test('writes the kind, return type and parameters by their wire names', () {
    final written = ExpressionFunctionModel.fromJson(json).toJson();

    expect(written['kind'], 'FORMULA');
    expect(written['returnType'], 'NUMBER');
    expect(written['parameters'], [
      {'name': 'base', 'type': 'NUMBER', 'testValue': '2'},
      {'name': 'crit', 'type': 'BOOLEAN', 'testValue': null},
    ]);
  });

  test('the written JSON can be encoded, parameters included', () {
    final function = ExpressionFunctionModel.fromJson(json);

    expect(() => jsonEncode(function.toJson()), returnsNormally);
  });

  test('a model read back from its JSON equals the original', () {
    final function = ExpressionFunctionModel.fromJson(json);

    expect(ExpressionFunctionModel.fromJson(function.toJson()), function);
  });

  test('a new function defaults to a formula that returns a number', () {
    const function = ExpressionFunctionModel(uiName: 'Hit');

    expect(function.name, '');
    expect(function.kind, ExpressionFunctionKind.FORMULA);
    expect(function.returnType, ExpressionFunctionReturnType.NUMBER);
    expect(function.parameters, isEmpty);
  });

  test('reads the interface source, type name and language', () {
    final generated = ExpressionFunctionInterface.fromJson(const {
      'language': 'java',
      'typeName': 'ProjectFunctions',
      'source': 'public interface ProjectFunctions {}',
    });

    expect(generated.language, 'java');
    expect(generated.typeName, 'ProjectFunctions');
    expect(generated.source, 'public interface ProjectFunctions {}');
  });

  group('functionIdentifierFor', () {
    test('keeps a name that already is an identifier', () {
      expect(functionIdentifierFor('damage_bonus'), 'damage_bonus');
    });

    test('replaces the characters an identifier cannot hold', () {
      expect(functionIdentifierFor('Damage bonus!'), 'Damage_bonus_');
    });

    test('puts an underscore in front of a leading digit', () {
      expect(functionIdentifierFor('3d hit'), '_3d_hit');
    });

    test('falls back to function for a blank name', () {
      expect(functionIdentifierFor('   '), 'function');
    });
  });
}
