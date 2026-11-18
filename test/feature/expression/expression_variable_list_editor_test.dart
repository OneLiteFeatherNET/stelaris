import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/expression/expression_variable_list_editor.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';
import 'package:stelaris_models/stelaris_models.dart';

const _radius = ExpressionVariable(name: 'radius', testValue: '2');

final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

/// Pumps an editor over [variables] and returns the lists it reported.
Future<List<List<ExpressionVariable>>> _pump(
  WidgetTester tester,
  List<ExpressionVariable> variables, {
  bool parameter = false,
  List<String> problems = const [],
}) async {
  final changes = <List<ExpressionVariable>>[];
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ExpressionVariableListEditor(
          variables: variables,
          onChanged: changes.add,
          emptyHeader: 'empty',
          emptySubheader: 'empty sub',
          deleteTitle: 'Delete it',
          parameter: parameter,
          problems: problems,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return changes;
}

final _dialogField = find
    .descendant(of: find.byType(Dialog), matching: find.byType(TextFormField))
    .first;

Future<void> _submit(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(Dialog), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

List<String> _names(List<ExpressionVariable> variables) => [
  for (final variable in variables) variable.name,
];

void main() {
  group('variable list editor', () {
    testWidgets('adding reports the list with the new variable', (
      tester,
    ) async {
      final changes = await _pump(tester, [_radius]);

      await tester.tap(find.text(l10n.button_add));
      await tester.pumpAndSettle();
      await tester.enterText(_dialogField, 'height');
      await _submit(tester, l10n.button_add);

      expect(changes, hasLength(1));
      expect(_names(changes.single), ['radius', 'height']);
    });

    testWidgets('editing keeps the order and the other entries', (
      tester,
    ) async {
      const a = ExpressionVariable(name: 'a');
      const c = ExpressionVariable(name: 'c');
      final changes = await _pump(tester, [
        a,
        const ExpressionVariable(name: 'b'),
        c,
      ]);

      await tester.tap(find.text('b'));
      await tester.pumpAndSettle();
      await tester.enterText(_dialogField, 'bb');
      await _submit(tester, l10n.button_save);

      expect(changes, hasLength(1));
      expect(_names(changes.single), ['a', 'bb', 'c']);
      expect(changes.single.first, a);
      expect(changes.single.last, c);
    });

    testWidgets('an edited variable may keep its own name', (tester) async {
      final changes = await _pump(tester, [_radius]);

      await tester.tap(find.text('radius'));
      await tester.pumpAndSettle();
      await _submit(tester, l10n.button_save);

      expect(
        find.text(l10n.expression_variable_name_duplicate('radius')),
        findsNothing,
      );
      expect(changes, hasLength(1));
      expect(changes.single, [_radius]);
    });

    testWidgets('a dismissed dialog reports nothing', (tester) async {
      final changes = await _pump(tester, [_radius]);

      await tester.tap(find.text(l10n.button_add));
      await tester.pumpAndSettle();
      await _submit(tester, l10n.button_cancel);

      expect(find.byType(Dialog), findsNothing);
      expect(changes, isEmpty);
    });

    testWidgets('deleting asks first', (tester) async {
      final changes = await _pump(tester, [_radius]);

      await tester.tap(find.byTooltip(l10n.tooltip_delete));
      await tester.pumpAndSettle();
      expect(find.text('Delete it'), findsOneWidget);
      await _submit(tester, l10n.button_cancel);
      expect(changes, isEmpty);

      await tester.tap(find.byTooltip(l10n.tooltip_delete));
      await tester.pumpAndSettle();
      await _submit(tester, l10n.tooltip_delete);

      expect(changes, [<ExpressionVariable>[]]);
    });

    testWidgets('shows the problems and the empty state', (tester) async {
      await _pump(tester, [], problems: ['bad']);

      expect(find.text('bad'), findsOneWidget);
      expect(find.text('empty'), findsOneWidget);
      expect(find.text('empty sub'), findsOneWidget);
    });

    testWidgets('parameter mode words the dialog for a parameter', (
      tester,
    ) async {
      await _pump(tester, [], parameter: true);

      await tester.tap(find.text(l10n.button_add));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.expression_function_parameter_add_title),
        findsOneWidget,
      );
    });
  });
}
