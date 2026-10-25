import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/expression/expression_general_page.dart';

import '../../support/pump_in_app.dart';

const _suggestions = ValueKey('expression_suggestions');
const _signature = ValueKey('expression_signature');

const _catalog = ExpressionCatalog(
  functions: [
    CatalogFunction(
      name: 'ROUND',
      category: CatalogFunctionCategory.basic,
      parameters: [
        CatalogParameter(name: 'value'),
        CatalogParameter(name: 'precision'),
      ],
    ),
  ],
  constants: [CatalogConstant(name: 'PI', value: '3.14159')],
);

ExpressionModel _expression({
  String text = '',
  List<ExpressionVariable> variables = const [
    ExpressionVariable(name: 'radius'),
    ExpressionVariable(name: 'rate', type: ExpressionVariableType.BOOLEAN),
    ExpressionVariable(name: 'height'),
  ],
}) => ExpressionModel(
  uiName: 'Damage',
  id: 'e1',
  expression: text,
  variables: variables,
);

Future<Store<AppState>> _pump(
  WidgetTester tester, {
  ExpressionModel? expression,
  ExpressionCatalog? catalog,
}) async {
  final store = Store<AppState>(
    initialState: AppState(
      selectedExpression: expression ?? _expression(),
      expressionCatalog: catalog,
    ),
  );
  await pumpInApp(tester, store, const ExpressionGeneralPage());
  return store;
}

/// Taps the formula field, types [text] and leaves the caret at its end.
Future<void> _type(WidgetTester tester, String text) async {
  await tester.tap(find.byType(TextField));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), text);
  await tester.pumpAndSettle();
}

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('typing the formula stages it in the store as unsaved', (
    tester,
  ) async {
    final store = await _pump(tester, expression: _expression(text: 'a * 2'));

    await _type(tester, 'a * 2 + sqrt(b)');

    expect(store.state.selectedExpression?.expression, 'a * 2 + sqrt(b)');
    expect(store.state.unsavedChanges, NavigationEntry.expression);
  });

  testWidgets('typing a prefix shows the declared variables that match it', (
    tester,
  ) async {
    await _pump(tester);

    await _type(tester, 'r');

    expect(
      find.descendant(
        of: find.byKey(_suggestions),
        matching: find.text('radius'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(_suggestions),
        matching: find.text('rate'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(_suggestions),
        matching: find.text('height'),
      ),
      findsNothing,
    );
  });

  testWidgets(
    'Enter accepts the highlighted suggestion and completes the name',
    (tester) async {
      final store = await _pump(tester);
      await _type(tester, 'ra');

      await _key(tester, LogicalKeyboardKey.enter);

      expect(store.state.selectedExpression?.expression, 'radius');
    },
  );

  testWidgets('Escape closes the suggestion list', (tester) async {
    await _pump(tester);
    await _type(tester, 'ra');

    await _key(tester, LogicalKeyboardKey.escape);

    expect(find.byKey(_suggestions), findsNothing);
  });

  testWidgets('arrow down then Enter picks the second match', (tester) async {
    final store = await _pump(tester);
    await _type(tester, 'ra');

    await _key(tester, LogicalKeyboardKey.arrowDown);
    await _key(tester, LogicalKeyboardKey.enter);

    expect(store.state.selectedExpression?.expression, 'rate');
  });

  testWidgets('tapping a suggestion completes the name', (tester) async {
    final store = await _pump(tester);
    await _type(tester, 'he');

    await tester.tap(
      find.descendant(
        of: find.byKey(_suggestions),
        matching: find.text('height'),
      ),
    );
    await tester.pumpAndSettle();

    expect(store.state.selectedExpression?.expression, 'height');
  });

  testWidgets('no suggestion list appears without declared variables', (
    tester,
  ) async {
    await _pump(tester, expression: _expression(variables: const []));

    await _type(tester, 'ra');

    expect(find.byKey(_suggestions), findsNothing);
  });

  testWidgets('tapping a variable chip inserts its name at the caret', (
    tester,
  ) async {
    final store = await _pump(tester);
    await _type(tester, 'ab');
    await _key(tester, LogicalKeyboardKey.arrowLeft);

    await tester.tap(find.widgetWithText(ActionChip, 'radius'));
    await tester.pumpAndSettle();

    expect(store.state.selectedExpression?.expression, 'aradiusb');
  });

  testWidgets('inserting a chip keeps the focus in the formula field', (
    tester,
  ) async {
    await _pump(tester);
    await _type(tester, 'a');

    await tester.tap(find.widgetWithText(ActionChip, 'height'));
    await tester.pumpAndSettle();

    final editable = tester.state<EditableTextState>(find.byType(EditableText));
    expect(editable.widget.focusNode.hasFocus, isTrue);
  });

  testWidgets(
    'typing a function prefix suggests the function with its signature',
    (tester) async {
      await _pump(tester, catalog: _catalog);

      await _type(tester, 'ro');

      expect(
        find.descendant(
          of: find.byKey(_suggestions),
          matching: find.text('ROUND(value, precision)'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Enter on a function stages its name with an opening parenthesis',
    (tester) async {
      final store = await _pump(tester, catalog: _catalog);
      await _type(tester, 'ro');

      await _key(tester, LogicalKeyboardKey.enter);

      expect(store.state.selectedExpression?.expression, 'ROUND(');
    },
  );

  testWidgets('the signature highlights the parameter after the comma', (
    tester,
  ) async {
    await _pump(tester, catalog: _catalog);

    await _type(tester, 'ROUND(a, ');

    final signature = tester.widget<Text>(
      find.descendant(of: find.byKey(_signature), matching: find.byType(Text)),
    );
    final root = signature.textSpan! as TextSpan;
    final bold = [
      for (final span in root.children!.cast<TextSpan>())
        if (span.style?.fontWeight == FontWeight.bold) span.text,
    ];
    expect(root.toPlainText(), 'ROUND(value, precision)');
    expect(bold, ['precision']);
  });

  testWidgets('without the catalog a function prefix suggests nothing', (
    tester,
  ) async {
    await _pump(tester);

    await _type(tester, 'ro');

    expect(find.byKey(_suggestions), findsNothing);
  });
}
