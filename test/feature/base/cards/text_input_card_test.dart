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

    testWidgets('applies input formatters when provided', (
      WidgetTester tester,
    ) async {
      final formatters = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(5),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInputCard(
              display: 'Formatted Input',
              valueUpdate: valueUpdateCallback,
              currentValue: '',
              formatter: formatters,
            ),
          ),
        ),
      );
      final textFormFieldFinder = find.descendant(
        of: find.byType(TextInputCard),
        matching: find.byType(TextFormField),
      );
      expect(
        textFormFieldFinder,
        findsOneWidget,
        reason: 'TextFormField not found within TextInputCard',
      );

      await tester.enterText(textFormFieldFinder, 'abc123def');
      await tester.pump();

      expect(
        testValue,
        equals('123'),
        reason:
            'DigitsOnly formatter should have removed non-digit characters.',
      );

      await tester.enterText(textFormFieldFinder, '');
      await tester.pump();
      testValue = '';

      await tester.enterText(textFormFieldFinder, '1234567890');
      await tester.pump();

      expect(
        testValue,
        equals('12345'),
        reason: 'LengthLimiting formatter should have capped the length at 5.',
      );

      expect(
        find.text('12345'),
        findsOneWidget,
        reason:
            'TextFormField should display the formatted value limited to 5 digits.',
      );
    });

    testWidgets('applies form validation when provided', (
      WidgetTester tester,
    ) async {
      String? validationFunction(String? value) {
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        return null;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInputCard(
              display: 'Validated Input',
              valueUpdate: valueUpdateCallback,
              currentValue: '',
              formValidator: (value) => validationFunction(value),
            ),
          ),
        ),
      );

      final textField = find.byType(TextFormField);
      final textFormField = tester.widget<TextFormField>(textField);

      expect(textFormField.validator, equals(validationFunction));
      expect(
        textFormField.autovalidateMode,
        equals(AutovalidateMode.onUserInteraction),
      );
    });

    testWidgets('shows validation error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInputCard(
              display: 'Validated Input',
              valueUpdate: valueUpdateCallback,
              currentValue: '',
              formValidator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please provide an input';
                }
                return null;
              },
            ),
          ),
        ),
      );

      final textField = find.byType(TextFormField);

      await tester.enterText(textField, 'test');
      await tester.enterText(textField, '');
      await tester.pump();

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('respects maxLength constraint', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextInputCard(
              display: 'Limited Input',
              valueUpdate: valueUpdateCallback,
              currentValue: '',
              maxLength: 5,
            ),
          ),
        ),
      );

      final textFieldFinder = find.byType(TextFormField);
      await tester.enterText(textFieldFinder, '123456');
      await tester.pump();

      expect(testValue.length, lessThanOrEqualTo(5));
      expect(testValue, '12345');
    });

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
