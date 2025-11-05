import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/util/formatter/min_value_formatter.dart';

void main() {
  testWidgets('TextField with MinValueFormatter behaves correctly',
          (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(
                controller: controller,
                inputFormatters: [MinValueFormatter(1)],
              ),
            ),
          ),
        );

        // Enter "05"
        await tester.enterText(find.byType(TextField), '05');
        expect(controller.text, '5');

        // Enter "0"
        await tester.enterText(find.byType(TextField), '0');
        expect(controller.text, '1'); // snapped to min

        // Enter "21"
        await tester.enterText(find.byType(TextField), '21');
        expect(controller.text, '21');
      });
}
