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

    testWidgets(
      'an option is centered in its row with the compact desktop density',
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      (tester) async {
        await pumpGrid(tester, frame());
        await open(tester);

        final row = tester.getRect(find.widgetWithText(ListTile, 'GOAL'));
        final text = tester.getRect(find.text('GOAL'));

        expect(text.center.dy, row.center.dy);
      },
    );

    testWidgets('picking the current option changes nothing', (tester) async {
      await pumpGrid(tester, frame());
      await open(tester);

      await tester.tap(find.widgetWithText(ListTile, 'TASK'));
      await tester.pumpAndSettle();

      expect(changes, isEmpty);
    });
  });

  group('choice search', () {
    ChoiceEdit<String> parents(int count, {String value = 'none'}) =>
        ChoiceEdit<String>(
          label: 'Parent',
          icon: Icons.list,
          value: value,
          options: ['none', for (var i = 1; i < count; i++) 'Advancement $i'],
          display: (option) => option,
          onChanged: changes.add,
        );

    Future<void> search(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(SearchBar), text);
      await tester.pump();
    }

    testWidgets('is offered once the options scroll', (tester) async {
      await pumpGrid(tester, parents(8));
      await open(tester);
      expect(find.byType(SearchBar), findsNothing);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await pumpGrid(tester, parents(9));
      await open(tester);
      expect(find.byType(SearchBar), findsOneWidget);
      expect(find.text('Search Parent'), findsOneWidget);
    });

    testWidgets('narrows the options to the ones matching every word', (
      tester,
    ) async {
      await pumpGrid(tester, parents(30));
      await open(tester);

      await search(tester, 'advancement 2');

      expect(find.widgetWithText(ListTile, 'Advancement 2'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Advancement 21'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Advancement 3'), findsNothing);
      expect(find.widgetWithText(ListTile, 'none'), findsNothing);
    });

    testWidgets('keeps the height of the list while narrowing', (tester) async {
      await pumpGrid(tester, parents(30));
      await open(tester);
      final before = tester.getSize(find.byType(Dialog)).height;

      await search(tester, 'advancement 29');

      expect(tester.getSize(find.byType(Dialog)).height, before);
    });

    testWidgets('says so when nothing matches', (tester) async {
      await pumpGrid(tester, parents(30));
      await open(tester);

      await search(tester, 'zzz');

      expect(find.byType(ListTile), findsNothing);
      expect(find.text('No matches'), findsOneWidget);
    });

    testWidgets('a tap on a found option picks it', (tester) async {
      await pumpGrid(tester, parents(30));
      await open(tester);

      await search(tester, '27');
      await tester.tap(find.widgetWithText(ListTile, 'Advancement 27'));
      await tester.pumpAndSettle();

      expect(changes, ['Advancement 27']);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('enter picks the first match', (tester) async {
      await pumpGrid(tester, parents(30));
      await open(tester);

      await search(tester, 'advancement 1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(changes, ['Advancement 1']);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('clearing the search shows all options again', (tester) async {
      await pumpGrid(tester, parents(30));
      await open(tester);
      await search(tester, 'zzz');

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pump();

      expect(find.widgetWithText(ListTile, 'none'), findsOneWidget);
      expect(find.byTooltip('Clear search'), findsNothing);
    });
  });
}
