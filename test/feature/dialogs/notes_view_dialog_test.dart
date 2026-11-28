import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/dialogs/notes_view_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';

void main() {
  group('NotesViewDialog', () {
    Future<void> pump(WidgetTester tester) => tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: NotesViewDialog(name: 'Ruby', notes: 'Drops in caves'),
        ),
      ),
    );

    testWidgets('shows the notes', (tester) async {
      await pump(tester);

      expect(find.text('Drops in caves'), findsOneWidget);
    });

    testWidgets('points to the card menu with its icon, not a text glyph', (
      tester,
    ) async {
      await pump(tester);

      final icon = tester.widget<Icon>(
        find.byKey(const Key('notes_edit_hint_menu_icon')),
      );
      expect(icon.icon, Icons.more_vert);

      final hint = find.textContaining(
        'on the overview card',
        findRichText: true,
      );
      expect(hint, findsOneWidget);
      final text = tester.widget<RichText>(hint).text.toPlainText();
      expect(text, isNot(contains('⋯')));
      expect(text, isNot(contains('→')));
      expect(text, isNot(contains('\u0000')));
    });
  });
}
