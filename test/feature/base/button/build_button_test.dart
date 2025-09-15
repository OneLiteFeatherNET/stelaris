import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/base/button/build_button.dart';

void main() {
  testWidgets('BuildButton opens endDrawer on tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          endDrawer: Drawer(
            child: Text('End Drawer Content'),
          ),
          body: BuildButton(),
        ),
      ),
    );

    // Verify button is rendered
    expect(find.byIcon(Icons.build_outlined), findsOneWidget);

    // Initially, drawer should be closed
    expect(find.text('End Drawer Content'), findsNothing);

    // Tap the build button
    await tester.tap(find.byIcon(Icons.build_outlined));
    await tester.pumpAndSettle();

    // Verify that tapping opened the endDrawer
    expect(find.text('End Drawer Content'), findsOneWidget);
  });
}
