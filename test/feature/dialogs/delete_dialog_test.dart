import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/app_theme.dart';

void main() {
  group('DeleteDialog', () {
    final settings = ThemeSettings.defaultSettings();
    final themes = {
      'light': AppTheme.buildLight(settings),
      'dark': AppTheme.buildDark(settings.copyWith(isDarkMode: true)),
    };

    Future<void> openDialog(WidgetTester tester, ThemeData theme) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => DeleteDialog<String>(
                  title: 'Delete lore',
                  header: const [TextSpan(text: 'Header text')],
                  value: 'value',
                  successfully: (_) => true,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    for (final MapEntry(key: name, value: theme) in themes.entries) {
      testWidgets('unstyled header uses the theme text color ($name)', (
        tester,
      ) async {
        await openDialog(tester, theme);

        final paragraph = tester.renderObject<RenderParagraph>(
          find.text('Header text'),
        );
        expect(paragraph.text.style?.color, theme.textTheme.bodyMedium?.color);
      });

      testWidgets('delete button uses the error colors ($name)', (
        tester,
      ) async {
        await openDialog(tester, theme);

        final button = find.ancestor(
          of: find.text('Delete'),
          matching: find.bySubtype<ButtonStyleButton>(),
        );
        final material = tester.widget<Material>(
          find.descendant(of: button, matching: find.byType(Material)).first,
        );
        expect(material.color, theme.colorScheme.error);

        final label = tester.renderObject<RenderParagraph>(find.text('Delete'));
        expect(label.text.style?.color, theme.colorScheme.onError);
      });
    }
  });
}
