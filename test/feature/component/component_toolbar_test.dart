import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/component/component_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/component_context.dart';

void main() {
  Future<void> pumpDialog(WidgetTester tester, String text) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ComponentDialog(
            title: 'Edit lore',
            actionLabel: 'Save',
            componentContext: ComponentContext.lore,
            initialValue: text,
            onSave: (_) {},
          ),
        ),
      ),
    );
  }

  TextEditingController controllerOf(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!;

  void select(WidgetTester tester, int start, int end) {
    controllerOf(tester).selection = TextSelection(
      baseOffset: start,
      extentOffset: end,
    );
  }

  bool isSelected(WidgetTester tester, String tag) {
    return tester
        .widget<IconButton>(
          find.descendant(
            of: find.byKey(Key('minimessage_toggle_$tag')),
            matching: find.byType(IconButton),
          ),
        )
        .isSelected!;
  }

  testWidgets('bold wraps the selection and turns on', (tester) async {
    await pumpDialog(tester, 'Epic Sword');
    select(tester, 5, 10);
    await tester.pump();
    expect(isSelected(tester, 'b'), isFalse);

    await tester.tap(find.byKey(const Key('minimessage_toggle_b')));
    await tester.pump();

    expect(controllerOf(tester).text, 'Epic <b>Sword</b>');
    expect(isSelected(tester, 'b'), isTrue);
  });

  testWidgets('an active style button removes its formatting', (tester) async {
    await pumpDialog(tester, '<u>Sharp</u>');
    controllerOf(tester).selection = const TextSelection.collapsed(offset: 5);
    await tester.pump();
    expect(isSelected(tester, 'u'), isTrue);
    expect(isSelected(tester, 'b'), isFalse);

    await tester.tap(find.byKey(const Key('minimessage_toggle_u')));
    await tester.pump();

    expect(controllerOf(tester).text, 'Sharp');
    expect(isSelected(tester, 'u'), isFalse);
  });

  testWidgets('the color menu applies the picked color by its key', (
    tester,
  ) async {
    await pumpDialog(tester, 'Night');
    select(tester, 0, 5);

    await tester.tap(find.byKey(const Key('minimessage_color')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Dark Purple'));
    await tester.pumpAndSettle();

    expect(controllerOf(tester).text, '<dark_purple>Night</dark_purple>');
    expect(find.byTooltip('Dark Purple'), findsNothing);
  });

  testWidgets('the gradient menu applies after the second color', (
    tester,
  ) async {
    await pumpDialog(tester, 'Fire');
    select(tester, 0, 4);

    await tester.tap(find.byKey(const Key('minimessage_gradient')));
    await tester.pumpAndSettle();
    expect(find.text('Pick the first color'), findsOneWidget);

    await tester.tap(find.byTooltip('Gold'));
    await tester.pumpAndSettle();
    expect(find.text('Pick the second color'), findsOneWidget);
    expect(controllerOf(tester).text, 'Fire');

    await tester.tap(find.byTooltip('Red'));
    await tester.pumpAndSettle();

    expect(controllerOf(tester).text, '<gradient:gold:red>Fire</gradient>');
    expect(find.text('Pick the second color'), findsNothing);
  });

  testWidgets('the gradient menu starts over when opened again', (
    tester,
  ) async {
    await pumpDialog(tester, 'Fire');
    final button = find.byKey(const Key('minimessage_gradient'));

    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Gold'));
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('Pick the first color'), findsOneWidget);
  });

  testWidgets('clear removes all formatting', (tester) async {
    await pumpDialog(tester, '<gold><b>Epic</b></gold>');

    await tester.tap(find.byKey(const Key('minimessage_clear')));
    await tester.pump();

    expect(controllerOf(tester).text, 'Epic');
  });

  testWidgets('ctrl + b toggles bold in the field', (tester) async {
    await pumpDialog(tester, 'Epic');
    await tester.pump();
    select(tester, 0, 4);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(controllerOf(tester).text, '<b>Epic</b>');
  });

  Color barColor(WidgetTester tester) {
    final bar = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const Key('minimessage_color_bar')),
        matching: find.byType(DecoratedBox),
      ),
    );
    return (bar.decoration as BoxDecoration).color!;
  }

  testWidgets('the color button shows the color at the caret', (tester) async {
    await pumpDialog(tester, '<yellow>a<dark_aqua>b');
    final controller = controllerOf(tester);

    controller.selection = const TextSelection.collapsed(offset: 9);
    await tester.pump();
    expect(barColor(tester), const Color(0xFFFFFF55));

    controller.selection = const TextSelection.collapsed(
      offset: '<yellow>a<dark_aqua>b'.length,
    );
    await tester.pump();
    expect(barColor(tester), const Color(0xFF00AAAA));
  });

  testWidgets('the color button shows the lore purple without a color', (
    tester,
  ) async {
    await pumpDialog(tester, 'plain');
    controllerOf(tester).selection = const TextSelection.collapsed(offset: 2);
    await tester.pump();

    expect(barColor(tester), const Color(0xFFAA00AA));
  });

  testWidgets('rainbow toggles like the style buttons', (tester) async {
    await pumpDialog(tester, 'Party');
    select(tester, 0, 5);

    await tester.tap(find.byKey(const Key('minimessage_toggle_rainbow')));
    await tester.pump();

    expect(controllerOf(tester).text, '<rainbow>Party</rainbow>');
    expect(isSelected(tester, 'rainbow'), isTrue);
  });
}
