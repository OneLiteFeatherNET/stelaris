import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/edit_card/edit_card.dart';

/// Opens the [EditCard] labelled [label], types [text] into its dialog and
/// saves with Enter.
Future<void> editCard(WidgetTester tester, String label, String text) async {
  final card = find.widgetWithText(EditCard, label);
  await tester.ensureVisible(card);
  await tester.tap(card);
  await tester.pumpAndSettle();
  await tester.enterText(
    find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextFormField),
    ),
    text,
  );
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}
