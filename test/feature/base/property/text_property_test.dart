import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/property/property.dart';
import 'package:stelaris/feature/base/property/property_card.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  String? changed;

  Future<void> pumpCard(WidgetTester tester, TextProperty property) async {
    changed = null;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PropertyCard(property: property)),
      ),
    );
  }

  TextProperty provider({String value = 'bitmap', String? hint}) =>
      TextProperty(
        label: 'Provider',
        value: value,
        hintText: hint,
        tooltip: 'The font provider',
        validator: (value) =>
            value != null && value.contains(' ') ? 'No spaces' : null,
        onChanged: (value) => changed = value,
      );

  Finder dialogSave() =>
      find.descendant(of: find.byType(FormDialog), matching: find.text('Save'));

  testWidgets('shows the label, the value and the tooltip', (tester) async {
    await pumpCard(tester, provider());

    expect(find.text('Provider'), findsOneWidget);
    expect(find.text('bitmap'), findsOneWidget);
    expect(find.byTooltip('The font provider'), findsOneWidget);
  });

  testWidgets('shows the hint, or a dash, for an empty value', (tester) async {
    await pumpCard(tester, provider(value: '', hint: 'minecraft:default'));
    expect(find.text('minecraft:default'), findsOneWidget);

    await pumpCard(tester, provider(value: ''));
    expect(find.text('–'), findsOneWidget);
  });

  testWidgets('a click opens the dialog with the value filled in', (
    tester,
  ) async {
    await pumpCard(tester, provider());

    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();

    expect(find.byType(FormDialog), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'bitmap');
    expect(field.focusNode!.hasFocus, isTrue);
  });

  testWidgets('save reports a changed value', (tester) async {
    await pumpCard(tester, provider());
    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ttf');
    await tester.tap(dialogSave());
    await tester.pumpAndSettle();

    expect(changed, 'ttf');
    expect(find.byType(FormDialog), findsNothing);
  });

  testWidgets('enter saves like the button', (tester) async {
    await pumpCard(tester, provider());
    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ttf');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(changed, 'ttf');
  });

  testWidgets('an invalid value keeps the dialog open', (tester) async {
    await pumpCard(tester, provider());
    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'a b');
    await tester.tap(dialogSave());
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(FormDialog), findsOneWidget);
    expect(find.text('No spaces'), findsOneWidget);
    expect(changed, isNull);
  });

  testWidgets('an unchanged value and cancel report nothing', (tester) async {
    await pumpCard(tester, provider());
    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();
    await tester.tap(dialogSave());
    await tester.pumpAndSettle();
    expect(changed, isNull);

    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ttf');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(changed, isNull);
  });

  testWidgets('a stored invalid value can still be cancelled', (tester) async {
    await pumpCard(tester, provider(value: 'a b'));
    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(FormDialog), findsNothing);
    expect(changed, isNull);
  });
}
