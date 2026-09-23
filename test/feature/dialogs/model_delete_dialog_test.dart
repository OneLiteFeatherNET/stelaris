import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';
import 'package:stelaris/feature/dialogs/model_delete_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  late int deleteCalls;

  Future<void> pumpDialog(WidgetTester tester, {String? namespacedKey}) {
    deleteCalls = 0;
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ModelDeleteDialog<String>(
            title: 'Delete item',
            name: 'Dark Sword',
            namespacedKey: namespacedKey,
            warning: 'Related data goes too.',
            value: 'value',
            successfully: (_) {
              deleteCalls++;
              return false;
            },
          ),
        ),
      ),
    );
  }

  FilledButton deleteButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byType(FilledButton));

  Future<void> typeName(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
  }

  group('ModelDeleteDialog', () {
    testWidgets('shows name, key and warning', (tester) async {
      await pumpDialog(tester, namespacedKey: 'stelaris:dark_sword');

      expect(find.text('Delete item'), findsOneWidget);
      expect(find.text('Dark Sword'), findsOneWidget);
      expect(
        find.widgetWithText(InfoChip, 'stelaris:dark_sword'),
        findsOneWidget,
      );
      expect(
        find.text(
          'This action cannot be undone. Related data goes too.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('hides the key chip without a key', (tester) async {
      await pumpDialog(tester);

      expect(find.byType(InfoChip), findsNothing);
    });

    testWidgets('enables delete only for the exact name', (tester) async {
      await pumpDialog(tester);
      expect(deleteButton(tester).onPressed, isNull);

      await typeName(tester, 'dark sword');
      expect(deleteButton(tester).onPressed, isNull);

      await typeName(tester, ' Dark Sword ');
      expect(deleteButton(tester).onPressed, isNotNull);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(deleteCalls, 1);
    });

    testWidgets('enter only deletes with the right name', (tester) async {
      await pumpDialog(tester);

      await typeName(tester, 'wrong');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(deleteCalls, 0);

      await typeName(tester, 'Dark Sword');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(deleteCalls, 1);
    });
  });
}
