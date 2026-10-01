import 'package:material_ui/material_ui.dart';
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

    Future<List<String>> blurAfter(
      WidgetTester tester, {
      required String currentValue,
      String? typed,
    }) async {
      final reported = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextInputCard(
                  display: 'Test Input',
                  valueUpdate: reported.add,
                  currentValue: currentValue,
                ),
                const TextField(),
              ],
            ),
          ),
        ),
      );

      final field = find.byType(TextFormField);
      if (typed == null) {
        await tester.tap(field);
      } else {
        await tester.enterText(field, typed);
      }
      await tester.tap(find.byType(TextField).last);
      await tester.pumpAndSettle();
      return reported;
    }

    testWidgets('clearing a field reports an empty value', (tester) async {
      expect(
        await blurAfter(tester, currentValue: 'initial', typed: '   '),
        [''],
      );
    });

    testWidgets('an unchanged value is not reported', (tester) async {
      expect(await blurAfter(tester, currentValue: 'same'), isEmpty);
      expect(
        await blurAfter(tester, currentValue: 'same', typed: 'same'),
        isEmpty,
      );
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
  });
}
