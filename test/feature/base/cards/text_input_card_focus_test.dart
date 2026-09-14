import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';

void main() {
  group('TextInputCard Focus and Traversal Tests', () {
    testWidgets(
      'navigates in numeric focus order inside FocusTraversalGroup',
      (WidgetTester tester) async {
        final List<String> submittedValues = [];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FocusScope(
                child: FocusTraversalGroup(
                  policy: OrderedTraversalPolicy(),
                  child: Column(
                    children: [
                      TextInputCard(
                        key: const ValueKey('card_second'),
                        display: 'Second Field',
                        currentValue: 'val2',
                        valueUpdate: (val) => submittedValues.add('second:$val'),
                        focusOrder: const NumericFocusOrder(2),
                      ),
                      TextInputCard(
                        key: const ValueKey('card_first'),
                        display: 'First Field',
                        currentValue: 'val1',
                        valueUpdate: (val) => submittedValues.add('first:$val'),
                        focusOrder: const NumericFocusOrder(1),
                      ),
                      TextInputCard(
                        key: const ValueKey('card_third'),
                        display: 'Third Field',
                        currentValue: 'val3',
                        valueUpdate: (val) => submittedValues.add('third:$val'),
                        focusOrder: const NumericFocusOrder(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        final firstFieldFinder = find.descendant(
          of: find.byKey(const ValueKey('card_first')),
          matching: find.byType(EditableText),
        );
        final secondFieldFinder = find.descendant(
          of: find.byKey(const ValueKey('card_second')),
          matching: find.byType(EditableText),
        );
        final thirdFieldFinder = find.descendant(
          of: find.byKey(const ValueKey('card_third')),
          matching: find.byType(EditableText),
        );

        // Tap the first field (NumericFocusOrder 1)
        await tester.tap(firstFieldFinder);
        await tester.pump();

        final EditableText firstEditable = tester.widget(firstFieldFinder);
        final EditableText secondEditable = tester.widget(secondFieldFinder);
        final EditableText thirdEditable = tester.widget(thirdFieldFinder);

        expect(firstEditable.focusNode.hasFocus, isTrue);
        expect(secondEditable.focusNode.hasFocus, isFalse);
        expect(thirdEditable.focusNode.hasFocus, isFalse);

        // Press Tab key -> Should advance to NumericFocusOrder 2 (card_second)
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(firstEditable.focusNode.hasFocus, isFalse);
        expect(secondEditable.focusNode.hasFocus, isTrue);
        expect(thirdEditable.focusNode.hasFocus, isFalse);

        // Press Tab key again -> Should advance to NumericFocusOrder 3 (card_third)
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(firstEditable.focusNode.hasFocus, isFalse);
        expect(secondEditable.focusNode.hasFocus, isFalse);
        expect(thirdEditable.focusNode.hasFocus, isTrue);

        // Press Tab key on last field -> Should wrap around to first field within FocusScope
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(firstEditable.focusNode.hasFocus, isTrue);
        expect(secondEditable.focusNode.hasFocus, isFalse);
        expect(thirdEditable.focusNode.hasFocus, isFalse);
      },
    );

    testWidgets(
      'FocusScope prevents focus from escaping to outside buttons when tabbing',
      (WidgetTester tester) async {
        final outsideFocusNode = FocusNode();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  focusNode: outsideFocusNode,
                  icon: const Icon(Icons.menu),
                  onPressed: () {},
                ),
              ),
              body: FocusScope(
                child: FocusTraversalGroup(
                  policy: OrderedTraversalPolicy(),
                  child: Column(
                    children: [
                      TextInputCard(
                        key: const ValueKey('input1'),
                        display: 'Input 1',
                        currentValue: '1',
                        valueUpdate: (_) {},
                        focusOrder: const NumericFocusOrder(1),
                      ),
                      TextInputCard(
                        key: const ValueKey('input2'),
                        display: 'Input 2',
                        currentValue: '2',
                        valueUpdate: (_) {},
                        focusOrder: const NumericFocusOrder(2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        final input1Finder = find.descendant(
          of: find.byKey(const ValueKey('input1')),
          matching: find.byType(EditableText),
        );
        final input2Finder = find.descendant(
          of: find.byKey(const ValueKey('input2')),
          matching: find.byType(EditableText),
        );

        await tester.tap(input1Finder);
        await tester.pump();

        final EditableText input1 = tester.widget(input1Finder);
        final EditableText input2 = tester.widget(input2Finder);

        expect(input1.focusNode.hasFocus, isTrue);

        // Tab from input1 -> input2
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(input2.focusNode.hasFocus, isTrue);
        expect(outsideFocusNode.hasFocus, isFalse);

        // Tab from input2 -> wraps back to input1, NOT outsideFocusNode (appBar)
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        expect(input1.focusNode.hasFocus, isTrue);
        expect(outsideFocusNode.hasFocus, isFalse);

        outsideFocusNode.dispose();
      },
    );

    testWidgets(
      'calls valueUpdate when submitting via Enter key',
      (WidgetTester tester) async {
        String updatedValue = '';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextInputCard(
                display: 'Test Input',
                currentValue: 'initial',
                valueUpdate: (val) => updatedValue = val,
              ),
            ),
          ),
        );

        final fieldFinder = find.byType(TextFormField);
        await tester.enterText(fieldFinder, 'new-submitted-value');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(updatedValue, equals('new-submitted-value'));
      },
    );
  });
}
