import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/component/component_dialog.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/component_context.dart';

void main() {
  Future<List<String>> pumpDialog(
    WidgetTester tester, {
    String initialValue = '',
    ThemeData? theme,
  }) async {
    final saved = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ComponentDialog(
            title: 'Edit lore',
            actionLabel: 'Save',
            componentContext: ComponentContext.lore,
            initialValue: initialValue,
            onSave: saved.add,
          ),
        ),
      ),
    );
    return saved;
  }

  testWidgets('shows the source in its formatting', (tester) async {
    await pumpDialog(tester, initialValue: '<gold>Epic</gold>');

    final span = tester
        .widget<EditableText>(find.byType(EditableText))
        .controller
        .buildTextSpan(
          context: tester.element(find.byType(EditableText)),
          withComposing: false,
        );
    expect(span.toPlainText(), '<gold>Epic</gold>');

    final parts = <TextSpan>[];
    span.visitChildren((child) {
      if (child is TextSpan && child.text != null) parts.add(child);
      return true;
    });
    final epic = parts.singleWhere((part) => part.text == 'Epic');
    expect(epic.style?.color, const Color(0xFFFFAA00));
    final tag = parts.singleWhere((part) => part.text == '<gold>');
    expect(tag.style?.color, previewPlaceholderColor);
  });

  for (final theme in [ThemeData.light(), ThemeData.dark()]) {
    testWidgets(
      'the field has the dark preview background in ${theme.brightness.name} '
      'theme',
      (tester) async {
        await pumpDialog(tester, theme: theme);

        final decoration = tester
            .widget<TextField>(find.byType(TextField))
            .decoration!;
        expect(decoration.filled, isTrue);
        expect(decoration.fillColor, previewBackground);
      },
    );
  }

  testWidgets('turns pasted line breaks into a space', (tester) async {
    await pumpDialog(tester);

    await tester.enterText(find.byType(TextField), 'one\ntwo');

    final controller = tester
        .widget<TextField>(find.byType(TextField))
        .controller!;
    expect(controller.text, 'one two');
  });

  testWidgets('saves the text on enter', (tester) async {
    final saved = await pumpDialog(tester);

    await tester.enterText(find.byType(TextField), '<b>Sharp');
    await tester.testTextInput.receiveAction(TextInputAction.done);

    expect(saved, ['<b>Sharp']);
  });

  testWidgets('does not save an empty text', (tester) async {
    final saved = await pumpDialog(tester);

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(saved, isEmpty);
    expect(find.text("The value can't be empty"), findsOneWidget);
  });
}
