import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/cards/switch_card.dart';

void main() {
  group('SwitchCard', () {
    testWidgets('shows the label and reports the toggled value', (
      tester,
    ) async {
      final List<bool> updates = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwitchCard(
              display: 'Hidden',
              currentValue: false,
              valueUpdate: updates.add,
            ),
          ),
        ),
      );

      expect(find.text('Hidden'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      expect(updates, [true]);
    });
  });
}
