import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/expression/expression_formula_controller.dart';
import 'package:stelaris/feature/expression/expression_general_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';

import '../../support/pump_in_app.dart';

const _suggestions = ValueKey('expression_suggestions');
const _signature = ValueKey('expression_signature');
const _formulaKey = ValueKey('expression_formula_text');
final _formula = find.byKey(_formulaKey);
final _formulaEditable = find.descendant(
  of: _formula,
  matching: find.byType(EditableText),
);

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
  // A wide surface: the functions sidebar sits beside the editor.
  tester.view
    ..physicalSize = const Size(1400, 1600)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
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
  await tester.tap(_formula);
  await tester.pumpAndSettle();
  await tester.enterText(_formula, text);
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

    final editable = tester.state<EditableTextState>(_formulaEditable);
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

  testWidgets(
    'clicking a function in the sidebar inserts its call at the caret',
    (tester) async {
      final store = await _pump(tester, catalog: _catalog);
      await _type(tester, 'a');
      await tester.enterText(
        find.byKey(const ValueKey('expression_function_search')),
        'round',
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const ValueKey('expression_function_ROUND')),
      );
      await tester.tap(find.byKey(const ValueKey('expression_function_ROUND')));
      await tester.pumpAndSettle();

      expect(store.state.selectedExpression?.expression, 'aROUND(');
      expect(store.state.unsavedChanges, NavigationEntry.expression);
    },
  );

  testWidgets('clicking a constant in the sidebar inserts its name', (
    tester,
  ) async {
    final store = await _pump(tester, catalog: _catalog);
    await _type(tester, '2 * ');
    await tester.enterText(
      find.byKey(const ValueKey('expression_function_search')),
      'pi',
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('expression_constant_PI')),
    );
    await tester.tap(find.byKey(const ValueKey('expression_constant_PI')));
    await tester.pumpAndSettle();

    expect(store.state.selectedExpression?.expression, '2 * PI');
  });

  testWidgets('the sidebar search hides functions whose name does not match', (
    tester,
  ) async {
    await _pump(tester, catalog: _catalog);

    await tester.enterText(
      find.byKey(const ValueKey('expression_function_search')),
      'PI',
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('expression_function_ROUND')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('expression_constant_PI')),
      findsOneWidget,
    );
  });

  testWidgets('a group header expands its functions when no search is active', (
    tester,
  ) async {
    await _pump(tester, catalog: _catalog);
    final entry = find.byKey(const ValueKey('expression_function_ROUND'));
    expect(entry, findsNothing);

    await tester.tap(find.text('Basic'));
    await tester.pumpAndSettle();

    expect(entry, findsOneWidget);
  });

  testWidgets(
    'without the catalog the sidebar says the functions are unavailable',
    (tester) async {
      await _pump(tester);

      final l10n = AppLocalizations.of(
        tester.element(find.byType(ExpressionGeneralPage)),
      )!;
      expect(find.text(l10n.expression_functions_unavailable), findsOneWidget);
    },
  );

  testWidgets('the + button inserts the operator with spaces at the caret', (
    tester,
  ) async {
    final store = await _pump(tester, catalog: _catalog);
    await _type(tester, 'a');

    await tester.ensureVisible(
      find.byKey(const ValueKey('expression_operator_+')),
    );
    await tester.tap(find.byKey(const ValueKey('expression_operator_+')));
    await tester.pumpAndSettle();

    expect(store.state.selectedExpression?.expression, 'a + ');
  });

  testWidgets('without the catalog the toolbar offers the fixed operators', (
    tester,
  ) async {
    await _pump(tester);

    for (final symbol in [
      '+',
      '-',
      '*',
      '/',
      '^',
      '%',
      '==',
      '!=',
      '<=',
      '>=',
      '&&',
      '||',
      '!',
    ]) {
      expect(
        find.byKey(ValueKey('expression_operator_$symbol')),
        findsOneWidget,
        reason: 'operator $symbol',
      );
    }
  });

  testWidgets(
    'a function and a variable get distinct styles in the highlighting',
    (tester) async {
      await _pump(tester, catalog: _catalog);
      await _type(tester, 'ROUND(radius, 2)');

      final context = tester.element(_formulaEditable);
      final controller =
          tester.state<EditableTextState>(_formulaEditable).widget.controller
              as ExpressionFormulaController;
      final root = controller.buildTextSpan(
        context: context,
        withComposing: false,
        style: const TextStyle(),
      );
      final spans = {
        for (final span in root.children!.cast<TextSpan>())
          span.text!: span.style,
      };
      final colors = Theme.of(context).colorScheme;

      expect(spans['ROUND']?.color, colors.primary);
      expect(spans['radius']?.color, colors.secondary);
      expect(spans['ROUND']?.color, isNot(spans['radius']?.color));
    },
  );

  testWidgets('a store text change with the same id replaces the field text', (
    tester,
  ) async {
    final store = await _pump(tester, expression: _expression(text: 'a'));

    store.dispatch(SelectExpressionAction(_expression(text: 'radius * 2')));
    await tester.pumpAndSettle();

    final editable = tester.state<EditableTextState>(_formulaEditable);
    expect(editable.widget.controller.text, 'radius * 2');
  });

  testWidgets('a shorter store text keeps the caret inside the new text', (
    tester,
  ) async {
    final store = await _pump(tester, expression: _expression(text: ''));
    await _type(tester, 'radius * 2');

    store.dispatch(SelectExpressionAction(_expression(text: 'r')));
    await tester.pumpAndSettle();

    final editable = tester.state<EditableTextState>(_formulaEditable);
    expect(editable.widget.controller.selection.baseOffset, 1);
  });
}
