import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/edit_card/edit_card.dart';
import 'package:stelaris/feature/base/edit_card/edit_card_grid.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  late List<Object?> changes;

  setUp(() => changes = []);

  Future<void> pumpGrid(WidgetTester tester, EditField field) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: EditCardGrid(
            sections: [
              EditSection(title: 'Section', fields: [field]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byType(EditCard));
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextFormField),
      ),
      text,
    );
    await tester.pump();
  }

  TextEdit material({bool suggests = true}) => TextEdit(
    label: 'Material',
    icon: Icons.category_outlined,
    value: '',
    suggestsMaterials: suggests,
    onChanged: changes.add,
  );

  group('material suggestions', () {
    testWidgets('offers at most five while typing', (tester) async {
      await pumpGrid(tester, material());
      await open(tester);

      await type(tester, 'diamond');

      expect(find.byType(MenuItemButton), findsAtLeastNWidgets(1));
      expect(
        find.byType(MenuItemButton).evaluate().length,
        lessThanOrEqualTo(5),
      );
    });

    testWidgets('enter takes the highlighted one and saves', (tester) async {
      await pumpGrid(tester, material());
      await open(tester);

      await type(tester, 'diamond sword');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(changes, ['minecraft:diamond_sword']);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('free text still saves', (tester) async {
      await pumpGrid(tester, material());
      await open(tester);

      await type(tester, 'mymod:custom_item');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(changes, ['mymod:custom_item']);
    });

    testWidgets('a field without them suggests nothing', (tester) async {
      await pumpGrid(tester, material(suggests: false));
      await open(tester);

      await type(tester, 'diamond');

      expect(find.byType(MenuItemButton), findsNothing);
    });
  });

  group('choices', () {
    ChoiceEdit<String> frame() => ChoiceEdit<String>(
      label: 'Frame',
      icon: Icons.list,
      value: 'task',
      options: const ['task', 'goal', 'challenge'],
      display: (option) => option.toUpperCase(),
      onChanged: changes.add,
    );

    testWidgets('the card shows the option as it reads', (tester) async {
      await pumpGrid(tester, frame());

      expect(find.text('TASK'), findsOneWidget);
    });

    testWidgets('a tap on an option picks it and closes', (tester) async {
      await pumpGrid(tester, frame());
      await open(tester);

      await tester.tap(find.widgetWithText(ListTile, 'CHALLENGE'));
      await tester.pumpAndSettle();

      expect(changes, ['challenge']);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('many options are built lazily, the current one in view', (
      tester,
    ) async {
      final options = [for (var i = 0; i < 500; i++) 'option $i'];
      await pumpGrid(
        tester,
        ChoiceEdit<String>(
          label: 'Parent',
          icon: Icons.list,
          value: 'option 300',
          options: options,
          display: (option) => option,
          onChanged: changes.add,
        ),
      );
      await open(tester);

      expect(find.byType(ListTile).evaluate().length, lessThan(20));
      expect(find.widgetWithText(ListTile, 'option 300'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'option 0'), findsNothing);
    });

    testWidgets('picking the current option changes nothing', (tester) async {
      await pumpGrid(tester, frame());
      await open(tester);

      await tester.tap(find.widgetWithText(ListTile, 'TASK'));
      await tester.pumpAndSettle();

      expect(changes, isEmpty);
    });
  });
}
