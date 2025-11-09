import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/base/button/settings_button.dart';

void main() {
  group('Settings button test', () {
    testWidgets('layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsButton())),
      );

      // Verify the button is present
      expect(find.byType(IconButton), findsOneWidget);

      // Verify the settings icon is present
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
