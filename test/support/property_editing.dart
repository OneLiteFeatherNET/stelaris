import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/property/property_card.dart';

/// Opens the card labelled [label], enters [text] and saves the dialog.
///
/// The dialog's save button is looked up inside the dialog: a detail page's
/// header has a "Save" button of its own.
Future<void> editTextProperty(
  WidgetTester tester,
  String label,
  String text,
) async {
  await tester.tap(find.widgetWithText(PropertyCard, label));
  await tester.pumpAndSettle();
  final dialog = find.byType(FormDialog);
  await tester.enterText(
    find.descendant(of: dialog, matching: find.byType(TextField)),
    text,
  );
  await tester.tap(find.descendant(of: dialog, matching: find.text('Save')));
  await tester.pumpAndSettle();
}

/// Opens the card labelled [label] and picks [option] in its dialog.
Future<void> pickChoice(
  WidgetTester tester,
  String label,
  String option,
) async {
  await tester.tap(find.widgetWithText(PropertyCard, label));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: find.byType(FormDialog), matching: find.text(option)),
  );
  await tester.pumpAndSettle();
}
