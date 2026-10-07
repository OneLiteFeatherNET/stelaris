import 'package:flutter/services.dart';
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
        help: 'The font provider',
        examples: const ['bitmap', 'ttf'],
        validator: (value) =>
            value != null && value.contains(' ') ? 'No spaces' : null,
        onChanged: (value) => changed = value,
      );

  Finder dialogSave() =>
      find.descendant(of: find.byType(FormDialog), matching: find.text('Save'));

  testWidgets('shows the label and the value, the help only in the dialog', (
    tester,
  ) async {
    await pumpCard(tester, provider());

    expect(find.text('Provider'), findsOneWidget);
    expect(find.text('bitmap'), findsOneWidget);
    expect(find.byType(Tooltip), findsNothing);
  });

  testWidgets('the dialog explains the field under its title', (tester) async {
    await pumpCard(tester, provider());

    await tester.tap(find.text('Provider'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(FormDialog),
        matching: find.text('The font provider'),
      ),
      findsOneWidget,
    );
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

  testWidgets('the info dialog shows the help and the examples', (
    tester,
  ) async {
    await pumpCard(tester, provider());

    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pumpAndSettle();

    Finder inDialog(String text) =>
        find.descendant(of: find.byType(FormDialog), matching: find.text(text));
    expect(inDialog('The font provider'), findsOneWidget);
    expect(inDialog('EXAMPLES'), findsOneWidget);
    expect(inDialog('bitmap'), findsOneWidget);
    expect(inDialog('ttf'), findsOneWidget);
  });

  testWidgets('an example can be copied', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpCard(tester, provider());

    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.copy_outlined).last);
    await tester.pump();

    expect(copied, 'ttf');
  });
}
