import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/expression_model.dart';

void main() {
  final created = DateTime.utc(2026, 10, 1, 8, 30);
  final modified = DateTime.utc(2026, 10, 2, 9, 15);

  final full = ExpressionModel(
    id: 'e1',
    uiName: 'Damage',
    expression: 'base * (1 + bonus)',
    comment: 'Boss room',
    projectId: 'p1',
    creationDate: created,
    modificationDate: modified,
    variables: const [
      ExpressionVariable(
        name: 'base',
        type: ExpressionVariableType.NUMBER,
        testValue: '10',
      ),
      ExpressionVariable(
        name: 'crit',
        type: ExpressionVariableType.BOOLEAN,
        testValue: 'true',
      ),
      ExpressionVariable(name: 'label', type: ExpressionVariableType.STRING),
    ],
  );

  test('a model survives a JSON round trip with its variables', () {
    expect(ExpressionModel.fromJson(full.toJson()), full);
  });

  test('variable types are written as the backend names them', () {
    final json = full.toJson();
    final variables = json['variables'] as List<dynamic>;

    expect(
      [for (final v in variables) (v as Map<String, dynamic>)['type']],
      ['NUMBER', 'BOOLEAN', 'STRING'],
    );
  });

  test('a variable type is read from its backend name', () {
    final variable = ExpressionVariable.fromJson({
      'name': 'flag',
      'type': 'BOOLEAN',
      'testValue': null,
    });

    expect(variable.type, ExpressionVariableType.BOOLEAN);
    expect(variable.testValue, isNull);
  });

  test('a variable without a type is a number', () {
    expect(
      const ExpressionVariable(name: 'x').type,
      ExpressionVariableType.NUMBER,
    );
  });

  test('a model without variables in its JSON has an empty list', () {
    final model = ExpressionModel.fromJson({
      'id': 'e2',
      'uiName': 'Empty',
      'expression': '1 + 1',
      'projectId': 'p1',
    });

    expect(model.variables, isEmpty);
    expect(model.comment, isNull);
  });

  test('a new model has no variables and an empty expression', () {
    final model = const ExpressionModel(uiName: 'New');

    expect(model.variables, isEmpty);
    expect(model.expression, '');
  });

  test('dates are read from the same ISO strings as the other models', () {
    final model = ExpressionModel.fromJson({
      'uiName': 'Dated',
      'creationDate': '2026-10-01T08:30:00Z',
      'modificationDate': '2026-10-02T09:15:00Z',
    });

    expect(model.creationDate, created);
    expect(model.modificationDate, modified);
  });

  test('evaluation results are read from the value and type fields', () {
    final result = ExpressionResult.fromJson({'value': '42', 'type': 'NUMBER'});

    expect(result.value, '42');
    expect(result.type, 'NUMBER');
  });
}
