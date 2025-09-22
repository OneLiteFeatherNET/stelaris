import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/base/model_text.dart';

void main() {
  testWidgets('renders the provided displayName', (tester) async {
    // Arrange
    const widget = TextWidget(displayName: 'Hello World');

    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      ),
    );

    // Assert
    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('uses ellipsis overflow', (tester) async {
    const widget = TextWidget(displayName: 'Overflow Test');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: widget,
        ),
      ),
    );

    // Grab the Text widget inside
    final text = tester.widget<Text>(find.byType(Text));
    expect(text.overflow, TextOverflow.ellipsis);
  });
}
