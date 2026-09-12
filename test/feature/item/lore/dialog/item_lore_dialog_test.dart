import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/item/lore/dialog/item_lore_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  group('ItemLoreDialog Widget Tests', () {
    Future<void> pumpDialog(
      WidgetTester tester, {
      required void Function(String) onSave,
      String title = 'Add Lore',
      String? initialData,
      ThemeData? theme,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ItemLoreDialog(
                        title: title,
                        data: initialData,
                        valueUpdate: onSave,
                      ),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders dialog with Normal and MiniMessage tabs', (tester) async {
      await pumpDialog(tester, onSave: (_) {});

      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('MiniMessage'), findsOneWidget);
      expect(find.text('Color'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
    });

    testWidgets('creates lore with selected color tag from Normal tab', (tester) async {
      String? savedResult;
      await pumpDialog(
        tester,
        onSave: (val) => savedResult = val,
      );

      // Enter text
      await tester.enterText(find.byType(TextFormField).first, 'Sharpness V');
      await tester.pump();

      // Select gold color chip
      final goldChip = find.byTooltip('Gold');
      expect(goldChip, findsOneWidget);
      await tester.tap(goldChip);
      await tester.pump();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedResult, equals('<gold>Sharpness V'));
    });

    testWidgets('creates plain lore without color tag when None is selected', (tester) async {
      String? savedResult;
      await pumpDialog(
        tester,
        onSave: (val) => savedResult = val,
      );

      // Enter text
      await tester.enterText(find.byType(TextFormField).first, 'Plain text');
      await tester.pump();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedResult, equals('Plain text'));
    });

    testWidgets('creates raw MiniMessage string from MiniMessage tab', (tester) async {
      String? savedResult;
      await pumpDialog(
        tester,
        onSave: (val) => savedResult = val,
      );

      // Switch to MiniMessage tab
      await tester.tap(find.text('MiniMessage'));
      await tester.pumpAndSettle();

      // Enter MiniMessage
      final miniMessageField = find.byType(TextFormField).last;
      await tester.enterText(miniMessageField, '<gradient:red:blue>Custom Sword</gradient>');
      await tester.pump();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedResult, equals('<gradient:red:blue>Custom Sword</gradient>'));
    });

    testWidgets('pre-populates Normal tab when editing simple <color> text', (tester) async {
      String? savedResult;
      await pumpDialog(
        tester,
        initialData: '<red>Dangerous Item',
        onSave: (val) => savedResult = val,
      );

      // Check that it opened in Normal tab with text stripped of tag
      expect(find.text('Dangerous Item'), findsWidgets);

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedResult, equals('<red>Dangerous Item'));
    });

    testWidgets('pre-populates MiniMessage tab when editing complex MiniMessage text', (tester) async {
      String? savedResult;
      await pumpDialog(
        tester,
        initialData: '<rainbow>Rainbow Lore</rainbow>',
        onSave: (val) => savedResult = val,
      );

      // Should open in MiniMessage tab
      expect(find.text('<rainbow>Rainbow Lore</rainbow>'), findsOneWidget);

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(savedResult, equals('<rainbow>Rainbow Lore</rainbow>'));
    });

    testWidgets('live preview in MiniMessage tab renders parsed styling', (tester) async {
      await pumpDialog(tester, onSave: (_) {});

      // Switch to MiniMessage tab
      await tester.tap(find.text('MiniMessage'));
      await tester.pumpAndSettle();

      // Initially shows fallback text
      expect(find.text('Lore Preview'), findsOneWidget);

      // Type MiniMessage text
      final miniMessageField = find.byType(TextFormField).last;
      await tester.enterText(miniMessageField, '<yellow>Live Preview Text</yellow>');
      await tester.pump();

      // Verify that RichText in preview container contains the parsed span with yellow color
      final richTextFinder = find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText() == 'Live Preview Text',
      );
      expect(richTextFinder, findsOneWidget);

      final richText = tester.widget<RichText>(richTextFinder);
      final rootSpan = richText.text as TextSpan;
      TextSpan? styledSpan;
      rootSpan.visitChildren((span) {
        if (span is TextSpan && span.text == 'Live Preview Text') {
          styledSpan = span;
          return false;
        }
        return true;
      });
      expect(styledSpan, isNotNull);
      expect(styledSpan!.style?.color, equals(const Color(0xFFFFFF55)));
    });

    testWidgets('clicking tag chip in MiniMessage tab inserts tag', (tester) async {
      await pumpDialog(tester, onSave: (_) {});

      // Switch to MiniMessage tab
      await tester.tap(find.text('MiniMessage'));
      await tester.pumpAndSettle();

      // Click <b> chip
      await tester.tap(find.text('<b>'));
      await tester.pump();

      // Check that text field now has <b></b>
      final miniMessageField = find.byType(TextFormField).last;
      final formField = tester.widget<TextFormField>(miniMessageField);
      expect(formField.controller?.text, equals('<b></b>'));
    });

    testWidgets('clicking syntax guide opens guide dialog and can be closed', (tester) async {
      await pumpDialog(tester, onSave: (_) {});

      // Switch to MiniMessage tab
      await tester.tap(find.text('MiniMessage'));
      await tester.pumpAndSettle();

      // Click syntax guide
      await tester.tap(find.text('MiniMessage Syntax Guide'));
      await tester.pumpAndSettle();

      // Verify guide dialog is shown
      expect(find.text('Named colors (<red>, <yellow>, ...) or 3/6-digit hex (<#ff00aa>)'), findsOneWidget);

      // Close guide
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      expect(find.text('Named colors (<red>, <yellow>, ...) or 3/6-digit hex (<#ff00aa>)'), findsNothing);
    });

    testWidgets('adapts preview container background for dark text in dark theme', (tester) async {
      await pumpDialog(
        tester,
        theme: ThemeData.dark(),
        onSave: (_) {},
      );

      // Default (white) in dark theme -> transparent
      var container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect((container.decoration as BoxDecoration).color, equals(Colors.transparent));

      // Select Black chip -> light contrast background
      final blackChip = find.byTooltip('Black');
      expect(blackChip, findsOneWidget);
      await tester.tap(blackChip);
      await tester.pump();

      container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect((container.decoration as BoxDecoration).color, equals(const Color(0xFFE4E4EE)));
    });

    testWidgets('adapts preview container background for bright text in light theme', (tester) async {
      await pumpDialog(
        tester,
        theme: ThemeData.light(),
        onSave: (_) {},
      );

      // Default (white) in light theme -> dark contrast background
      var container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect((container.decoration as BoxDecoration).color, equals(const Color(0xFF1E1F28)));

      // Select Black chip -> transparent
      final blackChip = find.byTooltip('Black');
      expect(blackChip, findsOneWidget);
      await tester.tap(blackChip);
      await tester.pump();

      container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect((container.decoration as BoxDecoration).color, equals(Colors.transparent));
    });

    testWidgets('adapts preview container background in MiniMessage tab for dark and light themes', (tester) async {
      // In dark theme with <black>
      await pumpDialog(
        tester,
        theme: ThemeData.dark(),
        onSave: (_) {},
      );

      await tester.tap(find.text('MiniMessage'));
      await tester.pumpAndSettle();

      final miniMessageField = find.byType(TextFormField).last;
      await tester.enterText(miniMessageField, '<black>Dark Secret</black>');
      await tester.pump();

      final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect((container.decoration as BoxDecoration).color, equals(const Color(0xFFE4E4EE)));
    });
  });
}
