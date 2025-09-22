import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/base/base_card.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';

void main() {
  group('TextInputCard Widget Tests', () {
    late String testValue;
    late void Function(String) valueUpdateCallback;

    setUp(() {
      testValue = '';
      valueUpdateCallback = (String value) {
        testValue = value;
      };
    });

    testWidgets('renders with basic required properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInputCard(
              display: 'Test Input',
              valueUpdate: valueUpdateCallback,
              currentValue: 'initial value',
            ),
          ),
        ),
      );

      expect(find.text('Test Input'), findsOneWidget);
      expect(find.text('initial value'), findsOneWidget);
    });

    testWidgets('displays hint text when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInputCard(
              display: 'Test Input',
              valueUpdate: valueUpdateCallback,
              currentValue: '',
              hintText: 'Enter something...',
            ),
          ),
        ),
      );

      expect(find.text('Enter something...'), findsOneWidget);
    });

    testWidgets('calls valueUpdate when focus is lost with non-empty value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextInputCard(
                  display: 'Test Input',
                  valueUpdate: valueUpdateCallback,
                  currentValue: '',
                ),
                const TextField(),
              ],
            ),
          ),
        ),
      );

      final textField = find.byType(TextFormField);
      await tester.enterText(textField, 'test value');

      await tester.tap(find.byType(TextField).last);
      await tester.pumpAndSettle();

      expect(testValue, equals('test value'));
    });

    testWidgets(
      'does not call valueUpdate when focus is lost with empty value',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextInputCard(
                    display: 'Test Input',
                    valueUpdate: valueUpdateCallback,
                    currentValue: 'initial',
                  ),
                  const TextField(),
                ],
              ),
            ),
          ),
        );

        final textField = find.byType(TextFormField);
        await tester.enterText(textField, '   ');

        await tester.tap(find.byType(TextField).last);
        await tester.pumpAndSettle();

        expect(testValue, equals(''));
      },
    );

    testWidgets('displays tooltip message through BaseCard', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInputCard(
              display: 'Input with Tooltip',
              valueUpdate: valueUpdateCallback,
              currentValue: '',
              tooltipMessage: 'This is a helpful tooltip',
            ),
          ),
        ),
      );

      final baseCard = find.byType(BaseCard);
      final baseCardWidget = tester.widget<BaseCard>(baseCard);

      expect(baseCardWidget.message, equals('This is a helpful tooltip'));
    });

    testWidgets('handles focus changes correctly', (WidgetTester tester) async {
      bool focusChanged = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextInputCard(
                  display: 'Focus Test',
                  valueUpdate: (value) {
                    focusChanged = true;
                    valueUpdateCallback(value);
                  },
                  currentValue: '',
                ),
                const TextField(),
              ],
            ),
          ),
        ),
      );

      final textField = find.byType(TextFormField);

      await tester.tap(textField);
      await tester.pump();

      await tester.enterText(textField, 'focus test');

      await tester.tap(find.byType(TextField).last);
      await tester.pumpAndSettle();

      expect(focusChanged, isTrue);
      expect(testValue, equals('focus test'));
    });
  });
}
