import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/base/button/save_button.dart';
import 'package:stelaris/util/constants.dart';

void main() {
  testWidgets('SaveButton without text renders icon only and triggers callback',
          (WidgetTester tester) async {
        var pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SaveButton(
                callback: () {
                  pressed = true;
                },
              ),
            ),
          ),
        );

        // Check that the icon is there
        expect(find.byWidget(saveIcon), findsOneWidget);

        // Since no text is provided, ensure no label is shown
        expect(find.byType(Text), findsNothing);

        // Tap the button
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Verify callback triggered
        expect(pressed, isTrue);
      });

  testWidgets('SaveButton with text renders label and triggers callback',
          (WidgetTester tester) async {
        var pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SaveButton(
                text: 'Save Changes',
                callback: () {
                  pressed = true;
                },
              ),
            ),
          ),
        );

        // Verify the text is shown
        expect(find.text('Save Changes'), findsOneWidget);

        // Verify the icon is present
        expect(find.byWidget(saveIcon), findsOneWidget);

        // Tap the button
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Verify callback triggered
        expect(pressed, isTrue);
      });
}
