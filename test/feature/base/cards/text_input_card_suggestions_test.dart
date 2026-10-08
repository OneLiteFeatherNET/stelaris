import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';

void main() {
  group('TextInputCard material suggestions', () {
    late List<String> updates;

    setUp(() => updates = []);

    Future<void> pumpCard(
      WidgetTester tester, {
      bool suggestsMaterials = true,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInputCard(
              display: 'Material',
              currentValue: '',
              valueUpdate: updates.add,
              suggestsMaterials: suggestsMaterials,
            ),
          ),
        ),
      );
    }

    Future<void> type(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(TextFormField), text);
      await tester.pump();
    }

    testWidgets('offers at most five suggestions while typing', (tester) async {
      await pumpCard(tester);

      await type(tester, 'diamond');

      expect(find.byType(MenuItemButton), findsAtLeastNWidgets(1));
      expect(find.byType(MenuItemButton).evaluate().length, lessThanOrEqualTo(5));
    });

    testWidgets('saves the key of the selected suggestion', (tester) async {
      await pumpCard(tester);

      await type(tester, 'diamond sword');
      await tester.tap(find.text('Diamond Sword'));
      // The menu item reports a press after the frame it was tapped in.
      await tester.pumpAndSettle();

      expect(updates, ['minecraft:diamond_sword']);
      expect(find.text('minecraft:diamond_sword'), findsOneWidget);
    });

    testWidgets('saves the highlighted suggestion on enter', (tester) async {
      await pumpCard(tester);

      await type(tester, 'diamond sword');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Enter also drops focus, which submits again: the card's parent drops
      // the repeat because the value no longer changes.
      expect(updates, isNotEmpty);
      expect(updates, everyElement('minecraft:diamond_sword'));
    });

    testWidgets('still saves free text when focus is lost', (tester) async {
      await pumpCard(tester);

      await tester.tap(find.byType(TextFormField));
      await type(tester, 'mymod:custom_item');
      FocusManager.instance.primaryFocus!.unfocus();
      await tester.pump();

      expect(updates, ['mymod:custom_item']);
    });

    testWidgets('suggests nothing unless opted in', (tester) async {
      await pumpCard(tester, suggestsMaterials: false);

      await type(tester, 'diamond');

      expect(find.byType(MenuItemButton), findsNothing);
    });
  });
}
